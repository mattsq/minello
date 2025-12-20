#!/usr/bin/env python3
"""
CI Feedback Generator for GitHub Actions

This script:
1. Parses CI log files from artifacts
2. Extracts error excerpts
3. Generates summary.json and summary.md
4. Provides structured feedback for both humans and agents

Usage:
    python3 scripts/ci_feedback.py <artifacts-dir> <output-dir> <run-id> <run-url> <sha> <branch> <pr-number>
"""

import json
import os
import re
import sys
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Any


@dataclass
class FailedStep:
    """Represents a failed CI step with error context"""
    step_name: str
    log_excerpt: List[str]  # Max ~10 lines of relevant errors


@dataclass
class JobResult:
    """Represents the result of a single CI job"""
    job_name: str
    conclusion: str  # success, failure, cancelled, skipped
    duration_seconds: Optional[int]
    failed_steps: List[FailedStep]


@dataclass
class ArtifactInfo:
    """Information about uploaded artifacts"""
    name: str
    path: str


@dataclass
class CISummary:
    """Complete CI run summary"""
    run_id: str
    run_url: str
    sha: str
    branch: str
    pr_number: Optional[str]
    overall_conclusion: str  # success, failure, cancelled
    timestamp: str
    jobs: List[JobResult]
    artifacts: List[ArtifactInfo]


class LogParser:
    """Parses CI logs to extract error information"""

    # Patterns that indicate errors
    ERROR_PATTERNS = [
        re.compile(r'(?i)error:', re.MULTILINE),
        re.compile(r'(?i)failed:', re.MULTILINE),
        re.compile(r'(?i)failure:', re.MULTILINE),
        re.compile(r'(?i)\*\*\s*BUILD FAILED\s*\*\*', re.MULTILINE),
        re.compile(r'(?i)\*\*\s*TEST FAILED\s*\*\*', re.MULTILINE),
        re.compile(r'(?i)fatal:', re.MULTILINE),
        re.compile(r'(?i)exception:', re.MULTILINE),
        re.compile(r'(?i)traceback', re.MULTILINE),
        re.compile(r'❌', re.MULTILINE),
        re.compile(r'⚠️.*(?i)(error|fail)', re.MULTILINE),
    ]

    # Patterns to exclude (noise)
    EXCLUDE_PATTERNS = [
        re.compile(r'^\s*$'),  # Empty lines
        re.compile(r'^[\s\-=]+$'),  # Separator lines
    ]

    @staticmethod
    def extract_errors(log_content: str, max_lines: int = 10) -> List[str]:
        """
        Extract relevant error lines from log content

        Args:
            log_content: Full log text
            max_lines: Maximum number of error lines to extract

        Returns:
            List of error lines (cleaned)
        """
        lines = log_content.split('\n')
        error_lines = []

        for i, line in enumerate(lines):
            # Skip excluded patterns
            if any(pattern.match(line) for pattern in LogParser.EXCLUDE_PATTERNS):
                continue

            # Check if line matches error patterns
            if any(pattern.search(line) for pattern in LogParser.ERROR_PATTERNS):
                # Include context: line before, error line, and 2 lines after
                start = max(0, i - 1)
                end = min(len(lines), i + 3)
                context = lines[start:end]

                for ctx_line in context:
                    cleaned = ctx_line.strip()
                    if cleaned and cleaned not in error_lines:
                        error_lines.append(cleaned)
                        if len(error_lines) >= max_lines:
                            return error_lines[:max_lines]

        # If no errors found but we know the job failed, take last N lines
        if not error_lines and log_content:
            tail_lines = [l.strip() for l in lines[-max_lines:] if l.strip()]
            return tail_lines[-max_lines:]

        return error_lines[:max_lines]


