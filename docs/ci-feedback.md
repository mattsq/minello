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
  "total_compilation_errors": 5,
  "total_test_failures": 3,
  "total_lint_violations": 12,
  "jobs": [
    {
      "job_name": "build",
      "conclusion": "success",
      "total_errors": 0,
      "total_warnings": 0,
      "duration_seconds": null,
      "failed_steps": []
    },
    {
      "job_name": "test",
      "conclusion": "failure",
      "total_errors": 3,
      "total_warnings": 1,
      "duration_seconds": null,
      "failed_steps": [
        {
          "step_name": "test",
          "log_excerpt": ["Testing failed:", "..."],
          "log_tail": ["Last 50 lines...", "..."],
          "error_summary": {
            "test_failures": 3
          },
          "compilation_errors": [],
          "test_failures": [
            {
              "test_name": "HomeCooked.BoardTests",
              "test_case": "testBoardCreation",
              "failure_message": "XCTAssertEqual failed: (Expected) is not equal to (Actual)",
              "file_path": "/path/BoardTests.swift",
              "line_number": 25
            }
          ],
          "lint_violations": []
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

### summary.md Structure (Enhanced)

The markdown file contains:

- Overall CI status (✅ or ❌)
- Run metadata (run ID, commit SHA, branch, PR number)
- **Error Statistics**: Total compilation errors, test failures, lint violations
- Job results with icons and error/warning counts
- **Detailed Failures** section with collapsible `<details>` for:
  - **Compilation Errors**: Up to 10 shown with file:line:column, message, and code context
  - **Test Failures**: Up to 20 shown with test name, location, and failure message
  - **Lint Violations**: Up to 20 shown with file:line:column, rule name, and message
  - **Error Excerpt**: General error context (30 lines)
  - **Log Tail**: Last 50 lines of full log for complete context
- Available artifacts list
- **For Agents** section with example jq commands to parse JSON
- Link to full JSON results

## Usage

### For Claude Code Agents

When working on a PR, agents can inspect CI results by:

1. **Read the summary file** (now with structured errors):
   ```python
   # In your agent code
   import json
   with open('.ci/summary.json') as f:
       ci_results = json.load(f)

   if ci_results['overall_conclusion'] == 'failure':
       print(f"Total errors: {ci_results['total_compilation_errors']} compilation, "
             f"{ci_results['total_test_failures']} tests, "
             f"{ci_results['total_lint_violations']} lint")

       for job in ci_results['jobs']:
           if job['failed_steps']:
               for step in job['failed_steps']:
                   # Access structured compilation errors
                   for error in step.get('compilation_errors', []):
                       print(f"Compilation error at {error['file_path']}:{error['line']}:{error['column']}")
                       print(f"  {error['error_type']}: {error['message']}")

                   # Access structured test failures
                   for failure in step.get('test_failures', []):
                       print(f"Test failure: {failure['test_name']}.{failure['test_case']}")
                       if failure['file_path']:
                           print(f"  Location: {failure['file_path']}:{failure['line_number']}")
                       print(f"  Message: {failure['failure_message']}")

                   # Access structured lint violations
                   for violation in step.get('lint_violations', []):
                       print(f"Lint {violation['severity']} at {violation['file_path']}:{violation['line']}")
                       print(f"  ({violation['rule']}) {violation['message']}")
   ```

2. **Use jq for quick queries**:
   ```bash
   # Get all compilation errors
   cat .ci/summary.json | jq '.jobs[].failed_steps[].compilation_errors[]'

   # Get all test failures
   cat .ci/summary.json | jq '.jobs[].failed_steps[].test_failures[]'

   # Get all files with errors
   cat .ci/summary.json | jq -r '.jobs[].failed_steps[].compilation_errors[].file_path' | sort -u

   # Get error statistics
   cat .ci/summary.json | jq '{compilation: .total_compilation_errors, tests: .total_test_failures, lint: .total_lint_violations}'
   ```

3. **Check if the file exists**:
   ```bash
   git fetch origin your-branch
   git checkout origin/your-branch -- .ci/summary.json
   ```

4. **Read human-friendly summary**:
   ```bash
   cat .ci/summary.md
   ```

### For Humans

1. **View the PR comment** - Updated automatically with each CI run
2. **Browse `.ci/summary.md`** in the PR branch on GitHub
3. **Download artifacts** for detailed logs and test results

## Error Extraction

The feedback script uses **specialized parsers** for different error types, providing structured, verbose output:

### Structured Parsing (Enhanced)

#### 1. Compilation Errors
- **Pattern**: `/path/file.swift:line:column: error: message`
- **Extracted**: File path, line number, column, error type (error/warning), message
- **Context**: 3 lines before + error line + 5 lines after (9 lines total)
- **Example**:
  ```json
  {
    "file_path": "/Users/runner/work/minello/minello/HomeCooked/App/ViewModel.swift",
    "line": 42,
    "column": 15,
    "error_type": "error",
    "message": "Value of type 'String' has no member 'count'",
    "context": ["func updateTitle() {", "...", "..."]
  }
  ```

#### 2. Test Failures
- **Pattern**: `Test Case '-[Target.Class.testMethod]' failed`
- **Extracted**: Test name, test case, failure message, file path, line number
- **Context**: Assertion failure details with exact location
- **Example**:
  ```json
  {
    "test_name": "HomeCooked.BoardTests",
    "test_case": "testBoardCreation",
    "failure_message": "XCTAssertEqual failed: (Expected) is not equal to (Actual)",
    "file_path": "/path/BoardTests.swift",
    "line_number": 25
  }
  ```

#### 3. Lint Violations
- **Pattern**: `/path/file.swift:line:column: error: (rule) message`
- **Extracted**: File path, line, column, rule name, severity (error/warning), message
- **Example**:
  ```json
  {
    "file_path": "/Users/runner/work/minello/minello/HomeCooked/App/HomeCookedApp.swift",
    "line": 1,
    "column": 1,
    "rule": "sortImports",
    "severity": "error",
    "message": "Sort import statements alphabetically"
  }
  ```

### General Error Fallback

For non-structured errors, the script still uses pattern matching:
- Lines containing: `error:`, `failed:`, `failure:`, `fatal:`, `exception:`
- Build/test failure markers: `** BUILD FAILED **`, `** TEST FAILED **`
- Warning symbols that mention errors: `⚠️ ... error`
- Emoji indicators: `❌`

### Output Levels

Each failed step now includes **four levels** of detail:

1. **Error Summary**: Statistics (e.g., "5 compilation errors, 2 warnings")
2. **Structured Errors**: Parsed errors with file:line:column (up to 10-20 per type)
3. **Error Excerpt**: 30 lines of error-focused context
4. **Log Tail**: Last 50 lines of the full log for complete context

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
