# HomeCooked Implementation Plan

This document tracks implementation tickets for the HomeCooked project. Each ticket lists Goal, Constraints, Files, Deliverables, and Acceptance criteria with commands.

## ⚠️ Architecture Redesign in Progress

**Card-Centric Design**: The app is being redesigned around a card-centric model where:
- **Boards → Columns → Cards** are the primary navigation hierarchy
- **Recipes** and **Lists** are optional attributes that can be attached to cards
- A card can have 0, 1, or both a recipe and a list attached
- No standalone recipes or lists - everything lives on a board in a card
- UI has single entry point: Boards (no separate Recipes/Lists tabs)

This is an **alpha** project - schemas will change without migration.

---

## Ticket Status Legend

- ✅ Complete
- 🔄 Needs Revision (for card-centric redesign)
- 🚧 In Progress
- ⬜ Not Started

---

## Phase 1: Core Infrastructure (Completed, Needs Card-Centric Revision)

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

### 1) Domain models & validators 🔄

**Goal**: Implement Domain structs + helpers (ID factories, tag sanitizer, checklist utilities).

**Current Status**: ✅ Models exist but need revision for card-centric design

**Required Changes for Card-Centric Design**:
- Add `Card.recipeID: RecipeID?` (optional reference)
- Add `Card.listID: PersonalListID?` (optional reference)
- Add `Recipe.cardID: CardID` (required - recipe must belong to a card)
- Add `PersonalList.cardID: CardID` (required - list must belong to a card)
- A card can have both a recipe and a list attached

**Files**:
- `Packages/Domain/Sources/Domain/Models.swift`
- `Tests/DomainTests/*`

**Deliverables**: Updated models with card associations

**Acceptance**:
- `make test-linux` green
- Tests verify card can have 0, 1, or both recipe/list attached

**Status**: 🔄 Needs revision for card-centric model

---

### 2) Repository interfaces + GRDB v1 🔄

**Goal**: Define repos + implement GRDB schema with card associations

**Current Status**: ✅ Repositories exist but need card-centric constraints

**Required Changes**:
- Update `RecipesRepository` to enforce `cardID` on create
- Update `ListsRepository` to enforce `cardID` on create
- Add `BoardsRepository.loadCardWithRecipe(cardID)` helper
- Add `BoardsRepository.loadCardWithList(cardID)` helper
- Add `BoardsRepository.findCardsWithRecipes(boardID?)` for filtering
- Add `BoardsRepository.findCardsWithLists(boardID?)` for filtering
- Update migrations to add foreign keys: `recipes.card_id`, `personal_lists.card_id`

