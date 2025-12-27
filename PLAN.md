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

## Summary - Core Features Complete

The HomeCooked project has completed all core board management features:

- ✅ Domain models and validators with comprehensive helpers
- ✅ GRDB persistence for boards/columns/cards with migrations and contract tests
- ✅ SwiftData adapter for iOS (with contract tests)
- ✅ CardReorderService with property-based tests
- ✅ Trello importer with fixtures and tests
- ✅ Backup/restore with round-trip tests
- ✅ Personal lists backend (GRDB + SwiftData, no UI yet)
- ✅ iOS UI with boards, columns, cards, and detail views
- ✅ Drag & drop with haptics and accessibility
- ✅ CloudKit private sync with conflict resolution
- ✅ CloudKit sharing per board
- ✅ App Intents for Shortcuts integration
- ✅ CI/CD with fail-fast Linux and macOS jobs
- ✅ Comprehensive accessibility support

**Recently Completed**:
- ✅ Recipes: Full implementation with GRDB/SwiftData backends and complete iOS UI

---

## Phase 2: Missing Features & Enhancements

### 14) Recipe Management (Complete Implementation) ✅

**Goal**: Implement complete recipe support (persistence + UI)

**Constraints**:
- Follow existing patterns (GRDB + SwiftData repos, contract tests)
- Markdown rendering for method
- Tag-based search and filtering
- Export recipe to shopping list (copy ingredients to PersonalList)

**Files**:
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBRecipesRepository.swift` (replace TODOs)
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/Migrations.swift` (add recipes table)
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/Records.swift` (add RecipeRecord)
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataModels.swift` (add RecipeModel)
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataRecipesRepository.swift` (new)
- `App/UI/Recipes/RecipesListView.swift` (new)
- `App/UI/Recipes/RecipeDetailView.swift` (new)
- `App/UI/Recipes/RecipeEditorView.swift` (new)
- `Tests/PersistenceGRDBTests/RecipesRepositoryContractTests.swift` (new)
- `Tests/PersistenceSwiftDataTests/SwiftDataRecipesRepositoryContractTests.swift` (new)

**Deliverables**:
- GRDB implementation with schema migration
- SwiftData implementation with contract tests
- UI for browsing, viewing, editing, and creating recipes
- "Add to Shopping List" action
- Tag filtering and search

**Acceptance**:
- `swift test --filter RecipesRepositoryContractTests` passes (Linux)
- macOS UI tests for recipe CRUD operations
- Recipes appear in main navigation alongside Boards and Lists

**Status**: ✅ Complete

---

### 15) Personal Lists UI ✅

**Goal**: Build iOS UI for PersonalList (grocery lists, packing lists, etc.)

**Constraints**:
- Follow board/card UI patterns
- Swipe actions for quick delete/reorder
- Bulk add/remove via text paste (one item per line)
- Share list via standard iOS share sheet
- Accessible without drag/drop (Move Up/Down actions)

**Files**:
- `App/UI/Lists/ListsView.swift` (completed)
- `App/UI/Lists/ListDetailView.swift` (completed)
- `App/UI/Lists/ListEditorView.swift` (completed)
- `Tests/UITests/ListsUITests.swift` (completed)

**Deliverables**:
- Lists browser (like BoardsListView) ✅
- Detail view with checklist items ✅
- Add/edit/delete items ✅
- Bulk import from text ✅
- Share integration ✅

**Acceptance**:
- macOS UI tests pass ✅
- VoiceOver announces list items correctly ✅
- Bulk paste creates multiple items ✅

**Status**: ✅ Complete

---

### 16) iOS Widgets (Home Screen & Lock Screen) ⬜

**Goal**: Add iOS widgets for quick access to lists and upcoming cards

**Constraints**:
- Small widget: Shows one list with top 3 items
- Medium widget: Shows 2-3 upcoming cards (by due date)
- Lock screen widget: Count of unchecked items in selected list
- Tap to open app to relevant screen
- Use WidgetKit with AppIntents for configuration

**Files**:
- `App/Widgets/ListWidget.swift` (new)
- `App/Widgets/UpcomingCardsWidget.swift` (new)
- `App/Widgets/LockScreenWidget.swift` (new)
- `App/Intents/ConfigureWidgetIntent.swift` (new)

**Deliverables**:
- Widget extension target
- Three widget types (list, cards, lock screen)
- Configuration via App Intents
- Timeline updates

**Acceptance**:
- Widgets appear in widget gallery
- Widgets update when data changes
- Tap opens correct app screen

**Status**: ⬜ Not Started

---

### 17) Advanced Search & Filtering ⬜

**Goal**: Full-text search across all entities (boards, cards, lists, recipes)

**Constraints**:
- GRDB FTS5 for efficient full-text search
- Search UI with filters (entity type, tags, date range)
- Recent searches stored locally
- Results grouped by entity type
- Tap result to navigate to detail view

**Files**:
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/Migrations.swift` (add FTS tables)
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/SearchRepository.swift` (new)
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBSearchRepository.swift` (new)
- `App/UI/Search/SearchView.swift` (new)
- `App/UI/Search/SearchResultsView.swift` (new)
- `Tests/PersistenceGRDBTests/SearchRepositoryTests.swift` (new)

**Deliverables**:
- FTS5 virtual tables in GRDB
- SearchRepository protocol and implementation
- Search UI with filters
- Recent searches
- Result navigation

**Acceptance**:
- `swift test --filter SearchRepositoryTests` passes
- Search returns results across entity types
- Filters work correctly
- VoiceOver announces result count

**Status**: ⬜ Not Started

---

### 18) Themes & Customization ⬜

**Goal**: Dark mode support and custom board color schemes

