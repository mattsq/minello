# CI/CD Feedback Logs: Comprehensive Plan

**Issue**: minello-8ig
**Date**: 2025-12-21
**Goal**: Ensure CI logs are ALWAYS generated for agent inspection, regardless of CI success/failure, without artificially marking failed CI as successful.

---

## Executive Summary

The CI/CD feedback workflow must reliably generate parseable logs that agents can inspect to understand build/test/lint failures. This plan ensures:

1. **Logs always generated** - Even when jobs fail catastrophically
2. **True CI status preserved** - Failed builds/tests/lint properly fail the CI
3. **Agent-friendly output** - Structured JSON + human-readable markdown
4. **Resilient to partial failures** - Individual artifact download failures don't block log generation

---

## Current State Analysis

### What Works Well ✅

1. **Log Upload**: All jobs (build, test, lint) upload logs with `if: always()`
   - `build.log`, `test.log`, `swiftformat.log`, `swiftlint.log`
   - This ensures logs exist even when steps fail

2. **Artifact Retention**: Logs retained for 7 days (14 for snapshots)
   - Sufficient for agent debugging cycles

3. **Structured Feedback**: `ci_feedback.py` generates both JSON and markdown
   - JSON for programmatic parsing
   - Markdown for human/PR comments

4. **Separation of Concerns**:
   - Jobs (build/test/lint) → do work
   - `ci_feedback` job → generate reports
   - `status` job → enforce CI pass/fail

5. **Continue-on-error for validation**: Some steps use `continue-on-error: true` to allow diagnostics even when validation fails

### Current Limitations ⚠️

1. **PR-Only Feedback**: `ci_feedback` job only runs on PRs
   - Regular branch pushes don't get structured feedback
   - Agents working on non-PR branches can't access `.ci/summary.json`

2. **Artifact Download Failures**: If artifact downloads fail, feedback generation continues but may be incomplete
   - Uses `continue-on-error: true` but doesn't track what's missing

3. **No Fallback Mechanisms**: If `ci_feedback.py` crashes, no logs are generated
   - Should have basic fallback that generates minimal summary

4. **Log Size Limits**: No truncation/pagination for very large logs
   - Could overwhelm agents with 100K+ line logs

5. **Timing Dependency**: `ci_feedback` depends on job completion
   - If jobs are cancelled, feedback may not run

---

## Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR1 | Logs uploaded for build, test, lint even on failure | P0 (Critical) |
| FR2 | CI status reflects actual success/failure | P0 (Critical) |
| FR3 | Feedback generated for all pushes (not just PRs) | P1 (High) |
| FR4 | Structured JSON summary always created | P1 (High) |
| FR5 | Markdown summary always created | P2 (Medium) |
| FR6 | Missing artifacts don't block feedback generation | P1 (High) |
| FR7 | Large logs truncated intelligently | P2 (Medium) |
| FR8 | Feedback script failures don't lose all data | P1 (High) |

### Non-Functional Requirements

- **Reliability**: 99.9% log generation success rate
- **Performance**: Feedback generation < 30s
- **Storage**: Logs < 10MB per run (compressed)
- **Accessibility**: Logs readable by both humans and agents

---

## Proposed Solution Architecture

### Principle: Separation of Concerns

```
┌─────────────────────────────────────────────────────┐
│  PHASE 1: CI Execution                              │
│  ├─ build job   → runs xcodebuild                   │
│  ├─ test job    → runs tests                        │
│  ├─ lint job    → runs swiftformat/swiftlint        │
│  └─ ALL jobs    → upload logs with if: always()     │
└─────────────────────────────────────────────────────┘
              ↓ (needs: [build, test, lint])
┌─────────────────────────────────────────────────────┐
│  PHASE 2: Feedback Generation (ALWAYS RUNS)         │
│  ├─ Download artifacts (continue-on-error)          │
│  ├─ Generate summary.json (with fallback)           │
│  ├─ Generate summary.md (with fallback)             │
│  ├─ Commit to branch (for non-PR pushes too)        │
│  └─ Post PR comment (if PR)                         │
└─────────────────────────────────────────────────────┘
              ↓ (parallel, independent)
┌─────────────────────────────────────────────────────┐
│  PHASE 3: Status Enforcement (REAL CI RESULT)       │
│  ├─ Check build.result                              │
│  ├─ Check test.result                               │
│  ├─ Check lint.result                               │
│  └─ exit 1 if any failed → CI FAILS ❌              │
└─────────────────────────────────────────────────────┘
```