**Files**:
- `Packages/PersistenceInterfaces/.../*.swift`
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/*`
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/Migrations.swift`

**Deliverables**:
- Updated repository protocols
- GRDB implementation with card associations
- Migration adding card_id foreign keys

**Acceptance**:
- `swift test --filter BoardsRepositoryContractTests` passes (Linux)
- `hc-migrate --dry-run` shows card association migrations
- Cannot create recipe/list without cardID

**Status**: 🔄 Needs revision for card associations

---

### 3) Reorder service (midpoint + idle normalization) ✅

**Goal**: Implement CardReorderService in UseCases; no persistence details.

**Constraints**: Thread-safe; property tests around extremes (duplicate keys, large deltas).

**Files**: `UseCases/Reorder/*`

**Deliverables**: Unit + property tests.

**Acceptance**: `swift test --filter ReorderTests` passes (Linux).

**Status**: ✅ Complete (no changes needed)

---

### 4) Trello importer + CLI (hc-import) 🔄

**Goal**: Decode Trello JSON; map to Domain; write via repo; attach recipes to cards

**Current Status**: ✅ Basic importer exists

**Required Changes for Card-Centric Design**:
- When importing Trello cards, create Card entities
- If Trello card has description with recipe-like content, create Recipe and attach to card
- If Trello card has checklist, create PersonalList and attach to card
- Single import interface (not separate recipe/list imports)
- Maintain idempotency (dedupe by name+createdAt heuristic)

**Files**:
- `ImportExport/Trello/*`
- `CLIs/hc-import/*`
- `Tests/Fixtures/trello_*.json`

**Deliverables**:
- CLI imports cards with attached recipes/lists
- Unit tests with fixtures

**Acceptance**:
- `swift run hc-import Tests/Fixtures/trello_minimal.json --db /tmp/hc.db` exits 0
- Imported cards have recipes/lists attached as appropriate
- `swift test --filter TrelloImporterTests` passes

**Status**: 🔄 Needs revision to attach recipes/lists to cards

---

### 5) Backup/export & restore + CLI (hc-backup) 🔄

**Goal**: Versioned JSON export and merge/overwrite restore with card associations

**Current Status**: ✅ Basic backup exists

**Required Changes**:
- Export format includes cards with their attached recipe/list IDs
- Restore maintains card→recipe/list associations
- Merge mode preserves associations

**Files**:
- `ImportExport/Backup/*`
- `CLIs/hc-backup/*`

**Deliverables**: Round-trip tests with card associations

**Acceptance**:
- `swift test --filter BackupRoundTripTests` passes
- Cards maintain recipe/list associations after restore

**Status**: 🔄 Needs revision for card associations

---

### 6) Lists (PersonalList) & checklist component 🔄

**Goal**: Checklist operations always associated with a card

**Current Status**: ✅ PersonalList exists but needs card association

**Required Changes**:
- Enforce `cardID` required on PersonalList creation
- Update `ListsRepository.create` to require cardID parameter
- Checklist operations remain the same (toggle, reorder, quantities)
- Remove any standalone list creation paths

**Files**:
- `UseCases/Checklist/*`
- `PersistenceInterfaces/ListsRepository.swift`
- `PersistenceGRDB/Lists/*`

**Deliverables**:
- PersonalList always belongs to a card
- Contract tests verify card association requirement

**Acceptance**:
- `swift test --filter ListsRepositoryContractTests`
- Cannot create list without cardID
- Checklist operations work on card-attached lists

**Status**: 🔄 Needs revision for mandatory card association

---

## Phase 2: iOS UI (Card-Centric Redesign Required)

### 7) iOS UI - Card-Centric Navigation 🔄

**Goal**: SwiftUI screens with boards as sole entry point; cards have optional recipe/list sections

**Current Status**: ✅ UI exists but needs card-centric redesign

**Required Changes**:
- **Remove**: Standalone RecipesListView and ListsView as main navigation tabs
- **Keep**: BoardsListView as single entry point
- **Update**: CardDetailView to show:
  - Card details (title, description, tags, due date)
  - Optional "Recipe" section (expandable) if card has recipe attached
  - Optional "List" section (expandable) if card has list attached
  - Actions: "Attach Recipe", "Attach List", "Detach Recipe", "Detach List"
- **Add**: Card action menu with "Add Recipe", "Add List" options
- **Navigation**: Boards → BoardDetail (columns) → CardDetail (with recipe/list)

**Files**:
- `App/UI/Boards/BoardsListView.swift` (keep, make primary)
- `App/UI/BoardDetail/BoardDetailView.swift` (keep)
- `App/UI/CardDetail/CardDetailView.swift` (update to show recipe/list sections)
- `App/UI/Recipes/RecipesListView.swift` (remove or repurpose for embedded use)
- `App/UI/Lists/ListsView.swift` (remove or repurpose for embedded use)
- `App/UI/Components/RecipeSectionView.swift` (new - embedded in card)
- `App/UI/Components/ListSectionView.swift` (new - embedded in card)
- `App/DI/*`

**Deliverables**:
- Single navigation entry: Boards
- CardDetailView shows optional recipe/list sections
- Accessible drag/drop with haptics
- Smoke UI tests

**Acceptance**:
- On macOS: `make test-macos` green
- No standalone recipe/list navigation tabs
- CardDetail shows recipe section when card has recipe
- CardDetail shows list section when card has list
- Snapshot tests pass

**Status**: 🔄 Major redesign required for card-centric UI

---

### 8) SwiftData adapter (Apple-only) 🔄

**Goal**: PersistenceSwiftData with card associations for recipes/lists

**Current Status**: ✅ SwiftData adapter exists

**Required Changes**:
- Add `RecipeModel.cardID` relationship
- Add `PersonalListModel.cardID` relationship
- Add `CardModel.recipeID` and `CardModel.listID` optional relationships
- Update contract tests to verify associations
- Enforce foreign key constraints

**Files**:
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataModels.swift`
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataRecipesRepository.swift`
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataListsRepository.swift`
- `Tests/PersistenceSwiftDataTests/*`

**Deliverables**:
- SwiftData models with card associations
- Contract tests verify associations
- Repository implementations enforce cardID requirement

**Acceptance**:
- macOS test matrix runs contract suite for GRDB and SwiftData
- All tests verify card associations

**Status**: 🔄 Needs revision for card associations

---

### 9) CloudKit private sync (optional) ✅

**Goal**: Implement SyncCloudKit behind SyncInterfaces; private DB only; LWW conflicts.

**Constraints**: App works offline; status UI.

**Note**: CloudKit will sync cards with their recipe/list associations. Sync logic should handle:
- Card changes trigger recipe/list sync if attached
- Recipe/list changes sync their parent card
- Conflict resolution preserves associations

**Files**:
- `Packages/SyncCloudKit/*`
- `App/UI/Settings/SyncStatusView.swift`

**Deliverables**: Manual harness + unit tests mapping statuses.

**Acceptance**: macOS CI runs sync unit tests; manual doc SyncManualTests.md.

**Status**: ✅ Complete (may need minor updates for card associations)

---

### 10) CloudKit sharing per Board (optional) ✅

**Goal**: Share a Board and children; revoke; badge participants count.

**Constraints**: Board-scoped sharing only.

**Note**: Sharing a board shares all cards and their attached recipes/lists.

**Files**: `App/UI/BoardDetail/Share/*`

**Deliverables**: Integration tests (macOS) + snapshot of "Shared" pill.

**Acceptance**: macOS UI tests pass.

**Status**: ✅ Complete (works with card associations)

---

## Phase 3: Shortcuts & Search (Card-Centric)

### 11) App Intents (add list item / add card with recipe) 🔄

**Goal**: Intents require board+card context; create card if needed

**Current Status**: ✅ Intents exist

**Required Changes**:
- **"Add List Item" Intent**:
  - Parameters: boardName, cardName, itemText
  - Fuzzy match board and card
  - If card not found, create new card on board
  - Create PersonalList attached to card if card doesn't have one
  - Add item to card's list

- **"Add Recipe to Card" Intent** (new):
  - Parameters: boardName, cardName, recipeName, ingredients
  - Fuzzy match board and card
  - Create card if needed
  - Attach Recipe to card

- **"Add Card" Intent** (existing, keep):
  - Parameters: boardName, columnName, cardTitle
  - Works as before

**Files**:
- `App/Intents/AddListItemIntent.swift` (update)
- `App/Intents/AddRecipeIntent.swift` (new)
- `App/Intents/AddCardIntent.swift` (keep)
- `App/Intents/IntentsProvider.swift`
- `UseCases/Lookup/*` (update for card-centric search)

**Deliverables**:
- Updated intents requiring board+card
- Fuzzy lookup for cards
- Intents create card if not found

**Acceptance**:
- macOS unit tests pass
- Shortcuts shows intents with correct parameters
- "Add milk to Shopping card on Home board" works
- "Add recipe to Dinner card on Meal Planning board" works

**Status**: 🔄 Needs revision for card-centric model

---

### 12) Search & Filtering (Card-Centric) ⬜

**Goal**: Search cards by attributes (has recipe, has list, tags, text)

**Constraints**:
- Search is card-centric: find cards, not standalone recipes/lists
- Filter cards by:
  - Has recipe attached
  - Has list attached
  - By tag
  - By text (title, details)
  - By due date
- Results show cards with badges indicating recipe/list presence
- Tap result navigates to CardDetailView

**Files**:
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/SearchRepository.swift` (new)
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBSearchRepository.swift` (new)
- `App/UI/Search/CardSearchView.swift` (new)
- `App/UI/Search/CardSearchResultsView.swift` (new)
- `Tests/PersistenceGRDBTests/SearchRepositoryTests.swift` (new)

**Deliverables**:
- Search UI finds cards
- Filter by "has recipe" / "has list"
- Results show card context (board → column → card)
- Navigation to CardDetailView

**Acceptance**:
- `swift test --filter SearchRepositoryTests` passes
- Search finds cards with recipes attached
- Filter "has list" returns only cards with lists
- VoiceOver announces result attributes

**Status**: ⬜ Not Started

---

### 13) CI hardening (fail-fast + artifacts) ✅

**Goal**: Add GitHub Actions (or equivalent) with Linux then macOS stages; artifact uploads; no continue-on-error.

**Constraints**: One-line failure summary; cache DerivedData selectively.

**Files**: `.github/workflows/ci.yml`

**Deliverables**: Green CI on clean clone.

**Acceptance**: CI passes; on failure, artifacts visible.

**Status**: ✅ Complete

---

### 14) Accessibility pass (DnD + labels) ✅

**Goal**: VoiceOver announces column and position; actions accessible without drag.

**Constraints**: Provide alternatives (Move Up/Down actions).

**Files**: `App/UI/...`

**Deliverables**: UI tests for accessibility identifiers.

**Acceptance**: Snapshot + XCTests pass.

**Status**: ✅ Complete

---

## Phase 4: Advanced Features (Card-Centric)

### 15) Recipe Management within Cards ⬜

**Goal**: Rich recipe editing within card detail view

**Constraints**:
- Recipe editor embedded in CardDetailView
- Markdown rendering for method
- Ingredients as ChecklistItems (quantity, unit, item)
- Tags for recipe categorization
- "Export to Shopping List" creates new card with list on same/different board
- Photo attachment for recipe (optional)

**Files**:
- `App/UI/CardDetail/RecipeEditorView.swift` (new, embedded)
- `App/UI/CardDetail/RecipeMethodView.swift` (new, markdown renderer)
- `App/UI/Components/RecipeActionsMenu.swift` (new)
- `UseCases/Recipes/RecipeExporter.swift` (new - export to list)

**Deliverables**:
- Recipe editor within card
- Markdown method rendering
- Export ingredients to shopping list card
- Photo attachment (optional)

**Acceptance**:
- Create recipe within card
- Edit recipe ingredients and method
- Export creates new card with PersonalList
- Photos appear in recipe view

**Status**: ⬜ Not Started

---

### 16) Bulk Card Operations ⬜

**Goal**: Select multiple cards and apply bulk actions

**Constraints**:
- Multi-select mode in BoardDetailView
- Actions: Move to column, Add tag, Delete, Archive
- Accessible without drag/drop
- Confirm before destructive actions
- Show count of selected cards

**Files**:
- `App/UI/BoardDetail/CardSelectionMode.swift` (new)
- `App/UI/BoardDetail/BulkActionsBar.swift` (new)
- `UseCases/Cards/BulkCardOperations.swift` (new)

**Deliverables**:
- Multi-select UI
- Bulk move to column
- Bulk tag addition
- Bulk delete with confirmation

**Acceptance**:
- Select multiple cards and move to column
- Bulk add tag to 10+ cards
- VoiceOver announces selection count
- Confirmation appears before bulk delete

**Status**: ⬜ Not Started

---

### 17) Card Templates ⬜

**Goal**: Save cards as templates with pre-filled recipe/list/checklist

**Constraints**:
- Save card as template (structure only, no timestamps)
- Template library in board menu
- Create card from template
- Templates can include recipe skeleton or list template
- Export/import templates via JSON

**Files**:
- `Packages/Domain/Sources/Domain/CardTemplate.swift` (new)
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/TemplatesRepository.swift` (new)
- `App/UI/Templates/CardTemplatesView.swift` (new)
- `UseCases/Templates/TemplateInstantiator.swift` (new)

**Deliverables**:
- Save card as template
- Template library
- Create from template
- Templates include recipe/list structure

**Acceptance**:
- Save card with recipe as template
- Creating from template creates independent card
- Template includes pre-filled checklist items

**Status**: ⬜ Not Started

---

### 18) iOS Widgets (Card-Based) ⬜

**Goal**: Widgets show cards with due dates and list progress

**Constraints**:
- Small widget: Shows one card with list progress (5/10 items done)
- Medium widget: Shows 2-3 upcoming cards (by due date)
- Lock screen widget: Count of cards due today
- Tap widget opens card detail view
- Configuration selects board/column to show

**Files**:
- `App/Widgets/CardListWidget.swift` (new)
- `App/Widgets/UpcomingCardsWidget.swift` (new)
- `App/Widgets/LockScreenWidget.swift` (new)
- `App/Intents/ConfigureWidgetIntent.swift` (new)

**Deliverables**:
- Widget showing card with list progress
- Upcoming cards widget (by due date)
- Lock screen widget (cards due today count)
- Configuration via App Intents

**Acceptance**:
- Widgets appear in gallery
- Widget shows "Shopping: 5/10 items done"
- Tap opens CardDetailView
- Lock screen shows "3 cards due today"

**Status**: ⬜ Not Started

---

### 19) Export Formats (PDF, Markdown) ⬜

**Goal**: Export boards and cards to PDF and Markdown

**Constraints**:
- PDF: Board with all cards, grouped by column
- Cards with recipes show recipe content in export
- Cards with lists show checklist items
- Markdown: Board structure with card details
- Export via iOS share sheet
- Linux-compatible export logic

**Files**:
- `Packages/ImportExport/Sources/ImportExport/Export/PDFExporter.swift` (new)
- `Packages/ImportExport/Sources/ImportExport/Export/MarkdownExporter.swift` (new)
- `App/UI/BoardDetail/ExportMenuView.swift` (new)

**Deliverables**:
- PDF export for boards
- Markdown export
- Recipe content included in exports
- List items included in exports

**Acceptance**:
- `swift test --filter ExportTests` passes (Linux)
- Exported PDF shows card with recipe formatted nicely
- Markdown preserves card→recipe/list structure

**Status**: ⬜ Not Started

---

### 20) Themes & Customization ⬜

**Goal**: Dark mode and per-board color themes

**Constraints**:
- System dark mode toggle
- Per-board color themes (8-10 palettes)
- Color persistence in Board model
- All UI respects themes
- Accessibility contrast maintained

**Files**:
- `Packages/Domain/Sources/Domain/Models.swift` (add Board.colorTheme)
- `App/UI/Theme/ThemeProvider.swift` (new)
- `App/UI/Theme/ColorPalettes.swift` (new)

**Deliverables**:
- Dark mode support
- Board color theme picker
- Theme persistence
- Accessible colors

**Acceptance**:
- App follows system dark mode
- Board themes persist
- All text readable with themes

**Status**: ⬜ Not Started

---

## Phase 5: Performance & Polish

### 21) Performance Optimization ⬜

**Goal**: Profile and optimize hot paths (reorder, search, card loading with recipes/lists)

**Constraints**:
- Benchmark card loading with attached recipes/lists
- Optimize queries: load card with recipe in single query
- Reduce allocations in reorder
- Profile CloudKit sync with associations
- Document performance baselines

**Files**:
- `Tests/PerformanceTests/*` (new)
- Optimize: `Migrations.swift` (indices on card_id foreign keys)
- Optimize: `GRDBBoardsRepository.swift` (JOIN queries for card+recipe/list)

**Deliverables**:
- Performance benchmarks
- Optimized queries for card+recipe/list loading
- Documented baselines

**Acceptance**:
- Load 100 cards with recipes <100ms
- Card reorder <10ms
- Search 1000 cards <100ms

**Status**: ⬜ Not Started

---

### 22) Improved Error Messages & Logging ⬜

**Goal**: Better errors, structured logging, PII redaction

**Constraints**:
- os.Logger on Apple platforms
- Lightweight logger for Linux
- Redact PII (user content)
- Contextual errors ("Failed to attach recipe to card X")
- No secrets in logs

**Files**:
- `Packages/Domain/Sources/Domain/Logging.swift` (new)
- Update all repos and use cases

**Deliverables**:
- Structured logging
- PII redaction
- Contextual errors

**Acceptance**:
- Logs contain no user content
- Errors include context
- Works on Linux and macOS

**Status**: ⬜ Not Started

---

### 23) Reduce Repository Duplication ⬜

**Goal**: Extract common patterns from GRDB and SwiftData repos

**Constraints**:
- Shared utilities for ID/UUID conversion
- Protocol extensions for common queries
- Maintain 100% test coverage

**Files**:
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/RepositoryHelpers.swift` (new)
- Refactor: All repository implementations

**Deliverables**:
- Extracted helpers
- Reduced duplication
- Tests still pass

**Acceptance**:
- `make test-linux && make test-macos` passes
- Code duplication reduced >30%

**Status**: ⬜ Not Started

---

## Summary

**Architectural Principles (Card-Centric Design)**:
- ✅ Boards → Columns → Cards is the primary hierarchy
- ✅ Recipes and Lists are optional card attributes (not standalone entities)
- ✅ Single navigation entry point: Boards
- ✅ A card can have 0, 1, or both recipe and list attached
- ✅ Search finds cards (with filters for "has recipe", "has list")
- ✅ Intents require board+card context
- ✅ UI shows recipe/list sections within CardDetailView

**Completed (Needs Revision)**:
- 🔄 Domain models (need card associations)
- 🔄 Repositories (need card foreign keys)
- 🔄 Trello importer (attach to cards)
- 🔄 Backup/restore (preserve associations)
- 🔄 iOS UI (card-centric redesign)
- 🔄 App Intents (require board+card)

**Next Priority**:
1. Update Domain models for card associations (ticket 1)
2. Update repositories and migrations (ticket 2)
3. Redesign iOS UI for card-centric navigation (ticket 7)
4. Update SwiftData adapter (ticket 8)
5. Revise App Intents (ticket 11)

**Agent Guidance**:

When working on card-centric redesign:

1. **Domain First**: Start with Domain models - add optional recipe/list references to Card, add required cardID to Recipe and PersonalList

2. **Migrations**: Add migration to create card_id foreign keys in recipes and personal_lists tables

3. **Repositories**: Update interfaces to enforce card associations (create methods require cardID)

4. **Contract Tests**: Verify that recipes/lists cannot be created without a card

5. **UI Redesign**: Remove standalone navigation for recipes/lists; embed in CardDetailView

6. **Search**: Implement card-centric search with "has recipe" / "has list" filters

7. **Use Golden Commands**:
   - `make preflight` before starting
   - `make test-linux` for core logic
   - `make test-macos` for iOS app

8. **Alpha Status**: Don't worry about data migration - breaking changes are expected

---

## Definition of Done

Before considering card-centric redesign complete:

- ✅ Domain models have card associations
- ✅ Migrations add card_id foreign keys
- ✅ Cannot create recipe/list without cardID
- ✅ Contract tests verify associations
- ✅ UI has single entry point: Boards
- ✅ CardDetailView shows optional recipe/list sections
- ✅ Search filters by "has recipe" / "has list"
- ✅ Intents require board+card context
- ✅ All tests pass: `make test-linux && make test-macos`
- ✅ CHANGELOG.md updated
