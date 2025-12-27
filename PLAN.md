# HomeCooked Implementation Plan

This document tracks implementation tickets for the HomeCooked project. Each ticket lists Goal, Constraints, Files, Deliverables, and Acceptance criteria with commands.

## Ticket Status Legend

- ✅ Complete
- 🚧 In Progress
- ⬜ Not Started

---

## Tickets

### 0) Project preflight & app skeleton ✅

**Goal**: Add scripts/preflight.sh and wire make preflight. Autogenerate iOS app skeleton if missing; verify toolchains.

**Constraints**: Works on Linux & macOS; prints one-line summary; exits non-zero on failure.

**Files**: Scripts/preflight.sh, Makefile, DEVELOPMENT.md, .swift-version, .xcode-version.

**Deliverables**: Passing preflight on fresh clone and on a broken tree (after autofix).

**Acceptance**:
- `make preflight` succeeds on Linux (no iOS build).
- On macOS, `make preflight && xcodebuild -list` succeeds.

**Status**: ✅ Complete

---

### 1) Domain models & validators ✅

**Goal**: Implement Domain structs + helpers (ID factories, tag sanitizer, checklist utilities).

**Constraints**: Pure Swift; no Foundation types in helpers beyond Date/UUID.

**Files**: Packages/Domain/...

**Deliverables**: Compiles + unit tests.