**Key Insight**: Feedback generation is INDEPENDENT of status enforcement.
- Feedback job uses `if: always()` (no PR restriction)
- Status job uses `if: always()` and enforces real results
- Neither job affects the other's execution

---

## Detailed Implementation Plan

### 1. Ensure Log Upload Robustness

**Current State**: ✅ Already using `if: always()` on upload steps

**Enhancement**: Add explicit error handling and metadata

```yaml
- name: Upload build logs
  if: always()  # ✅ Already correct
  uses: actions/upload-artifact@v4
  with:
    name: build-logs
    path: ci-logs/*.log
    retention-days: 7
    if-no-files-found: warn  # Changed from 'ignore' to 'warn'
```

**Changes**:
- Use `if-no-files-found: warn` instead of `ignore` to surface issues
- Add step to create `.ci-logs/metadata.json` with job status before upload

### 2. Expand Feedback Job to All Pushes

**Current State**: Only runs on PRs (`if: always() && github.event_name == 'pull_request'`)

**Proposed**:
```yaml
ci_feedback:
  name: CI Feedback
  runs-on: ubuntu-latest
  needs: [build, test, lint]
  if: always()  # Remove PR restriction
  permissions:
    contents: write
    pull-requests: write
```

**Rationale**:
- Agents working on feature branches need feedback too
- `.ci/summary.json` should exist on all branches
- PR comment still conditional on PR context

### 3. Add Fallback Feedback Generation

**Current State**: If `ci_feedback.py` fails, no output

**Proposed**: Add shell-based fallback that generates minimal summary

```yaml
- name: Generate CI feedback
  id: feedback_script
  continue-on-error: true
  env:
    BUILD_RESULT: ${{ needs.build.result }}
    TEST_RESULT: ${{ needs.test.result }}
    LINT_RESULT: ${{ needs.lint.result }}
  run: |
    python3 scripts/ci_feedback.py \
      artifacts \
      .ci \
      "${{ github.run_id }}" \
      "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}" \
      "${{ github.sha }}" \
      "${{ github.head_ref || github.ref_name }}" \
      "${{ github.event.pull_request.number || 'none' }}"

- name: Fallback feedback generation
  if: always() && steps.feedback_script.outcome != 'success'
  run: |
    mkdir -p .ci

    # Generate minimal JSON summary
    cat > .ci/summary.json <<'EOF'
    {
      "run_id": "${{ github.run_id }}",
      "run_url": "${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}",
      "sha": "${{ github.sha }}",
      "branch": "${{ github.head_ref || github.ref_name }}",
      "pr_number": "${{ github.event.pull_request.number || null }}",
      "overall_conclusion": "unknown",
      "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
      "jobs": [
        {"job_name": "build", "conclusion": "${{ needs.build.result }}", "failed_steps": []},
        {"job_name": "test", "conclusion": "${{ needs.test.result }}", "failed_steps": []},
        {"job_name": "lint", "conclusion": "${{ needs.lint.result }}", "failed_steps": []}
      ],
      "artifacts": [],
      "error": "Primary feedback script failed; this is a fallback summary"
    }
    EOF

    # Generate minimal markdown summary
    cat > .ci/summary.md <<'EOF'
    # ⚠️ CI Feedback (Fallback)

    **Run**: [${{ github.run_id }}](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})
    **Commit**: `${{ github.sha }}`
    **Branch**: `${{ github.head_ref || github.ref_name }}`

    ## Job Results

    - Build: ${{ needs.build.result }}
    - Test: ${{ needs.test.result }}
    - Lint: ${{ needs.lint.result }}

    ⚠️ The primary feedback script failed. This is a minimal fallback summary.
    Check the workflow run for detailed logs.

    ---
    <!-- ci-feedback -->
    EOF

    echo "✓ Generated fallback feedback"
```

### 4. Improve Artifact Download Resilience

**Current State**: Uses `continue-on-error: true` on downloads

**Enhancement**: Track which artifacts were successfully downloaded

