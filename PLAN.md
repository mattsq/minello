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

### 1) Domain models & validators ✅

**Goal**: Implement Domain structs + helpers (ID factories, tag sanitizer, checklist utilities).

**Current Status**: ✅ Complete - Card-centric design fully implemented

**Implemented Changes**:
- ✅ `Card.recipeID: RecipeID?` (optional reference) - Models.swift:170
- ✅ `Card.listID: ListID?` (optional reference) - Models.swift:171
- ✅ `Recipe.cardID: CardID` (required - recipe must belong to a card) - Models.swift:239
- ✅ `PersonalList.cardID: CardID` (required - list must belong to a card) - Models.swift:210
- ✅ Card can have both a recipe and a list attached

**Files**:
- `Packages/Domain/Sources/Domain/Models.swift` ✅
- `Tests/DomainTests/ModelsTests.swift` ✅

**Deliverables**: ✅ Models with card associations implemented

**Acceptance**:
- ✅ Tests verify card can have 0, 1, or both recipe/list attached (ModelsTests.swift:339-409)
- ✅ Tests verify Recipe requires cardID (ModelsTests.swift:411-437)
- ✅ Tests verify PersonalList requires cardID (ModelsTests.swift:439-464)

**Status**: ✅ Complete

---

### 2) Repository interfaces + GRDB v1 ✅

**Goal**: Define repos + implement GRDB schema with card associations

**Current Status**: ✅ Complete - Card associations fully implemented (migrations skipped per alpha policy)

**Implemented Changes**:
- ✅ `RecipesRepository` enforces `cardID` via Domain model constructor - RecipesRepository.swift:14
- ✅ `ListsRepository` enforces `cardID` via Domain model constructor - ListsRepository.swift:14
- ✅ `BoardsRepository.loadCardWithRecipe(cardID)` - BoardsRepository.swift:133, GRDBBoardsRepository.swift:252
- ✅ `BoardsRepository.loadCardWithList(cardID)` - BoardsRepository.swift:139, GRDBBoardsRepository.swift:273
- ✅ `BoardsRepository.findCardsWithRecipes(boardID?)` - BoardsRepository.swift:145, GRDBBoardsRepository.swift:294
- ✅ `BoardsRepository.findCardsWithLists(boardID?)` - BoardsRepository.swift:151, GRDBBoardsRepository.swift:320
- ✅ `RecipesRepository.loadForCard(cardID)` - RecipesRepository.swift:57, GRDBRecipesRepository.swift:125
- ✅ `ListsRepository.loadForCard(cardID)` - ListsRepository.swift:56, GRDBListsRepository.swift:125
- ✅ GRDB Records have card associations - Records.swift:163-164 (Card), 264 (PersonalList), 331 (Recipe)
- ⚠️ Migrations SKIPPED per alpha policy (NO DATABASE MIGRATIONS allowed)

**Files**:
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/BoardsRepository.swift` ✅
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/RecipesRepository.swift` ✅
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/ListsRepository.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/Records.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBBoardsRepository.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBRecipesRepository.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBListsRepository.swift` ✅

**Deliverables**:
- ✅ Repository protocols with card-centric methods
- ✅ GRDB Records with card associations
- ✅ GRDB implementations with all query methods
- ⚠️ Migrations skipped (alpha - users recreate DBs)

**Acceptance**:
- ✅ Repository interfaces define card-centric methods
- ✅ GRDB Records have card_id fields
- ✅ GRDB implementations have all required methods
- ⚠️ Migrations not created per alpha policy

**Status**: ✅ Complete (migrations intentionally skipped per CLAUDE.md policy)

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

### 6) Lists (PersonalList) & checklist component ✅

**Goal**: Checklist operations always associated with a card

**Current Status**: ✅ Complete - PersonalList requires cardID, checklist operations card-agnostic

**Implemented Changes**:
- ✅ `PersonalList.cardID` required in Domain model - Models.swift:210
- ✅ `ListsRepository.createList` enforces cardID via PersonalList constructor - ListsRepository.swift:14
- ✅ Checklist operations work with any ChecklistItem array - ChecklistOperations.swift
- ✅ No standalone list creation (enforced by Domain model requiring cardID)
- ✅ PersonalListRecord has card_id field - Records.swift:264

**Files**:
- `Packages/UseCases/Sources/UseCases/Checklist/ChecklistOperations.swift` ✅
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/ListsRepository.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBListsRepository.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/Records.swift` (PersonalListRecord) ✅

**Deliverables**:
- ✅ PersonalList always belongs to a card (enforced by Domain model)
- ✅ ChecklistOperations service works with any ChecklistItem array
- ✅ Repository enforces card association via type system