**Constraints**:
- System dark mode toggle (follow iOS setting)
- Per-board color themes (8-10 preset palettes)
- Color persistence in Board model
- All UI respects theme colors
- Accessibility contrast ratios maintained

**Files**:
- `Packages/Domain/Sources/Domain/Models.swift` (add Board.colorTheme)
- `App/UI/Theme/ThemeProvider.swift` (new)
- `App/UI/Theme/ColorPalettes.swift` (new)
- `App/UI/BoardDetail/BoardThemePickerView.swift` (new)
- Migration for Board.colorTheme column

**Deliverables**:
- Dark mode support throughout app
- Board color theme picker
- Theme persistence
- Accessible color combinations

**Acceptance**:
- App follows system dark mode
- Board themes persist across launches
- All text remains readable with themes

**Status**: ⬜ Not Started

---

### 19) Export Formats (PDF, Markdown) ⬜

**Goal**: Export boards and recipes to PDF and Markdown

**Constraints**:
- PDF: Single board with all cards grouped by column
- Markdown: Board structure with card details
- Recipe PDF: Formatted with ingredients and method
- Export via iOS share sheet
- Linux-compatible export logic in ImportExport package

**Files**:
- `Packages/ImportExport/Sources/ImportExport/Export/PDFExporter.swift` (new)
- `Packages/ImportExport/Sources/ImportExport/Export/MarkdownExporter.swift` (new)
- `App/UI/BoardDetail/ExportMenuView.swift` (new)
- `Tests/ImportExportTests/ExportTests.swift` (new)

**Deliverables**:
- PDF export for boards and recipes
- Markdown export for boards
- Share sheet integration
- Unit tests for export formats

**Acceptance**:
- `swift test --filter ExportTests` passes (Linux)
- Exported PDFs are readable and well-formatted
- Markdown preserves structure

**Status**: ⬜ Not Started

---

### 20) Templates (Boards & Cards) ⬜

**Goal**: Save and reuse board/card templates for common workflows

**Constraints**:
- Save board as template (structure only, no data)
- Card templates with default checklist/tags
- Template library in UI
- Templates stored in database
- Export/import templates via JSON

**Files**:
- `Packages/Domain/Sources/Domain/Template.swift` (new)
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/TemplatesRepository.swift` (new)
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBTemplatesRepository.swift` (new)
- `App/UI/Templates/TemplatesView.swift` (new)
- Migration for templates table

**Deliverables**:
- Template domain model
- Repository implementation
- Template browser UI
- Create board from template
- Import/export templates

**Acceptance**:
- Save board as template preserves structure
- Creating from template creates independent copy
- Templates work offline

**Status**: ⬜ Not Started

---

## Phase 3: Refactoring & Technical Improvements

### 21) Reduce Code Duplication in Repositories ⬜

**Goal**: Extract common patterns from GRDB and SwiftData repositories

**Constraints**:
- Create shared utilities for ID/UUID conversion
- Shared JSON encoding/decoding for arrays
- Protocol extensions for common queries
- Maintain 100% test coverage

**Files**:
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/RepositoryHelpers.swift` (new)
- Refactor: `GRDBBoardsRepository.swift`, `SwiftDataBoardsRepository.swift`, etc.

**Deliverables**:
- Extracted helper utilities
- Reduced duplication
- All tests still pass

**Acceptance**:
- `make test-linux && make test-macos` passes
- Code duplication reduced by >30% (measured by lines)

**Status**: ⬜ Not Started

---

### 22) Improve Error Messages & Logging ⬜

**Goal**: Better error messages, structured logging, redaction

**Constraints**:
- Use os.Logger on Apple platforms
- Lightweight custom logger for Linux
- Redact PII (user content, IDs in logs)
- Error context (what operation failed, why)
- No secrets in logs

**Files**:
- `Packages/Domain/Sources/Domain/Logging.swift` (new)
- Update all repos and use cases with logging

**Deliverables**:
- Structured logging throughout codebase
- PII redaction
- Contextual error messages

**Acceptance**:
- Logs contain no user content
- Errors include actionable context
- Works on Linux and macOS

**Status**: ⬜ Not Started

---

### 23) Performance Optimization ⬜

**Goal**: Profile and optimize hot paths (reorder, search, sync)

**Constraints**:
- Benchmark key operations
- Optimize GRDB queries (indices, joins)
- Reduce allocations in reorder normalization
- Profile CloudKit sync batch sizes
- Document performance baselines

**Files**:
- `Tests/PerformanceTests/ReorderBenchmarks.swift` (new)
- `Tests/PerformanceTests/SearchBenchmarks.swift` (new)
- Optimize: Migrations.swift (add missing indices)

**Deliverables**:
- Performance benchmarks
- Optimized queries
- Documented baselines
- <50ms for common operations

**Acceptance**:
- Benchmark suite runs in CI
- Card reorder <10ms
- Search <100ms for 1000 cards

**Status**: ⬜ Not Started

---

### 24) Add swiftlint & swiftformat to CI ⬜

**Goal**: Enforce code style consistency in CI

**Constraints**:
- Add .swiftlint.yml configuration
- Add .swiftformat configuration
- Run in CI (fail on violations)
- Document style rules in DEVELOPMENT.md

**Files**:
- `.swiftlint.yml` (new)
- `.swiftformat` (new)
- `.github/workflows/ci.yml` (add lint stage)
- `Makefile` (enhance lint target)

**Deliverables**:
- Lint configurations
- CI enforcement
- Documentation

**Acceptance**:
- `make lint` passes locally
- CI fails on style violations
- All existing code passes lint

**Status**: ⬜ Not Started

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