def parse_job_logs(artifacts_dir: Path, job_name: str, job_conclusion: str) -> JobResult:
    """
    Parse logs for a specific job

    Args:
        artifacts_dir: Directory containing downloaded artifacts
        job_name: Name of the job (build, test, lint)
        job_conclusion: Job conclusion from GitHub Actions

    Returns:
        JobResult with parsed information
    """
    failed_steps = []

    # Look for log files for this job
    job_log_dir = artifacts_dir / f"{job_name}-logs"

    if job_log_dir.exists():
        for log_file in job_log_dir.glob("*.log"):
            step_name = log_file.stem

            try:
                with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
                    log_content = f.read()

                # Extract errors if this step had issues
                error_lines = LogParser.extract_errors(log_content, max_lines=10)

                if error_lines:
                    failed_steps.append(FailedStep(
                        step_name=step_name,
                        log_excerpt=error_lines
                    ))
            except Exception as e:
                print(f"Warning: Could not parse {log_file}: {e}", file=sys.stderr)

    # If job failed but we found no specific step logs, create a generic entry
    if job_conclusion == 'failure' and not failed_steps:
        failed_steps.append(FailedStep(
            step_name=f"{job_name} (general)",
            log_excerpt=[f"Job {job_name} failed but no detailed logs were captured"]
        ))

    return JobResult(
        job_name=job_name,
        conclusion=job_conclusion,
        duration_seconds=None,  # Could parse from GitHub Actions output if available
        failed_steps=failed_steps
    )


def find_artifacts(output_dir: Path) -> List[ArtifactInfo]:
    """
    Find all artifacts that should be referenced in summary

    Args:
        output_dir: Directory where .ci/ files will be written

    Returns:
        List of artifact information
    """
    artifacts = []

    # Standard artifacts we expect
    artifact_names = [
        "test-results",
        "failed-snapshots",
        "lint-results",
        "build-logs",
        "test-logs",
        "lint-logs",
    ]

    for name in artifact_names:
        artifacts.append(ArtifactInfo(
            name=name,
            path=f".ci/{name}"  # Relative path in repo
        ))

    return artifacts


def generate_summary(
    artifacts_dir: Path,
    output_dir: Path,
    run_id: str,
    run_url: str,
    sha: str,
    branch: str,
    pr_number: Optional[str],
    job_results: Dict[str, str]
) -> CISummary:
    """
    Generate complete CI summary from job results

    Args:
        artifacts_dir: Directory with downloaded artifacts
        output_dir: Directory to write summary files
        run_id: GitHub Actions run ID
        run_url: URL to the workflow run
        sha: Git commit SHA
        branch: Git branch name
        pr_number: PR number (if applicable)
        job_results: Dict of job_name -> conclusion

    Returns:
        Complete CISummary object
    """
    jobs = []

    # Parse each job's logs
    for job_name, conclusion in job_results.items():
        job_result = parse_job_logs(artifacts_dir, job_name, conclusion)
        jobs.append(job_result)

    # Determine overall conclusion
    all_conclusions = [job.conclusion for job in jobs]
    if 'failure' in all_conclusions:
        overall = 'failure'
    elif 'cancelled' in all_conclusions:
        overall = 'cancelled'
    elif all(c == 'success' for c in all_conclusions):
        overall = 'success'
    else:
        overall = 'partial'

    return CISummary(
        run_id=run_id,
        run_url=run_url,
        sha=sha,
        branch=branch,
        pr_number=pr_number,
        overall_conclusion=overall,
        timestamp=datetime.utcnow().isoformat() + 'Z',
        jobs=jobs,
        artifacts=find_artifacts(output_dir)
    )


def write_json_summary(summary: CISummary, output_path: Path):
    """Write JSON summary file"""

    # Convert dataclasses to dicts
    def to_dict(obj):
        if hasattr(obj, '__dataclass_fields__'):
            return {k: to_dict(v) for k, v in asdict(obj).items()}
        elif isinstance(obj, list):
            return [to_dict(item) for item in obj]
        return obj

    summary_dict = to_dict(summary)

    with open(output_path, 'w') as f:
        json.dump(summary_dict, f, indent=2)

    print(f"✓ Wrote JSON summary to {output_path}")