**Acceptance**: `make test-linux` green; tests under DomainTests/*.

**Status**: ✅ Complete

---

### 2) Repository interfaces + GRDB v1 (boards/columns/cards) ✅

**Goal**: Define repos + implement GRDB schema v1 with indices; CRUD and query helpers.

**Constraints**: Foreign keys ON; migrations idempotent; use ISO8601 dates.

**Files**: PersistenceInterfaces/*, PersistenceGRDB/*

**Deliverables**: GRDB repo + migration v1 + contract tests.

**Acceptance**:
- `swift test --filter BoardsRepositoryContractTests` passes (Linux).
- `hc-migrate --dry-run` prints applied migrations.

**Status**: ✅ Complete

---

### 3) Reorder service (midpoint + idle normalization) ✅

**Goal**: Implement CardReorderService in UseCases; no persistence details.

**Constraints**: Thread-safe; property tests around extremes (duplicate keys, large deltas).

**Files**: UseCases/Reorder/*

**Deliverables**: Unit + property tests.

**Acceptance**: `swift test --filter ReorderTests` passes (Linux).

**Status**: ✅ Complete

---

### 4) Trello importer + CLI (hc-import) ✅

**Goal**: Decode Trello JSON; map to Domain; write via repo; print summary.

**Constraints**: Idempotent (dedupe by name+createdAt heuristic); tolerate variant exports.

**Files**: ImportExport/Trello/*, CLIs/hc-import/*, Tests/Fixtures/trello_*.json

**Deliverables**: CLI + unit tests with fixtures.

**Acceptance**:
- `swift run hc-import Tests/Fixtures/trello_minimal.json --db /tmp/hc.db` exits 0.
- `swift test --filter TrelloImporterTests` passes.

**Status**: ✅ Complete

---

### 5) Backup/export & restore + CLI (hc-backup) ✅

**Goal**: Versioned JSON export and merge/overwrite restore.

**Constraints**: Stable schema; progress logging.

**Files**: ImportExport/Backup/*, CLIs/hc-backup/*

**Deliverables**: Round-trip tests.

**Acceptance**: `swift test --filter BackupRoundTripTests` passes.

**Status**: ✅ Complete

---

### 6) Lists (PersonalList) & checklist component (Linux logic) ✅

**Goal**: Checklist operations (toggle all, reorder, quantities/units) in UseCases; repo CRUD for lists.

**Constraints**: Bulk actions confirm when >10 items (policy only; UI later).

**Files**: UseCases/Checklist/*, PersistenceInterfaces/ListsRepository.swift, PersistenceGRDB/Lists/*

**Deliverables**: Contract tests for Lists repo.

**Acceptance**: `swift test --filter ListsRepositoryContractTests`.

**Status**: ✅ Complete

---

### 7) iOS UI skeleton (Boards/Columns/Cards) ✅

**Goal**: SwiftUI skeleton screens; wire to repos via DI (use GRDB or SwiftData via feature flag).

**Constraints**: Accessibility labels; drag/drop hooks; haptics on drop.

**Files**: App/UI/*, App/DI/*

**Deliverables**: Buildable app; smoke UI tests.

**Acceptance**: On macOS: `make test-macos` green; snapshot tests recorded with RECORD_SNAPSHOTS=1.

**Status**: ✅ Complete

---

### 8) SwiftData adapter (Apple-only) ✅

**Goal**: PersistenceSwiftData that conforms to repos, mapping Domain ↔ SwiftData models.

**Constraints**: Prefer explicit deletes over .cascade; unidirectional relationships.

**Files**: App/PersistenceSwiftData/*

**Deliverables**: Contract tests run also against SwiftData (macOS).

**Acceptance**: macOS test matrix runs contract suite for GRDB and SwiftData.

**Status**: ✅ Complete

---

### 9) CloudKit private sync (optional) ✅

**Goal**: Implement SyncCloudKit behind SyncInterfaces; private DB only; LWW conflicts.

**Constraints**: App works offline; status UI.

**Files**: Packages/SyncCloudKit/*, App/UI/Settings/SyncStatusView.swift

**Deliverables**: Manual harness + unit tests mapping statuses.

**Acceptance**: macOS CI runs sync unit tests; manual doc SyncManualTests.md.

**Status**: ✅ Complete

---

### 10) CloudKit sharing per Board (optional) ✅

**Goal**: Share a Board and children; revoke; badge participants count.

**Constraints**: Board-scoped sharing only.

**Files**: App/UI/BoardDetail/Share/*

**Deliverables**: Integration tests (macOS) + snapshot of "Shared" pill.

**Acceptance**: macOS UI tests pass.

**Status**: ✅ Complete

---

### 11) App Intents (add list item / add card) ✅

**Goal**: "Add milk to Groceries"; "Add 'Pay strata' to 'Home' → 'To Do'".

**Constraints**: Fuzzy name lookup from UseCases; return success phrases.

**Files**: App/Intents/*

**Deliverables**: Unit tests for lookup; intent performs action.

**Acceptance**: macOS unit tests pass; Shortcuts shows intents.

**Status**: ✅ Complete

---

### 12) CI hardening (fail-fast + artifacts) ✅

**Goal**: Add GitHub Actions (or equivalent) with Linux then macOS stages; artifact uploads; no continue-on-error.

**Constraints**: One-line failure summary; cache DerivedData selectively.

**Files**: .github/workflows/ci.yml

**Deliverables**: Green CI on clean clone.

**Acceptance**: CI passes; on failure, artifacts visible.

**Status**: ✅ Complete

---

### 13) Accessibility pass (DnD + labels) ✅

**Goal**: VoiceOver announces column and position; actions accessible without drag.

**Constraints**: Provide alternatives (Move Up/Down actions).

**Files**: App/UI/...

**Deliverables**: UI tests for accessibility identifiers.

**Acceptance**: Snapshot + XCTests pass.

**Status**: ✅ Complete (accessibility labels implemented throughout UI)

---

## Summary

All planned tickets have been completed! The HomeCooked project has:

- ✅ Domain models and validators with comprehensive helpers
- ✅ GRDB persistence with migrations and contract tests
- ✅ SwiftData adapter for iOS (with contract tests)
- ✅ CardReorderService with property-based tests
- ✅ Trello importer with fixtures and tests
- ✅ Backup/restore with round-trip tests
- ✅ Personal lists with checklist operations
- ✅ iOS UI with boards, columns, cards, and detail views
- ✅ Drag & drop with haptics and accessibility
- ✅ CloudKit private sync with conflict resolution
- ✅ CloudKit sharing per board
- ✅ App Intents for Shortcuts integration
- ✅ CI/CD with fail-fast Linux and macOS jobs
- ✅ Comprehensive accessibility support

## Future Enhancements

Potential areas for future development:

1. **Recipe Management UI**: While the domain models and persistence are in place, the UI for managing recipes could be enhanced
2. **Advanced Search**: Implement full-text search across boards, cards, and lists
3. **Themes & Customization**: Dark mode, custom color schemes for boards
4. **Widgets**: iOS widgets for quick access to lists and boards
5. **Apple Watch**: Companion app for viewing lists and checking off items
6. **Export Formats**: PDF export for boards, recipes
7. **Templates**: Board and card templates for common workflows
8. **Attachments**: Support for images and files on cards
9. **Comments**: Discussion threads on cards
10. **Calendar Integration**: Sync card due dates with system calendar

## Agent Guidance

When working on new features:

1. **Follow the established patterns**:
   - Pure business logic in UseCases (Linux-compatible)
   - Repository pattern for all data access
   - Contract tests for repository implementations
   - SwiftUI views in App/ with dependency injection

2. **Use the golden commands**:
   - `make preflight` before starting work
   - `make test-linux` for core logic validation
   - `make test-macos` for iOS app validation
   - `make lint` before committing

3. **Maintain the Linux-first approach**:
   - 80-90% of code should build on Linux
   - Keep Apple-only code behind adapters
   - Use protocols to abstract platform-specific APIs

4. **Update documentation**:
   - Add entries to CHANGELOG.md
   - Update README.md if user-facing features change
   - Keep DEVELOPMENT.md current with toolchain requirements
