# CI Feedback System

This document describes the "Pattern A" CI feedback system implemented for this repository, which allows Claude Code agents and humans to inspect CI outcomes without calling the GitHub Actions API.

## Overview

When a pull request is opened or updated, CI runs normally and then generates a comprehensive feedback bundle that is committed back to the PR branch. This enables easy inspection of CI results by:

1. **Agents**: Can read `.ci/summary.json` directly from the branch
2. **Humans**: Can view PR comments and browse `.ci/summary.md` in the branch

## How It Works

### 1. CI Execution

The CI workflow (`.github/workflows/ci.yml`) runs three main jobs:

- **build**: Validates and builds the Xcode project
- **test**: Runs unit tests with code coverage
- **lint**: Runs SwiftFormat and SwiftLint checks

Each job captures its output to log files using `tee`, even when commands fail (via `continue-on-error: true`).

### 2. Log Capture

All CI steps that might fail have their output captured:

```bash
set -o pipefail
xcodebuild build ... 2>&1 | tee ci-logs/build.log
```

These logs are uploaded as workflow artifacts so they're available to the feedback job.

### 3. Feedback Generation

After all jobs complete, the `ci_feedback` job runs (only on PRs):

1. Downloads all log artifacts
2. Runs `scripts/ci_feedback.py` to parse logs and generate:
   - `.ci/summary.json` - Structured data for agents
   - `.ci/summary.md` - Human-readable summary
3. Commits these files to the PR branch
4. Posts/updates a PR comment with the markdown summary

### 4. Loop Prevention

To prevent infinite workflow loops:

- The workflow has `paths-ignore: ['.ci/**']` so changes to `.ci/` don't trigger CI
- Commits are made with `[skip ci]` in the message as an extra guard
- The `ci_feedback` job only runs on `pull_request` events, not pushes to main

## File Formats

### summary.json Structure

```json
{
  "run_id": "12345",
  "run_url": "https://github.com/owner/repo/actions/runs/12345",
  "sha": "abc123...",
  "branch": "my-feature-branch",
  "pr_number": "42",
  "overall_conclusion": "failure",
  "timestamp": "2025-01-04T12:34:56Z",
  "jobs": [
    {
      "job_name": "build",
      "conclusion": "success",
      "duration_seconds": null,
      "failed_steps": []
    },
    {
      "job_name": "test",
      "conclusion": "failure",
      "duration_seconds": null,
      "failed_steps": [
        {
          "step_name": "test",
          "log_excerpt": [
            "Testing failed:",
            "❌ TestCase.testFeature() failed",
            "Expected true, got false"
          ]
        }
      ]
    }
  ],
  "artifacts": [
    {"name": "test-results", "path": ".ci/test-results"},
    {"name": "failed-snapshots", "path": ".ci/failed-snapshots"}
  ]
}
```

### summary.md Structure

The markdown file contains:

- Overall CI status (✅ or ❌)
- Run metadata (run ID, commit SHA, branch, PR number)
- Job results with icons
- Failed jobs with step details and error excerpts
- Top errors section (max ~30 lines of key errors)
- Available artifacts list
- Link to full JSON results

## Usage

### For Claude Code Agents

When working on a PR, agents can inspect CI results by:

1. **Read the summary file**:
   ```python
   # In your agent code
   import json
   with open('.ci/summary.json') as f:
       ci_results = json.load(f)

   if ci_results['overall_conclusion'] == 'failure':
       for job in ci_results['jobs']:
           if job['failed_steps']:
               for step in job['failed_steps']:
                   print(f"Error in {job['job_name']}/{step['step_name']}:")
                   for line in step['log_excerpt']:
                       print(f"  {line}")
   ```

2. **Check if the file exists**:
   ```bash
   git fetch origin your-branch
   git checkout origin/your-branch -- .ci/summary.json
   ```

3. **Read human-friendly summary**:
   ```bash
   cat .ci/summary.md
   ```

### For Humans