```yaml
- name: Download artifacts and track availability
  run: |
    mkdir -p artifacts

    # Function to download with tracking
    download_artifact() {
      local name=$1
      echo "Downloading $name..."
      if gh run download ${{ github.run_id }} -n "$name" -D "artifacts/$name" 2>/dev/null; then
        echo "$name: available" >> artifacts/manifest.txt
        echo "✓ $name"
      else
        echo "$name: missing" >> artifacts/manifest.txt
        echo "⚠️ $name not available"
      fi
    }

    download_artifact "build-logs"
    download_artifact "test-logs"
    download_artifact "lint-logs"
    download_artifact "test-results"
    download_artifact "failed-snapshots"

    cat artifacts/manifest.txt
  env:
    GH_TOKEN: ${{ github.token }}
  continue-on-error: false  # Should always succeed
```

**Alternative**: Keep current approach but enhance `ci_feedback.py` to document missing artifacts

### 5. Enhance ci_feedback.py Script

**Enhancements**:

```python
# 1. Accept artifact manifest to document what's missing
def load_artifact_manifest(artifacts_dir: Path) -> Dict[str, bool]:
    """Load manifest of available artifacts"""
    manifest_path = artifacts_dir / "manifest.txt"
    manifest = {}

    if manifest_path.exists():
        with open(manifest_path, 'r') as f:
            for line in f:
                name, status = line.strip().split(': ')
                manifest[name] = (status == 'available')

    return manifest

# 2. Add log truncation for large files
def extract_errors(log_content: str, max_lines: int = 10, max_size: int = 100_000) -> List[str]:
    """Extract errors with size limits"""
    if len(log_content) > max_size:
        # Take first 50KB and last 50KB for very large logs
        header = log_content[:50_000]
        footer = log_content[-50_000:]
        log_content = header + "\n\n[... truncated ...]\n\n" + footer

    # ... rest of existing logic

# 3. Add structured error summary
@dataclass
class ErrorSummary:
    """High-level error categorization for agents"""
    category: str  # build_error, test_failure, lint_warning, parse_error
    count: int
    representative_example: str

def categorize_errors(jobs: List[JobResult]) -> List[ErrorSummary]:
    """Categorize errors for agent consumption"""
    # Group similar errors, provide high-level summary
    # Makes it easier for agents to understand failure patterns
```

### 6. Preserve True CI Status

**Current State**: ✅ `status` job correctly fails when any job fails

**Verification**: No changes needed, but document the pattern clearly

```yaml
status:
  name: CI Status
  runs-on: ubuntu-latest
  needs: [build, test, lint]
  if: always()

  steps:
    - name: Check job results
      run: |
        # THIS STEP ENFORCES THE REAL CI STATUS
        # It is INDEPENDENT of the ci_feedback job
        # ci_feedback generates logs; this enforces pass/fail

        if [[ "${{ needs.build.result }}" != "success" ]]; then
          echo "❌ Build failed"
          exit 1  # CI FAILS
        fi
        if [[ "${{ needs.test.result }}" != "success" ]]; then
          echo "❌ Tests failed"
          exit 1  # CI FAILS
        fi
        if [[ "${{ needs.lint.result }}" != "success" ]]; then
          echo "❌ Lint failed"
          exit 1  # CI FAILS
        fi
        echo "✅ All CI checks passed!"
```

**Key Point**: This job is the source of truth for CI status. It runs in parallel with `ci_feedback` and is completely independent.

---

## Implementation Phases

### Phase 1: Critical Fixes (P0)
**Goal**: Ensure logs always generated with correct CI status

1. ✅ Verify log upload uses `if: always()` (already done)
2. ✅ Verify `status` job enforces real results (already done)
3. Add fallback feedback generation
4. Test on intentionally failing build

**Acceptance**:
- Failing build produces logs + summary
- CI correctly reports failure
- `.ci/summary.json` exists on branch

### Phase 2: Robustness (P1)
**Goal**: Handle edge cases and all branch types

1. Remove PR restriction from `ci_feedback` job
2. Update branch commit logic to use `github.head_ref || github.ref_name`
3. Add artifact manifest tracking
4. Enhance `ci_feedback.py` with truncation

**Acceptance**:
- Non-PR pushes generate feedback
- Missing artifacts documented but don't block
- Large logs truncated intelligently

### Phase 3: Agent Experience (P2)
**Goal**: Make logs maximally useful for agents