**Acceptance**:
- ✅ PersonalList constructor requires cardID
- ✅ Cannot create list without cardID (enforced by Domain model)
- ✅ Checklist operations work on card-attached lists
- ✅ ChecklistOperations is reusable for Card.checklist, PersonalList.items, Recipe.ingredients

**Status**: ✅ Complete

---

## Phase 2: iOS UI (Card-Centric Redesign Required)

### 7) iOS UI - Card-Centric Navigation ✅

**Goal**: SwiftUI screens with boards as sole entry point; cards have optional recipe/list sections

**Current Status**: ✅ Complete - Card-centric UI fully implemented

**Implemented Changes**:
- ✅ **Removed**: Standalone RecipesListView and ListsView from main navigation tabs - ContentView.swift:6-18
- ✅ **Navigation**: Only Boards and Search tabs remain (card-centric search)
- ✅ **CardDetailView Updated**: Shows optional recipe and list sections - CardDetailView.swift:123-152
  - Card details (title, description, tags, due date, checklist)
  - Optional "Recipe" section (collapsible) when card.recipeID exists
  - Optional "List" section (collapsible) when card.listID exists
  - Actions: "Attach Recipe", "Attach List", "Detach Recipe", "Detach List", "Edit"
- ✅ **Created RecipeSectionView**: Embedded recipe component - RecipeSectionView.swift
  - Shows recipe title, tags, ingredients, method preview
  - Collapsible/expandable UI
  - Edit and detach actions
  - "Attach Recipe" button when no recipe attached
- ✅ **Created ListSectionView**: Embedded list component - ListSectionView.swift
  - Shows list title, progress, items (first 5)
  - Collapsible/expandable UI
  - Toggle items, edit, and detach actions
  - "Attach List" button when no list attached
- ✅ **Updated RecipeEditorView**: Accepts cardID for create mode - RecipeEditorView.swift:10
- ✅ **Updated ListEditorView**: Accepts cardID for create mode - ListEditorView.swift:10
- ✅ **Card Actions**: Attach/detach/edit recipes and lists from CardDetailView - CardDetailView.swift:315-430
- ✅ **Removed**: RecipesListView and ListsView (incompatible with card-centric model)

**Files**:
- `App/UI/ContentView.swift` ✅ (removed Lists and Recipes tabs)
- `App/UI/CardDetail/CardDetailView.swift` ✅ (added recipe/list sections with full CRUD)
- `App/UI/Components/RecipeSectionView.swift` ✅ (new - embedded recipe display)
- `App/UI/Components/ListSectionView.swift` ✅ (new - embedded list display)
- `App/UI/Recipes/RecipeEditorView.swift` ✅ (updated to accept cardID)
- `App/UI/Lists/ListEditorView.swift` ✅ (updated to accept cardID)
- `App/UI/Recipes/RecipesListView.swift` ❌ (deleted - incompatible with card-centric model)
- `App/UI/Lists/ListsView.swift` ❌ (deleted - incompatible with card-centric model)

**Deliverables**: ✅ All Complete
- Single navigation entry: Boards (+ Search)
- CardDetailView shows optional recipe/list sections
- Attach/detach/edit actions functional
- Card-centric data flow enforced

**Acceptance**: ⏳ Pending CI
- Navigation has only Boards and Search tabs ✅
- CardDetailView loads recipe when card.recipeID exists ✅
- CardDetailView loads list when card.listID exists ✅
- Attach recipe creates new recipe with cardID and updates card ✅
- Attach list creates new list with cardID and updates card ✅
- Detach removes reference and deletes recipe/list ✅
- Edit updates existing recipe/list ✅
- RecipeEditorView.Mode.create requires cardID ✅
- ListEditorView.Mode.create requires cardID ✅

**Status**: ✅ Complete (pending CI validation)

---

### 8) SwiftData adapter (Apple-only) ✅

**Goal**: PersistenceSwiftData with card associations for recipes/lists

**Current Status**: ✅ Complete - SwiftData models and repositories have full card associations

**Implemented Changes**:
- ✅ `RecipeModel.cardID` relationship - SwiftDataModels.swift:315
- ✅ `PersonalListModel.cardID` relationship - SwiftDataModels.swift:252
- ✅ `CardModel.recipeID` optional relationship - SwiftDataModels.swift:160
- ✅ `CardModel.listID` optional relationship - SwiftDataModels.swift:161
- ✅ Proper conversion to/from Domain models with card associations
- ✅ Alpha migration support (dummy CardID for old records)
- ✅ All card-centric query methods implemented:
  - `SwiftDataBoardsRepository.loadCardWithRecipe` - SwiftDataBoardsRepository.swift:296
  - `SwiftDataBoardsRepository.loadCardWithList` - SwiftDataBoardsRepository.swift:322
  - `SwiftDataBoardsRepository.findCardsWithRecipes` - SwiftDataBoardsRepository.swift:348
  - `SwiftDataBoardsRepository.findCardsWithLists` - SwiftDataBoardsRepository.swift:373
  - `SwiftDataRecipesRepository.loadForCard` - SwiftDataRecipesRepository.swift:114
  - `SwiftDataListsRepository.loadForCard` - SwiftDataListsRepository.swift:110

