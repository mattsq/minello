# Continuity

**Purpose**: Track session-to-session state, decisions, and progress. Ephemeral details live here; durable lessons get promoted to `KNOWLEDGEBASE.md`.

---

## Current Focus

**Goal**: Keep the baseline persistence stack healthy—run the suite regularly, unblock the `claude/fix-ci-cascading-delete` branch, and document any workflow pitfalls discovered while doing so.

**Next 3 Steps**:
1. Monitor the next CI run for `claude/fix-ci-cascading-delete` to verify the relationship hydration + formatting fixes stick.
2. Remove the extra BoardsRepository logging once CI stays green for a full run.
3. Fold any repeatable SwiftData quirks (like predicate filtering limits) into ADRs or workflow docs as they emerge.

**Current Risks / Open Questions**:
- Still need ADR scaffolding + workflow docs from the earlier plan (no one has picked this up yet).

---

## Session Log

### 2025-12-22: BoardsRepository hydration + lint cleanup

**What Changed**:
- Reworked `SwiftDataBoardsRepository.hydrateRelationships` to fetch columns/cards/checklists broadly and filter in-memory using `persistentModelID` + `includePendingChanges` so CI no longer returns empty relationships, then reran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` (green locally).
- Ran SwiftFormat (`swiftformat --config HomeCooked/Tooling/swiftformat.yml HomeCooked/`) to clean up the 98 lint violations (import order, indentation, guard syntax, numbering) reported in `.ci/summary`.
- Added targeted logging (`fetchColumns/fetchCards/fetchChecklist`) so the next CI log reveals how many objects were fetched vs. matched for each relationship.
- Logged the change in `CHANGELOG.md` and tracked the work in beads issue `minello-6rk`.

**Decisions Made**:
- Treat SwiftData relationship predicates as unreliable in CI for now; prefer fetching supersets and filtering manually inside the repository for determinism.
- Keep the temporary logging inside BoardsRepository while CI stabilizes so we can inspect board/column counts directly in the artifact logs.

**Failures Tried / Ruled Out**:
- Attempted to run `swiftlint lint --config Tooling/swiftlint.yml --strict` directly; SwiftLint still reports “No lintable files found,” so CI continues to rely on SwiftFormat until we revisit the config root issue separately.

**Next Steps**:
- Wait for CI run 20425000604’s successor to confirm the fetch + formatting fixes, then clean up the extra logging once we see a full green run.

### 2025-12-22: CI cascading delete + lint fix

**What Changed**:
- Investigated `.ci/summary.json` failure from GH run 20420099081 showing `testCascadingDelete` breakage plus 152 lint hits in `BoardDetailView`.
- Updated `SwiftDataBoardsRepository.delete` to manually cascade columns/cards before removing a board so SwiftData can't leave orphan rows.
- Re-formatted `BoardDetailView` (import order, operator spacing, preview indentation) to satisfy SwiftFormat.
- Logged the SwiftData cascade quirk in `KNOWLEDGEBASE.md` for future reference.

**Decisions Made**:
- Trust repository-level clean-up over relying on SwiftData's `.cascade` rules until we understand why they are skipped in CI.

**Failures Tried / Ruled Out**:
- Attempted to rely solely on `modelContext.delete(board)`; CI evidence showed it leaves columns/cards behind, so manual cleanup is required.

**Next Steps**:
- Monitor the next CI run for the same test to ensure manual cascading holds.
- Keep watching for other SwiftData lifecycle inconsistencies that deserve docs/tests.

### 2025-12-21: Initial agent memory system setup

**What Changed**:
- Created `KNOWLEDGEBASE.md` with comprehensive project knowledge (TL;DR, project map, build/test commands, conventions, architecture decisions, workflows, pitfalls, glossary)
- Created `CONTINUITY.md` (this file) for session tracking
- Planned ADR scaffolding, PR template, agent workflow guide

**Decisions Made**:
- Use `KNOWLEDGEBASE.md` for durable knowledge (how-to, conventions, architecture)
- Use `CONTINUITY.md` for session state (current focus, recent changes, decisions)
- Keep both files concise; move long-form notes to `notes/sessions/`
- Integrate memory upkeep into PR template (gentle nudges, not enforcement)

**Failures Tried / Ruled Out**:
- None yet

**Next Steps**:
- Create `docs/adr/` with README and template
- Update `CLAUDE.md` to add memory system section at top
- Create `.github/pull_request_template.md` with memory upkeep checklist
- Create `docs/agent-workflow.md` with session start/end workflow
- Create `notes/sessions/` structure for optional long-form notes
- Update `README.md` to link to agent workflow docs

### 2025-12-22: Test health check + workflow note

**What Changed**:
- Ran `xcodebuild -scheme HomeCooked test` successfully; suite remains green.
- Hit a "does not contain an Xcode project" error when running tests from repo root, so documented that commands must run inside `HomeCooked/` (or pass `-project`) in `KNOWLEDGEBASE.md`.

**Decisions Made**:
- Treat these periodic test runs as part of baseline health-check work—log any workflow gotchas we find even if the code needs no changes.

**Failures Tried / Ruled Out**:
- Attempted to execute `xcodebuild` from repo root; fails because `HomeCooked.xcodeproj` lives in the `HomeCooked/` subdirectory.

**Next Steps**:
- Future session: resume the outstanding ADR scaffolding + agent workflow docs from the previous session log.

---

## How to Use This File

**At session start**:
1. Read "Current Focus" to understand what's in flight
2. Scan recent session log entries (top 2-3) for context
3. Check "Current Risks / Open Questions" for blockers

**During session**:
- Update "Current Focus" if goals/steps change
- Add to "Current Risks / Open Questions" as they arise

**At session end**:
1. Add new session log entry (date, what changed, decisions, failures, next steps)
2. Update "Current Focus" with new goal/next steps
3. Promote durable lessons to `KNOWLEDGEBASE.md` (architecture, conventions, pitfalls)
4. Archive old entries if log grows beyond ~10 sessions (move to `notes/sessions/YYYY-MM.md`)

**When to create a session note in `notes/sessions/`**:
- Deep investigation/research that shouldn't clutter CONTINUITY
- Long debugging session with multiple attempts
- Complex refactoring with step-by-step reasoning
- Architecture exploration / design spikes

**When to promote to KNOWLEDGEBASE**:
- Discovered a recurring pitfall (add to "Pitfalls / Sharp Edges")
- Made an architectural decision (add to "Architecture & Decisions" + create ADR)
- Established a new convention (add to "Conventions")
- Learned a new workflow pattern (add to "Common Workflows")