1. **View the PR comment** - Updated automatically with each CI run
2. **Browse `.ci/summary.md`** in the PR branch on GitHub
3. **Download artifacts** for detailed logs and test results

## Error Extraction

The feedback script extracts errors using multiple patterns:

- Lines containing: `error:`, `failed:`, `failure:`, `fatal:`, `exception:`
- Build/test failure markers: `** BUILD FAILED **`, `** TEST FAILED **`
- Warning symbols that mention errors: `⚠️ ... error`
- Emoji indicators: `❌`

For each error, it includes context (1 line before, error line, 2 lines after) up to a maximum of ~10 lines per failed step.

## Workflow Triggers

The CI feedback system:

- ✅ **Runs on**: `pull_request` events (opened, synchronize, reopened)
- ✅ **Runs on**: Manual `workflow_dispatch`
- ❌ **Skips on**: Pushes to main/master
- ❌ **Skips on**: Changes only to `.ci/**`

## Troubleshooting

### Feedback not appearing

1. Check that the `ci_feedback` job ran (should show in Actions tab)
2. Verify it's a pull request (doesn't run on direct pushes)
3. Check for permission errors in the job logs

### Loop detected

If you see infinite CI runs:

1. Verify `paths-ignore` includes `.ci/**`
2. Check commit messages include `[skip ci]`
3. Ensure `ci_feedback` job only runs on `github.event_name == 'pull_request'`

### Missing error excerpts

If logs are captured but errors aren't shown:

1. Check that logs were uploaded as artifacts
2. Verify error patterns in `scripts/ci_feedback.py` match your error format
3. Add custom patterns if needed for your specific errors

## Validation

To test the system:

1. **Create a failing PR**:
   ```bash
   # Introduce a syntax error or failing test
   git checkout -b test-ci-feedback
   # Make changes that will fail CI
   git commit -am "test: intentional failure"
   git push origin test-ci-feedback
   ```

2. **Open PR** and wait for CI to complete

3. **Verify**:
   - [ ] CI runs and fails
   - [ ] `.ci/summary.json` appears in the branch
   - [ ] `.ci/summary.md` appears in the branch
   - [ ] PR comment is posted/updated with error details
   - [ ] Error excerpts are pulled from actual logs (not generic)
   - [ ] Second push doesn't trigger duplicate CI runs

4. **Check content**:
   ```bash
   git fetch origin test-ci-feedback
   git show origin/test-ci-feedback:.ci/summary.json
   git show origin/test-ci-feedback:.ci/summary.md
   ```

## Implementation Files

- **Workflow**: `.github/workflows/ci.yml` - Main CI workflow with feedback job
- **Script**: `scripts/ci_feedback.py` - Python script that generates summaries
- **Output**: `.ci/summary.json` - Structured JSON results (committed to PR branch)
- **Output**: `.ci/summary.md` - Human-readable markdown (committed to PR branch)
- **Docs**: `docs/ci-feedback.md` - This file

## Advanced Usage

### Custom Error Patterns

To add custom error patterns, edit `scripts/ci_feedback.py`:

```python
class LogParser:
    ERROR_PATTERNS = [
        # ... existing patterns ...
        re.compile(r'YourCustomErrorPattern', re.MULTILINE),
    ]
```

### Extracting More Context

To increase the number of context lines around errors:

```python
# In LogParser.extract_errors()
start = max(0, i - 2)  # More lines before
end = min(len(lines), i + 5)  # More lines after
```

### Adding Custom Metrics

To track custom metrics in the JSON:

1. Modify the `CISummary` dataclass in `scripts/ci_feedback.py`
2. Extract metrics in the `parse_job_logs()` function
3. Include in the markdown template in `write_markdown_summary()`

## Security Considerations

- Uses `GITHUB_TOKEN` for authentication (scoped to repo)
- Bot commits use `github-actions[bot]` identity
- No secrets are logged or included in feedback files
- Artifacts are retained for only 7-14 days
- PR comments are public (don't include sensitive error details)