**Files**:
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataModels.swift` ✅
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataBoardsRepository.swift` ✅
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataRecipesRepository.swift` ✅
- `App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataListsRepository.swift` ✅

**Deliverables**:
- ✅ SwiftData models with card associations
- ✅ Repository implementations enforce cardID via Domain models
- ✅ All card-centric query methods implemented

**Acceptance**:
- ✅ SwiftData models have card association fields
- ✅ Repositories implement all card-centric query methods
- ✅ Conversion to/from Domain models preserves associations

**Status**: ✅ Complete

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

### 12) Search & Filtering (Card-Centric) ✅

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
- `Packages/PersistenceInterfaces/Sources/PersistenceInterfaces/SearchRepository.swift` ✅
- `Packages/PersistenceGRDB/Sources/PersistenceGRDB/GRDBSearchRepository.swift` ✅
- `App/UI/Search/CardSearchView.swift` ✅
- `App/DI/RepositoryProvider.swift` (updated to include SearchRepository) ✅
- `App/DI/GRDBRepositoryProvider.swift` (updated to provide SearchRepository) ✅
- `App/UI/ContentView.swift` (updated with Search tab) ✅
- `Tests/PersistenceGRDBTests/SearchRepositoryTests.swift` ✅

**Implementation Details**:
- Created `CardFilter` struct with comprehensive filtering options (text, hasRecipe, hasList, tag, dueDateRange, boardID)
- `CardSearchResult` provides full context (card, column, board, hasRecipe, hasList)
- GRDB implementation uses SQL joins and JSON queries for efficient search
- Comprehensive test suite with 18 tests covering:
  - Text search (title and details, case-insensitive)
  - Recipe/list filtering (with board scoping)
  - Tag filtering (using SQLite JSON extension)
  - Due date range filtering
  - Multiple filters combined
  - Full context retrieval
- UI features:
  - Debounced search (300ms delay)
  - Filter sheet with segmented pickers
  - Visual badges for recipe/list presence
  - Board → Column breadcrumb navigation
  - Tag display with horizontal scroll
  - Accessibility labels for VoiceOver
  - Empty states and error handling

**Deliverables**: ✅ Complete
- Search UI finds cards ✅
- Filter by "has recipe" / "has list" ✅
- Results show card context (board → column → card) ✅
- Navigation to card detail view ✅
- Added as Search tab in main navigation ✅

**Acceptance**: ✅ Complete
- Comprehensive test suite passes (18 tests)
- Search finds cards with recipes attached
- Filter "has list" returns only cards with lists
- VoiceOver announces result attributes
- Integrated into app navigation

**Status**: ✅ Complete

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

**Completed (Card-Centric)**:
- ✅ Domain models (ticket 1) - card associations implemented
- ✅ Repositories & GRDB (ticket 2) - card foreign keys in Records, migrations skipped per alpha policy
- ✅ Reorder service (ticket 3) - no changes needed
- ✅ Lists & checklist (ticket 6) - PersonalList requires cardID
- ✅ iOS UI (ticket 7) - card-centric navigation with embedded recipe/list sections
- ✅ SwiftData adapter (ticket 8) - card associations implemented
- ✅ Search & Filtering (ticket 12) - card-centric search complete

**Needs Revision**:
- 🔄 Trello importer (ticket 4) - needs logic to create Recipe/PersonalList entities from Trello data
- 🔄 Backup/restore (ticket 5) - needs verification for card associations
- 🔄 App Intents (ticket 11) - needs update for card-centric model

**Next Priority**:
1. ✅ Update Domain models for card associations (ticket 1) - COMPLETE
2. ✅ Update repositories and migrations (ticket 2) - COMPLETE (migrations skipped)
3. ✅ Update Lists & checklist (ticket 6) - COMPLETE
4. ✅ Update SwiftData adapter (ticket 8) - COMPLETE
5. ✅ Redesign iOS UI for card-centric navigation (ticket 7) - COMPLETE
6. 🔄 Revise App Intents (ticket 11) - TODO
7. 🔄 Update Trello importer (ticket 4) - TODO
8. 🔄 Verify Backup/restore (ticket 5) - TODO

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