def write_markdown_summary(summary: CISummary, output_path: Path):
    """Write human-readable markdown summary"""

    lines = []

    # Header
    if summary.overall_conclusion == 'success':
        lines.append("# ✅ CI Passed")
    else:
        lines.append(f"# ❌ CI Failed ({summary.overall_conclusion})")

    lines.append("")
    lines.append(f"**Run**: [{summary.run_id}]({summary.run_url})")
    lines.append(f"**Commit**: `{summary.sha[:8]}`")
    lines.append(f"**Branch**: `{summary.branch}`")
    if summary.pr_number:
        lines.append(f"**PR**: #{summary.pr_number}")
    lines.append(f"**Time**: {summary.timestamp}")
    lines.append("")

    # Job results
    lines.append("## Job Results")
    lines.append("")

    for job in summary.jobs:
        if job.conclusion == 'success':
            icon = "✅"
        elif job.conclusion == 'failure':
            icon = "❌"
        elif job.conclusion == 'cancelled':
            icon = "🚫"
        else:
            icon = "⚠️"

        lines.append(f"- {icon} **{job.job_name}**: {job.conclusion}")

    lines.append("")

    # Failed steps and errors
    failed_jobs = [job for job in summary.jobs if job.failed_steps]

    if failed_jobs:
        lines.append("## ❌ Failures")
        lines.append("")

        total_errors = 0
        for job in failed_jobs:
            lines.append(f"### {job.job_name}")
            lines.append("")

            for step in job.failed_steps:
                lines.append(f"#### Step: `{step.step_name}`")
                lines.append("")
                lines.append("```")
                for error_line in step.log_excerpt:
                    lines.append(error_line)
                    total_errors += 1
                lines.append("```")
                lines.append("")

        # Summary of top errors
        lines.append("## 🔍 Top Errors")
        lines.append("")

        error_count = 0
        for job in failed_jobs:
            for step in job.failed_steps:
                for error_line in step.log_excerpt[:5]:  # Top 5 per step
                    lines.append(f"- `{error_line[:100]}`")  # Truncate long lines
                    error_count += 1
                    if error_count >= 30:  # Max 30 error lines
                        break
                if error_count >= 30:
                    break
            if error_count >= 30:
                lines.append(f"- _(... and {total_errors - error_count} more errors)_")
                break

        lines.append("")

    # Artifacts
    lines.append("## 📦 Artifacts")
    lines.append("")
    lines.append("The following artifacts may be available:")
    for artifact in summary.artifacts:
        lines.append(f"- `{artifact.name}`")
    lines.append("")

    # How to find detailed results
    lines.append("## 📄 Detailed Results")
    lines.append("")
    lines.append(f"Full structured results: `.ci/summary.json` in branch `{summary.branch}`")
    lines.append("")
    lines.append("---")
    lines.append("<!-- ci-feedback -->")

    with open(output_path, 'w') as f:
        f.write('\n'.join(lines))

    print(f"✓ Wrote markdown summary to {output_path}")


def main():
    """Main entry point"""

    if len(sys.argv) < 8:
        print("Usage: ci_feedback.py <artifacts-dir> <output-dir> <run-id> <run-url> <sha> <branch> <pr-number>", file=sys.stderr)
        print("       pr-number should be 'none' if not a PR", file=sys.stderr)
        sys.exit(1)

    artifacts_dir = Path(sys.argv[1])
    output_dir = Path(sys.argv[2])
    run_id = sys.argv[3]
    run_url = sys.argv[4]
    sha = sys.argv[5]
    branch = sys.argv[6]
    pr_number = sys.argv[7] if sys.argv[7] != 'none' else None

    # Job results are passed via environment variables
    job_results = {
        'build': os.environ.get('BUILD_RESULT', 'unknown'),
        'test': os.environ.get('TEST_RESULT', 'unknown'),
        'lint': os.environ.get('LINT_RESULT', 'unknown'),
    }

    print(f"Generating CI feedback for run {run_id}")
    print(f"  Artifacts: {artifacts_dir}")
    print(f"  Output: {output_dir}")
    print(f"  Job results: {job_results}")

    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)

    # Generate summary
    summary = generate_summary(
        artifacts_dir=artifacts_dir,
        output_dir=output_dir,
        run_id=run_id,
        run_url=run_url,
        sha=sha,
        branch=branch,
        pr_number=pr_number,
        job_results=job_results
    )

    # Write outputs
    json_path = output_dir / "summary.json"
    md_path = output_dir / "summary.md"

    write_json_summary(summary, json_path)
    write_markdown_summary(summary, md_path)

    print("")
    print("✅ CI feedback generation complete")
    print(f"   - JSON: {json_path}")
    print(f"   - Markdown: {md_path}")

    # Exit with appropriate code
    if summary.overall_conclusion == 'failure':
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()
