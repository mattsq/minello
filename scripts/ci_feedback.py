#!/usr/bin/env python3
"""
CI Feedback Generator for GitHub Actions

This script:
1. Parses CI log files from artifacts with verbose error extraction
2. Extracts structured errors (compilation, tests, lint) with full context
3. Generates detailed summary.json and summary.md
4. Provides actionable feedback for both humans and agents

Usage:
    python3 scripts/ci_feedback.py <artifacts-dir> <output-dir> <run-id> <run-url> <sha> <branch> <pr-number>
"""

import json
import os
import re
import sys
from dataclasses import dataclass, asdict, field
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Any


@dataclass
class CompilationError:
    """Represents a compilation error with file location"""
    file_path: str
    line: Optional[int]
    column: Optional[int]
    error_type: str  # error or warning
    message: str
    context: List[str]  # Surrounding lines


@dataclass
class TestFailure:
    """Represents a test failure"""
    test_name: str
    test_case: str
    failure_message: str
    file_path: Optional[str]
    line_number: Optional[int]


@dataclass
class LintViolation:
    """Represents a lint violation"""
    file_path: str
    line: int
    column: Optional[int]
    rule: str
    message: str
    severity: str  # error or warning


@dataclass
class FailedStep:
    """Represents a failed CI step with detailed error context"""
    step_name: str
    log_excerpt: List[str]  # Raw log excerpt
    log_tail: List[str]  # Last 50 lines for full context
    compilation_errors: List[CompilationError] = field(default_factory=list)
    test_failures: List[TestFailure] = field(default_factory=list)
    lint_violations: List[LintViolation] = field(default_factory=list)
    error_summary: Dict[str, int] = field(default_factory=dict)


@dataclass
class JobResult:
    """Represents the result of a single CI job"""
    job_name: str
    conclusion: str  # success, failure, cancelled, skipped
    duration_seconds: Optional[int]
    failed_steps: List[FailedStep]
    total_errors: int = 0
    total_warnings: int = 0


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
    total_compilation_errors: int = 0
    total_test_failures: int = 0
    total_lint_violations: int = 0


