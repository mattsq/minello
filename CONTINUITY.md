# Continuity

**Purpose**: Track session-to-session state, decisions, and progress. Ephemeral details live here; durable lessons get promoted to `KNOWLEDGEBASE.md`.

---

## Current Focus

**Goal**: Keep the baseline persistence stack healthy—run the suite regularly, unblock the `claude/fix-ci-cascading-delete` branch, and document any workflow pitfalls discovered while doing so.

**Next 3 Steps**:
1. Watch the next CI run for `claude/fix-ci-cascading-delete` (now using the broad descriptor fallbacks from `minello-0zd`) to confirm SwiftData 15.4 stops crashing.
2. If that run succeeds, start pruning the BoardsRepository debug logging back down to the essentials before we merge the branch.
3. Capture any additional SwiftData predicate/filter quirks we learn from CI in docs/ADRs so they’re easy to reference later.

**Current Risks / Open Questions**:
- Still need ADR scaffolding + workflow docs from the earlier plan (no one has picked this up yet).

---

## Session Log

### 2025-12-22: Instrument fetchColumns fallback for CI logs

**What Changed**:
- When `fetchColumns` falls back to the broad descriptor, log a column store snapshot (with the current board’s column count) so the next CI run reveals whether SwiftData 15.4 is actually persisting the children before filtering.
- Re-ran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` locally (green) to ensure the extra logging doesn’t disturb the suite.

**Decisions Made**:
- Treat the fallback logging as a diagnostic tool for run 20428983617’s successor before attempting another structural change.

**Next Steps**:
- Inspect the next CI run’s logs to see whether any Column rows exist when the fallback triggers; if they do, focus on why `boardID` / relationships aren’t populated, otherwise investigate model insertion.

### 2025-12-22: Broad descriptor fallbacks to stop SwiftData crashes

**What Changed**:
- Removed the descriptor retries that queried `parent?.persistentModelID` / `.id` and restored the broad `FetchDescriptor` fallbacks (with pending changes) so we keep filtering in-memory without relying on unsupported relationship predicates in SwiftData 15.4.
- Reran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` (green) to verify the fallback approach still passes locally.
- Tracked the failure and fix under beads issue `minello-0zd`.

**Decisions Made**:
- Treat relationship-based predicates inside SwiftData `FetchDescriptor`s as unsafe on CI’s toolchain and stick with broader fetches plus manual filtering until we can verify a newer Xcode build.

**Failures Tried / Ruled Out**:
- The attempt to narrow fetches by targeting `persistentModelID` / UUID relationship predicates caused the CI crashes observed in run 20428657755, so that approach is shelved for now.

**Next Steps**:
- Monitor the next CI run for the branch to confirm the crash disappears with the broader fetch strategy and, once green, trim the logging noise.

### 2025-12-22: Descriptor retries for BoardsRepository fetches

**What Changed**:
- Added descriptor retries that re-filter on `parent?.persistentModelID` and `parent?.id` when the stored parent UUID predicate returns zero rows so CI's older SwiftData build still hydrates BoardsRepository columns/cards/checklists.
- Reran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` from `HomeCooked/` (green) to verify the new fetch flow.
- Logged the work under beads issue `minello-lci`.

**Decisions Made**:
- Keep the verbose BoardsRepository logging plus the new descriptor retries until a remote CI run confirms everything is stable, then tighten logging separately.

**Failures Tried / Ruled Out**:
- Attempted to pipe the test run through `xcbeautify`, but the binary isn't installed here, so re-ran `xcodebuild` directly.

**Next Steps**:
- Monitor the next CI run for `claude/fix-ci-cascading-delete` to confirm the descriptor retries unblock the persistence tests before trimming logs.

### 2025-12-22: BoardsRepository UUID fallbacks pushed

**What Changed**:
- Added UUID-based fallbacks (plus descriptor retries) inside `BoardsRepository.fetchColumns/fetchCards/fetchChecklist` so CI’s older SwiftData build can still hydrate relationships when `persistentModelID` comparisons return zero rows, and kept the verbose logging that dumps each candidate’s parent IDs for future debugging.
- Documented the fix in `CHANGELOG.md` and tracked it under beads issue `minello-bbq`.
- Reran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` to ensure the suite stays green before pushing.

**Decisions Made**:
- Ship the verbose logging alongside the fallback logic so we can validate CI’s behavior before trimming noise in a follow-up PR.

**Failures Tried / Ruled Out**:
- None; this change was primarily about landing the already-tested local code so CI can exercise it.

**Next Steps**:
- Monitor the next CI run for `claude/fix-ci-cascading-delete` and plan the logging cleanup once we see a passing run.

### 2025-12-22: Stored parent IDs to stop CI Board.columns crash

**What Changed**:
- Added `boardID`, `columnID`, and `cardID` attributes on the SwiftData models (plus a SchemaV3 migration stage) so repositories can match children to parents without dereferencing brittle relationships; CI crash logs pointed at `Board.columns.getter` right when the relationship fallback tried to re-fetch.
- Updated `BoardsRepository` to set these IDs in `attachRelationships`, filter primarily on the stored IDs, and remove the extra fetch descriptors that were tripping SwiftData 15.4.
- Extended `CardSortKeyMigration` to migrate from SchemaV2→V3 by backfilling the parent IDs, then reran `xcodebuild … test` locally (green) to ensure the new schema stays healthy.

**Decisions Made**:
- Prefer explicit parent UUIDs for CI-critical filtering instead of repeatedly poking at inverse relationships that behave differently between Xcode 15.4 and 16.

**Failures Tried / Ruled Out**:
- Initial test run crashed because the simulator still held a SchemaV2 store; resolved by adding the SchemaV3 stage so SwiftData can migrate automatically.

**Next Steps**:
- Watch the next CI run to confirm the crash is gone and that columns/cards hydrate correctly with the new ID-backed filtering.

### 2025-12-22: Predicate fetches for parent IDs

**What Changed**:
- CI run 20427914086 still crashed while enumerating `Board.columns`, so BoardsRepository now issues direct `FetchDescriptor` predicates against the stored `boardID`/`columnID`/`cardID` fields before falling back to any relationship matching; this keeps SwiftData on 15.4 from instantiating every column just to filter in-memory.
- Reran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` locally to verify the new descriptors work (green).

**Decisions Made**:
- Keep the verbose logging temporarily but narrow each fetch to the exact parent UUID to minimize CI's exposure to buggy relationship hydration.

**Failures Tried / Ruled Out**:
- The earlier boardID storage fix alone wasn't enough—CI still logged `matched=0`, implying the relationship-backed filtering remained brittle even with stored IDs, hence the move to predicate-based fetches.

**Next Steps**:
- Wait for the next CI run to confirm the crash is finally gone; once we see green we can start trimming the debug logging.


### 2025-12-22: BoardsRepository hydration + lint cleanup

**What Changed**:
- Reworked `SwiftDataBoardsRepository.hydrateRelationships` to fetch columns/cards/checklists broadly and filter in-memory using `persistentModelID` + `includePendingChanges` so CI no longer returns empty relationships, then reran `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test` (green locally).
- Ran SwiftFormat (`swiftformat --config HomeCooked/Tooling/swiftformat.yml HomeCooked/`) to clean up the 98 lint violations (import order, indentation, guard syntax, numbering) reported in `.ci/summary`.
- Added targeted logging (`fetchColumns/fetchCards/fetchChecklist`) so the next CI log reveals how many objects were fetched vs. matched for each relationship.
- Expanded the logging to dump every column/card/checklist candidate (IDs + `persistentModelID`s) so CI artifacts tell us exactly which relationships lose their parent pointers.
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