1. Add error categorization to `ci_feedback.py`
2. Generate `errors-summary.txt` with top 10 issues
3. Add links to relevant documentation for common errors
4. Add example fix suggestions

**Acceptance**:
- Agents can quickly understand failure root cause
- Structured error data easy to parse
- Reduces agent token usage on log parsing

---

## Testing Strategy

### Test Cases

| Test ID | Scenario | Expected Outcome |
|---------|----------|------------------|
| T1 | All jobs succeed | ✅ CI passes, logs uploaded, feedback generated |
| T2 | Build fails | ❌ CI fails, build logs uploaded, feedback shows build error |
| T3 | Test fails | ❌ CI fails, test logs uploaded, feedback shows test failures |
| T4 | Lint fails | ❌ CI fails, lint logs uploaded, feedback shows lint errors |
| T5 | Multiple jobs fail | ❌ CI fails, all logs uploaded, feedback shows all errors |
| T6 | Job cancelled | 🚫 CI cancelled, partial logs uploaded, feedback generated |
| T7 | Artifact download fails | ⚠️ Feedback generated with missing artifact note |
| T8 | ci_feedback.py crashes | ⚠️ Fallback generates minimal summary |
| T9 | Non-PR push | ✅ Feedback generated, committed to branch |
| T10 | PR push | ✅ Feedback generated, committed + PR comment |

### Manual Testing Procedure

```bash
# Test 1: Intentional build failure
# - Add syntax error to Swift file
# - Push to branch
# - Verify: CI fails, logs exist, summary.json created

# Test 2: Intentional test failure
# - Add failing test assertion
# - Push to branch
# - Verify: CI fails, test logs show failure, summary categorizes error

# Test 3: Intentional lint failure
# - Add code violating SwiftLint rules
# - Push to branch
# - Verify: CI fails, lint logs show violations, summary lists them

# Test 4: Script failure simulation
# - Temporarily break ci_feedback.py (syntax error)
# - Push to branch
# - Verify: Fallback generates minimal summary, CI status still enforced

# Test 5: Non-PR push
# - Push to feature branch (not PR)
# - Verify: .ci/summary.json exists on branch, no PR comment attempted
```

---

## Rollback Plan

If issues arise with the new approach:

1. **Quick rollback**: Revert `ci_feedback` job to PR-only
2. **Disable fallback**: Remove fallback step if causing issues
3. **Emergency**: Comment out `ci_feedback` job entirely; logs still uploaded

**Safety**: All changes preserve existing log upload behavior

---

## Monitoring & Success Metrics

### Metrics to Track

1. **Log generation rate**: % of CI runs with `.ci/summary.json`
   - Target: 99.9%

2. **Feedback timeliness**: Time from job completion to feedback commit
   - Target: < 30 seconds

3. **Artifact availability**: % of expected artifacts successfully downloaded
   - Target: > 95%

4. **Script success rate**: % of runs where `ci_feedback.py` succeeds
   - Target: > 98% (fallback for remaining 2%)

### How to Monitor

- Query GitHub Actions API for artifact counts
- Parse `.ci/summary.json` to check for fallback usage
- Track CI duration (ensure feedback doesn't add significant time)

---

## Future Enhancements (Out of Scope)

1. **Real-time log streaming**: Agents could watch logs as jobs run
2. **Incremental feedback**: Generate partial summaries as jobs complete
3. **ML-based error clustering**: Group similar errors across runs
4. **Auto-fix suggestions**: Integrate with known issue database
5. **Slack/Discord notifications**: Post summaries to team channels

---

## Conclusion

This plan ensures CI logs are ALWAYS generated for agent inspection while preserving the integrity of CI status reporting. The key principles are:

1. **Separation of concerns**: Log generation ≠ Status enforcement
2. **Defense in depth**: Fallbacks ensure minimal output even on failures
3. **Always use `if: always()`**: For log uploads and feedback generation
4. **Independent status job**: Single source of truth for pass/fail
5. **Structured output**: JSON for agents, Markdown for humans

By following this plan, we achieve:
- ✅ Logs always generated (even on catastrophic failure)
- ✅ CI status accurately reflects build/test/lint results
- ✅ Agents can reliably inspect failures
- ✅ Resilient to partial failures
- ✅ Works for PR and non-PR workflows

**Next Steps**: Implement Phase 1 (critical fixes) and validate with intentional failures.