class LogParser:
    """Parses CI logs to extract detailed error information"""

    # Xcode compilation error patterns
    # Format: /path/to/file.swift:line:column: error: message
    COMPILATION_ERROR_PATTERN = re.compile(
        r'^(/[^:]+):(\d+):(\d+):\s+(error|warning):\s+(.+)$',
        re.MULTILINE
    )

    # Xcode test failure patterns
    # Format: Test Case '-[TargetTests.TestClass testMethod]' failed
    TEST_FAILURE_PATTERN = re.compile(
        r"Test Case '-\[([^\]]+)\]' (failed|passed)",
        re.MULTILINE
    )

    # More detailed test failure with assertion
    TEST_ASSERTION_PATTERN = re.compile(
        r'^(/[^:]+):(\d+):\s+error:\s+-\[([^\]]+)\]\s+:\s+(.+)$',
        re.MULTILINE
    )

    # SwiftLint/SwiftFormat patterns
    # Format: /path/to/file.swift:line:column: error: (rule) message
    LINT_PATTERN = re.compile(
        r'^(/[^:]+):(\d+):(\d+):\s+(error|warning):\s+\(([^)]+)\)\s+(.+)$',
        re.MULTILINE
    )

    # General error patterns
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
        re.compile(r'(?i)⚠️.*(error|fail)', re.MULTILINE),
    ]

    # Patterns to exclude (noise)
    EXCLUDE_PATTERNS = [
        re.compile(r'^\s*$'),  # Empty lines
        re.compile(r'^[\s\-=]+$'),  # Separator lines
    ]

    @staticmethod
    def parse_compilation_errors(log_content: str) -> List[CompilationError]:
        """Extract compilation errors with file locations"""
        errors = []
        lines = log_content.split('\n')

        for i, line in enumerate(lines):
            match = LogParser.COMPILATION_ERROR_PATTERN.match(line)
            if match:
                file_path, line_num, col, error_type, message = match.groups()

                # Get context (3 lines before, error line, 5 lines after)
                start = max(0, i - 3)
                end = min(len(lines), i + 6)
                context = [lines[j].rstrip() for j in range(start, end)]

                errors.append(CompilationError(
                    file_path=file_path,
                    line=int(line_num),
                    column=int(col),
                    error_type=error_type,
                    message=message.strip(),
                    context=context
                ))

        return errors

    @staticmethod
    def parse_test_failures(log_content: str) -> List[TestFailure]:
        """Extract test failures with details"""
        failures = []
        lines = log_content.split('\n')

        # Find failed test cases
        failed_tests = {}
        for i, line in enumerate(lines):
            match = LogParser.TEST_FAILURE_PATTERN.search(line)
            if match and match.group(2) == 'failed':
                test_full_name = match.group(1)
                # Parse TestTarget.TestClass.testMethod
                parts = test_full_name.split('.')
                test_case = parts[-1] if parts else test_full_name
                test_name = '.'.join(parts[:-1]) if len(parts) > 1 else test_full_name

                failed_tests[test_full_name] = {
                    'test_name': test_name,
                    'test_case': test_case,
                    'line_index': i
                }

        # Extract failure messages for each failed test
        for test_full_name, test_info in failed_tests.items():
            start_idx = test_info['line_index']
            failure_message = []

            # Look for assertion failures in the next 20 lines
            for j in range(start_idx + 1, min(start_idx + 20, len(lines))):
                line = lines[j]

                # Stop at next test case
                if LogParser.TEST_FAILURE_PATTERN.search(line):
                    break

                # Check for assertion pattern
                assertion_match = LogParser.TEST_ASSERTION_PATTERN.match(line)
                if assertion_match:
                    file_path, line_num, test_method, message = assertion_match.groups()
                    failures.append(TestFailure(
                        test_name=test_info['test_name'],
                        test_case=test_info['test_case'],
                        failure_message=message.strip(),
                        file_path=file_path,
                        line_number=int(line_num)
                    ))
                    break
                elif 'error:' in line.lower() or 'failed:' in line.lower():
                    failure_message.append(line.strip())

            # If no structured failure found, use collected message
            if not any(f.test_case == test_info['test_case'] for f in failures):
                failures.append(TestFailure(
                    test_name=test_info['test_name'],
                    test_case=test_info['test_case'],
                    failure_message=' '.join(failure_message) or 'Test failed (no details)',
                    file_path=None,
                    line_number=None
                ))

        return failures

    @staticmethod
    def parse_lint_violations(log_content: str) -> List[LintViolation]:
        """Extract lint violations with file locations"""
        violations = []
        lines = log_content.split('\n')

        for line in lines:
            match = LogParser.LINT_PATTERN.match(line)
            if match:
                file_path, line_num, col, severity, rule, message = match.groups()
                violations.append(LintViolation(
                    file_path=file_path,
                    line=int(line_num),
                    column=int(col),
                    rule=rule,
                    message=message.strip(),
                    severity=severity
                ))

        return violations

    @staticmethod
    def extract_errors(log_content: str, max_lines: int = 30) -> List[str]:
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
                # Include context: 2 lines before, error line, and 3 lines after
                start = max(0, i - 2)
                end = min(len(lines), i + 4)
                context = lines[start:end]

                for ctx_line in context:
                    cleaned = ctx_line.rstrip()
                    if cleaned and cleaned not in error_lines:
                        error_lines.append(cleaned)
                        if len(error_lines) >= max_lines:
                            return error_lines[:max_lines]

        # If no errors found but we know something failed, take last N lines
        if not error_lines and log_content:
            tail_lines = [l.rstrip() for l in lines[-max_lines:] if l.strip()]
            return tail_lines[-max_lines:]

        return error_lines[:max_lines]

    @staticmethod
    def extract_log_tail(log_content: str, num_lines: int = 50) -> List[str]:
        """Extract the last N lines of the log for full context"""
        lines = log_content.split('\n')
        tail = [l.rstrip() for l in lines[-num_lines:] if l.strip()]
        return tail


def parse_job_logs(artifacts_dir: Path, job_name: str, job_conclusion: str) -> JobResult:
    """
    Parse logs for a specific job with detailed error extraction

    Args:
        artifacts_dir: Directory containing downloaded artifacts
        job_name: Name of the job (build, test, lint)
        job_conclusion: Job conclusion from GitHub Actions

    Returns:
        JobResult with parsed information
    """
    failed_steps = []
    total_errors = 0
    total_warnings = 0

    # Look for log files for this job
    job_log_dir = artifacts_dir / f"{job_name}-logs"

    if job_log_dir.exists():
        for log_file in job_log_dir.glob("*.log"):
            step_name = log_file.stem

            try:
                with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
                    log_content = f.read()

                # Extract different types of errors based on job type
                compilation_errors = []
                test_failures = []
                lint_violations = []

                if job_name == 'build':
                    compilation_errors = LogParser.parse_compilation_errors(log_content)
                    total_errors += sum(1 for e in compilation_errors if e.error_type == 'error')
                    total_warnings += sum(1 for e in compilation_errors if e.error_type == 'warning')

                elif job_name == 'test':
                    test_failures = LogParser.parse_test_failures(log_content)
                    compilation_errors = LogParser.parse_compilation_errors(log_content)
                    total_errors += len(test_failures)
                    total_errors += sum(1 for e in compilation_errors if e.error_type == 'error')
                    total_warnings += sum(1 for e in compilation_errors if e.error_type == 'warning')

                elif job_name == 'lint':
                    lint_violations = LogParser.parse_lint_violations(log_content)
                    total_errors += sum(1 for v in lint_violations if v.severity == 'error')
                    total_warnings += sum(1 for v in lint_violations if v.severity == 'warning')

                # Extract general error lines and log tail
                error_lines = LogParser.extract_errors(log_content, max_lines=30)
                log_tail = LogParser.extract_log_tail(log_content, num_lines=50)

                # Build error summary
                error_summary = {}
                if compilation_errors:
                    error_summary['compilation_errors'] = len([e for e in compilation_errors if e.error_type == 'error'])
                    error_summary['compilation_warnings'] = len([e for e in compilation_errors if e.error_type == 'warning'])
                if test_failures:
                    error_summary['test_failures'] = len(test_failures)
                if lint_violations:
                    error_summary['lint_errors'] = len([v for v in lint_violations if v.severity == 'error'])
                    error_summary['lint_warnings'] = len([v for v in lint_violations if v.severity == 'warning'])

                # Only add step if there are errors or it's a failed job
                if error_lines or compilation_errors or test_failures or lint_violations or job_conclusion == 'failure':
                    failed_steps.append(FailedStep(
                        step_name=step_name,
                        log_excerpt=error_lines,
                        log_tail=log_tail,
                        compilation_errors=compilation_errors,
                        test_failures=test_failures,
                        lint_violations=lint_violations,
                        error_summary=error_summary
                    ))
            except Exception as e:
                print(f"Warning: Could not parse {log_file}: {e}", file=sys.stderr)

    # If job failed but we found no specific step logs, create a generic entry
    if job_conclusion == 'failure' and not failed_steps:
        failed_steps.append(FailedStep(
            step_name=f"{job_name} (general)",
            log_excerpt=[f"Job {job_name} failed but no detailed logs were captured"],
            log_tail=[],
            error_summary={'uncategorized_failure': 1}
        ))
        total_errors += 1

    return JobResult(
        job_name=job_name,
        conclusion=job_conclusion,
        duration_seconds=None,
        failed_steps=failed_steps,
        total_errors=total_errors,
        total_warnings=total_warnings
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
    total_compilation_errors = 0
    total_test_failures = 0
    total_lint_violations = 0

    # Parse each job's logs
    for job_name, conclusion in job_results.items():
        job_result = parse_job_logs(artifacts_dir, job_name, conclusion)
        jobs.append(job_result)

        # Aggregate statistics
        for step in job_result.failed_steps:
            total_compilation_errors += len([e for e in step.compilation_errors if e.error_type == 'error'])
            total_test_failures += len(step.test_failures)
            total_lint_violations += len([v for v in step.lint_violations if v.severity == 'error'])

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
        artifacts=find_artifacts(output_dir),
        total_compilation_errors=total_compilation_errors,
        total_test_failures=total_test_failures,
        total_lint_violations=total_lint_violations
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

    # Statistics summary
    if summary.total_compilation_errors > 0 or summary.total_test_failures > 0 or summary.total_lint_violations > 0:
        lines.append("## 📊 Error Statistics")
        lines.append("")
        if summary.total_compilation_errors > 0:
            lines.append(f"- **Compilation Errors**: {summary.total_compilation_errors}")
        if summary.total_test_failures > 0:
            lines.append(f"- **Test Failures**: {summary.total_test_failures}")
        if summary.total_lint_violations > 0:
            lines.append(f"- **Lint Violations**: {summary.total_lint_violations}")
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

        error_info = ""
        if job.total_errors > 0:
            error_info = f" ({job.total_errors} errors"
            if job.total_warnings > 0:
                error_info += f", {job.total_warnings} warnings"
            error_info += ")"

        lines.append(f"- {icon} **{job.job_name}**: {job.conclusion}{error_info}")

    lines.append("")

    # Detailed failures
    failed_jobs = [job for job in summary.jobs if job.failed_steps]

    if failed_jobs:
        lines.append("## ❌ Detailed Failures")
        lines.append("")

        for job in failed_jobs:
            lines.append(f"### {job.job_name}")
            lines.append("")

            for step in job.failed_steps:
                lines.append(f"#### Step: `{step.step_name}`")
                lines.append("")

                # Show error summary
                if step.error_summary:
                    lines.append("**Error Summary:**")
                    for error_type, count in step.error_summary.items():
                        lines.append(f"- {error_type.replace('_', ' ').title()}: {count}")
                    lines.append("")

                # Show compilation errors
                if step.compilation_errors:
                    lines.append("<details>")
                    lines.append(f"<summary><b>Compilation Errors ({len(step.compilation_errors)})</b></summary>")
                    lines.append("")
                    for error in step.compilation_errors[:10]:  # Limit to first 10
                        lines.append(f"**{error.file_path}:{error.line}:{error.column}**")
                        lines.append(f"```")
                        lines.append(f"{error.error_type}: {error.message}")
                        lines.append("```")
                        if error.context:
                            lines.append("<details>")
                            lines.append("<summary>Context</summary>")
                            lines.append("")
                            lines.append("```swift")
                            for ctx_line in error.context:
                                lines.append(ctx_line)
                            lines.append("```")
                            lines.append("</details>")
                        lines.append("")
                    if len(step.compilation_errors) > 10:
                        lines.append(f"_... and {len(step.compilation_errors) - 10} more compilation errors_")
                        lines.append("")
                    lines.append("</details>")
                    lines.append("")

                # Show test failures
                if step.test_failures:
                    lines.append("<details>")
                    lines.append(f"<summary><b>Test Failures ({len(step.test_failures)})</b></summary>")
                    lines.append("")
                    for failure in step.test_failures[:20]:  # Limit to first 20
                        lines.append(f"**{failure.test_name}.{failure.test_case}**")
                        if failure.file_path and failure.line_number:
                            lines.append(f"- Location: `{failure.file_path}:{failure.line_number}`")
                        lines.append(f"```")
                        lines.append(failure.failure_message)
                        lines.append("```")
                        lines.append("")
                    if len(step.test_failures) > 20:
                        lines.append(f"_... and {len(step.test_failures) - 20} more test failures_")
                        lines.append("")
                    lines.append("</details>")
                    lines.append("")

                # Show lint violations
                if step.lint_violations:
                    lines.append("<details>")
                    lines.append(f"<summary><b>Lint Violations ({len(step.lint_violations)})</b></summary>")
                    lines.append("")
                    for violation in step.lint_violations[:20]:  # Limit to first 20
                        lines.append(f"**{violation.file_path}:{violation.line}:{violation.column}**")
                        lines.append(f"```")
                        lines.append(f"{violation.severity}: ({violation.rule}) {violation.message}")
                        lines.append("```")
                        lines.append("")
                    if len(step.lint_violations) > 20:
                        lines.append(f"_... and {len(step.lint_violations) - 20} more lint violations_")
                        lines.append("")
                    lines.append("</details>")
                    lines.append("")

                # Show general error excerpt
                if step.log_excerpt and not (step.compilation_errors or step.test_failures or step.lint_violations):
                    lines.append("<details>")
                    lines.append("<summary><b>Error Excerpt</b></summary>")
                    lines.append("")
                    lines.append("```")
                    for error_line in step.log_excerpt:
                        lines.append(error_line)
                    lines.append("```")
                    lines.append("</details>")
                    lines.append("")

                # Show full log tail for agents
                if step.log_tail:
                    lines.append("<details>")
                    lines.append("<summary><b>Full Log Tail (Last 50 Lines)</b></summary>")
                    lines.append("")
                    lines.append("```")
                    for tail_line in step.log_tail:
                        lines.append(tail_line)
                    lines.append("```")
                    lines.append("</details>")
                    lines.append("")

    # Artifacts
    lines.append("## 📦 Artifacts")
    lines.append("")
    lines.append("The following artifacts may be available for download:")
    for artifact in summary.artifacts:
        lines.append(f"- `{artifact.name}` - Available in GitHub Actions artifacts")
    lines.append("")

    # How to find detailed results
    lines.append("## 📄 Detailed Results")
    lines.append("")
    lines.append(f"Full structured results available at: `.ci/summary.json` in branch `{summary.branch}`")
    lines.append("")
    lines.append("### For Agents")
    lines.append("")
    lines.append("To review failures programmatically:")
    lines.append("```bash")
    lines.append("# Read the JSON summary")
    lines.append("cat .ci/summary.json | jq '.jobs[] | select(.conclusion == \"failure\")'")
    lines.append("")
    lines.append("# Check specific error types")
    lines.append("cat .ci/summary.json | jq '.jobs[].failed_steps[].compilation_errors[]'")
    lines.append("cat .ci/summary.json | jq '.jobs[].failed_steps[].test_failures[]'")
    lines.append("cat .ci/summary.json | jq '.jobs[].failed_steps[].lint_violations[]'")
    lines.append("```")
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
    print("")
    print(f"Statistics:")
    print(f"   - Compilation errors: {summary.total_compilation_errors}")
    print(f"   - Test failures: {summary.total_test_failures}")
    print(f"   - Lint violations: {summary.total_lint_violations}")

    # Exit with appropriate code
    if summary.overall_conclusion == 'failure':
        sys.exit(1)
    else:
        sys.exit(0)


if __name__ == '__main__':
    main()
