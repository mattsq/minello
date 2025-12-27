# Project

"HomeCooked" — a small, local-first task/collab app to replace Trello at home. Core types: Board → Column → Card, ChecklistItem, plus PersonalList (grocery/packing) and Recipe (ingredients + markdown method).
Principle: 80–90% of the code builds/tests on Linux via SwiftPM; the iOS app is a thin shell (SwiftUI) with Apple-only adapters (SwiftData/CloudKit).

⸻

## Architecture (package-first, Linux-first)

```
HomeCooked/
  Package.swift               # SwiftPM manifest
  project.yml                 # XcodeGen config (generates .xcodeproj)
  Makefile                    # Golden commands
  Packages/                   # Linux-compatible packages
    Domain/                   # Pure value types, IDs, validators (Linux)
      Sources/Domain/
        Models.swift          # Board, Column, Card, ChecklistItem, etc.
        Helpers.swift         # TagHelpers, ChecklistHelpers, IDFactory
    UseCases/                 # Business logic (Linux)
      Sources/UseCases/
        Reorder/              # CardReorderService with normalization
        Checklist/            # ChecklistOperations for lists
        Lookup/               # FuzzyMatcher and EntityLookup
    PersistenceInterfaces/    # Repository protocols (Linux)
      Sources/PersistenceInterfaces/
        BoardsRepository.swift
        ListsRepository.swift
        RecipesRepository.swift
        PersistenceError.swift
    PersistenceGRDB/          # SQLite/GRDB impl (Linux + Apple)
      Sources/PersistenceGRDB/
        GRDBBoardsRepository.swift
        GRDBListsRepository.swift
        GRDBRecipesRepository.swift
        Migrations.swift
        Records.swift
    ImportExport/             # Trello import, backup/restore (Linux)
      Sources/ImportExport/
        Trello/               # TrelloModels, TrelloMapper, TrelloImporter
        Backup/               # BackupExporter, BackupRestorer
    SyncInterfaces/           # Sync protocol (Linux)
      Sources/SyncInterfaces/
        SyncClient.swift
        SyncConflict.swift
    SyncNoop/                 # No-op sync (Linux)
    SyncCloudKit/             # CloudKit sync (Apple only)
  CLIs/                       # Command-line tools (Linux)
    hc-import/main.swift      # Import Trello boards
    hc-backup/main.swift      # Backup/restore data
    hc-migrate/main.swift     # Database migrations
  App/                        # iOS app (Apple only)
    HomeCookedApp.swift       # App entry point
    UI/
      Boards/BoardsListView.swift
      BoardDetail/BoardDetailView.swift, ColumnView.swift
      CardDetail/CardDetailView.swift
      Settings/SyncStatusView.swift
      Components/DragDropHandler.swift
    DI/                       # Dependency injection
      AppDependencyContainer.swift
      RepositoryProvider.swift
    PersistenceSwiftData/     # SwiftData adapter (Apple)
      Sources/PersistenceSwiftData/
        SwiftDataBoardsRepository.swift
        SwiftDataListsRepository.swift
        SwiftDataModels.swift
    Intents/                  # App Intents for Shortcuts
      AddCardIntent.swift
      AddListItemIntent.swift
      IntentsProvider.swift
  Tests/                      # Test suites
    DomainTests/
    UseCasesTests/
    PersistenceGRDBTests/     # Contract tests (Linux)
    PersistenceSwiftDataTests/# Contract tests (macOS)
    ImportExportTests/
    IntentsTests/
    SyncCloudKitTests/
    UITests/
    Fixtures/                 # Test data
      trello_minimal.json
      trello_full.json
  scripts/
    preflight.sh              # Verification + auto-fix
  .github/workflows/
    ci.yml                    # Linux + macOS CI
  .xcode-version              # Pin Xcode (16.1)
  .swift-version              # Pin Swift (6.0)
  README.md
  PLAN.md                     # Implementation tickets
  CHANGELOG.md
  DEVELOPMENT.md
```

**Key Design Decisions**:

1. **Linux-First**: Domain, UseCases, Import/Export, GRDB, and CLIs build on Linux
2. **Repository Pattern**: All data access through protocol interfaces
3. **Multiple Backends**: GRDB (Linux/macOS) and SwiftData (macOS) both implement same contracts
4. **Contract Tests**: Same test suite verifies all repository implementations
5. **Dependency Injection**: App uses RepositoryProvider to swap implementations
6. **XcodeGen**: Xcode project generated from project.yml, not committed to repo
7. **Actor-Based Services**: Thread-safe services using Swift actors (CardReorderService, ChecklistOperations, etc.)

⸻

## Ground rules

- **Privacy**: no secrets, provisioning profiles, or personal data in repo or logs.
- **Deps**: no new third-party deps without an explicit ticket.
- **Warnings as errors**. Keep public APIs documented.
- **Commits/PRs**: Conventional Commits (feat:, fix:, refactor:, test:). Include screenshots for UI.
- **Tests**: Unit + contract tests on Linux; UI/snapshot only on macOS.
- **Accessibility**: all interactive UI has VoiceOver labels; drag/drop exposes position updates.

⸻

## Environment & toolchain

- **Swift**: 6.0 (see `.swift-version`)
- **Xcode**: 16.1 (macOS only, see `.xcode-version`)
- **XcodeGen**: Used to generate Xcode project from `project.yml`
- **GRDB**: 6.29.0+ (SQLite with custom build flags on Linux CI)
- SwiftPM builds work on Linux and macOS
- Format/Lint: swiftformat + swiftlint (optional, not in CI yet)
- Make targets (golden commands):
  - `make preflight` → scripts/preflight.sh (auto-fix skeleton, verify toolchains)
  - `make test-linux` → swift build/test all Linux targets
  - `make test-macos` → xcodebuild build/test app + UI tests
  - `make lint` → swiftformat + swiftlint
  - `make import-sample` → run hc-import on fixtures
  - `make backup-sample` → run hc-backup to tmp

Preflight script (runs on Linux and macOS):
- Verifies Swift toolchain, SwiftPM build, presence of Package targets.
- If App/ is missing boot files, autogenerates:
  - HomeCookedApp.swift, ContentView.swift, Assets.xcassets, Bundle ID placeholder.
- Validates Xcode version (macOS), xcodebuild -list on workspace.
- Prints a single-line failure summary and exits non-zero if checks fail.
- If the same CI/job fails on the same step 3×, the loop-breaker instructs to run `make preflight --autofix`.

Skeleton creation snippet (excerpt):

```bash
# scripts/preflight.sh (excerpt)
if [ ! -f "App/HomeCookedApp.swift" ]; then
  mkdir -p App/UI
  cat > App/HomeCookedApp.swift <<'SWIFT'
import SwiftUI
@main struct HomeCookedApp: App {
  var body: some Scene { WindowGroup { ContentView() } }
}
SWIFT
  cat > App/UI/ContentView.swift <<'SWIFT'
import SwiftUI
struct ContentView: View { var body: some View { Text("HomeCooked") } }
#Preview { ContentView() }
SWIFT
fi
```

⸻

## CI (fail-fast, artifacts)

- **Linux job** (swift container):
  1. `make preflight`
  2. `swift build && swift test --parallel`
  3. Upload artifacts: test logs, any generated JSON fixtures.
- **macOS job**:
  1. `make preflight`
  2. `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' build`
  3. `xcodebuild ... test` (unit + UI/snapshot)
  4. Upload artifacts: XCTest logs, failure screenshots.

No continue-on-error. First failure wins, with a concise summary at tail of logs.

⸻

## Test strategy

- **Contract tests** against repository protocols (run on Linux & macOS). Same suite runs against:
  - PersistenceGRDB (Linux/macOS)
  - PersistenceSwiftData (macOS)
- **Fixtures for migrations**: keep a frozen V0 store (SQLite or JSON) in Tests/Fixtures/Persistence/V0/. Migration tests must load V0 and verify transformed data (e.g., sortKey initialization).
- **Property tests** for reorder/normalization (edge cases, concurrency).
- **UI snapshot tests** (macOS only) for primary screens; record mode behind RECORD_SNAPSHOTS=1.

⸻

## Domain model (Linux-friendly, pure value types)

```swift
// Packages/Domain/Sources/Domain/Models.swift
import Foundation

public struct BoardID: Hashable, Codable { public let rawValue: UUID }
public struct ColumnID: Hashable, Codable { public let rawValue: UUID }
public struct CardID: Hashable, Codable { public let rawValue: UUID }

public struct Board: Codable, Equatable {
  public var id: BoardID
  public var title: String
  public var columns: [ColumnID]
  public var createdAt: Date
  public var updatedAt: Date
}

public struct Column: Codable, Equatable {
  public var id: ColumnID
  public var board: BoardID
  public var title: String
  public var index: Int
  public var cards: [CardID]
}

public struct ChecklistItem: Codable, Equatable {
  public var id: UUID
  public var text: String
  public var isDone: Bool
  public var quantity: Double?
  public var unit: String?
  public var note: String?
}

public struct Card: Codable, Equatable {
  public var id: CardID
  public var column: ColumnID
  public var title: String
  public var details: String
  public var due: Date?
  public var tags: [String]
  public var checklist: [ChecklistItem]
  public var sortKey: Double
  public var createdAt: Date
  public var updatedAt: Date
}
```

⸻

## Repositories (interfaces → multiple impls)

```swift
// Packages/PersistenceInterfaces/.../BoardsRepository.swift
import Domain

public protocol BoardsRepository {
  func createBoard(_ b: Board) async throws
  func loadBoards() async throws -> [Board]
  func saveColumns(_ cols: [Column]) async throws
  func saveCards(_ cards: [Card]) async throws
  func deleteBoard(_ id: BoardID) async throws
}

public protocol ListsRepository {
  // CRUD for PersonalList (title + [ChecklistItem])
}

public protocol RecipesRepository {
  // CRUD for Recipe (ingredients: [ChecklistItem], methodMarkdown, tags)
}
```

- GRDB implementation (Linux/macOS) is the default repo in CLIs and contract tests.
- SwiftData implementation (Apple-only) lives in App/PersistenceSwiftData, mapping to/from Domain structs; opt-in for the app build.

⸻

## Reorder & normalization (UseCases)

```swift
public enum Reorder {
  public static func midpoint(after a: Double?, before b: Double?) -> Double {
    switch (a, b) {
    case let (.some(x), .some(y)): return (x + y) / 2
    case let (.some(x), .none):    return x + 1
    case let (.none, .some(y)):    return y - 1
    default:                       return 0
    }
  }
  public static func normalize(_ keys: inout [Double]) {
    for i in keys.indices { keys[i] = Double(i) }
  }
}
```

- Background normalization: debounce on idle; never block UI.

⸻

## Import/Export

- **Trello importer** maps: lists → Columns, cards → Cards, checklists → ChecklistItem, labels → tags, markdown desc → Card.details.
- **Backup/restore JSON**: { version, exportedAt, boards, lists, recipes } with merge/overwrite modes.
- **CLIs** provide end-to-end Linux workflows: hc-import, hc-backup, hc-migrate.

⸻

## Sync (optional, Apple-only)

- SyncInterfaces defines a minimal protocol.
- SyncNoop satisfies Linux builds.
- SyncCloudKit (Apple) implements private DB + sharing (Board-scoped).

⸻

## iOS app (thin)

- **SwiftUI screens**: Boards, BoardDetail (horizontal columns), CardDetail (checklist), Lists, Recipes.
- **Adapters**: PersistenceSwiftData conforms to repository protocols; CloudKit behind SyncCloudKit.
- **Intents**: Add card/list item via App Intents with fuzzy name lookup (pure Swift logic lives in UseCases).

⸻

## Agent runbook add-ons

- **Root-cause vs Symptom checklist** (prepend to every PR):
  1. Does `make preflight` pass (or did it auto-fix)?
  2. Failure type? (compile/link/test/lint) Attach the first failing log block.
  3. Repo invariants checked? (Package targets present, workspace sync for macOS)
- **Loop-breaker**: If the same failure repeats 3×, run `make preflight --autofix` then rebase.
- **Golden commands**: Every ticket shows the exact commands to run locally/CI to verify.

⸻

## Current Implementation Status

The HomeCooked project has completed all planned tickets. See [PLAN.md](./PLAN.md) for detailed ticket information and implementation history.

**Completed Features**:
- ✅ Domain models with type-safe IDs and helpers
- ✅ Repository pattern with GRDB and SwiftData implementations
- ✅ Contract tests ensuring implementation consistency
- ✅ Card reordering with midpoint algorithm and normalization
- ✅ Trello importer with deduplication
- ✅ Backup/restore with merge and overwrite modes
- ✅ Personal lists with checklist operations
- ✅ iOS UI with boards, columns, cards, and detail views
- ✅ Drag & drop with haptics and accessibility
- ✅ CloudKit private sync with LWW conflict resolution
- ✅ CloudKit sharing per board
- ✅ App Intents for Shortcuts integration (fuzzy name lookup)
- ✅ CI/CD with fail-fast Linux and macOS stages
- ✅ Comprehensive accessibility support

**What's Working**:
- Linux builds and tests for all core packages
- macOS iOS app builds with XcodeGen
- CLI tools: hc-import, hc-backup, hc-migrate
- Contract tests running against both GRDB and SwiftData
- GitHub Actions CI with artifact uploads

⸻

## Coding standards

- Swift API Guidelines; prefer small, composable types.
- Error handling: typed errors in repo interfaces; avoid fatalError.
- Logging: lightweight, redacted; no PII in logs or test artifacts.
- Normalization: run after idle; never block UI thread.
- Migrations: each adds indices; never drop columns in place—use shadow tables if needed.

⸻

## Working with This Codebase

### For AI Agents and Developers

You are working with a mature Swift codebase following Linux-first architecture. The project is feature-complete for its initial scope. When making changes:

**Core Principles**:
- Target Linux (SwiftPM) for business logic
- Keep Apple-only code behind adapters
- Produce small, tested changes
- No new dependencies without explicit approval
- Keep public APIs documented
- Warnings are errors

**Before You Start**:
1. Run `make preflight` to verify environment
2. Review [PLAN.md](./PLAN.md) to understand what's implemented
3. Check [CHANGELOG.md](./CHANGELOG.md) for recent changes
4. Read [DEVELOPMENT.md](./DEVELOPMENT.md) for toolchain setup

**Making Changes**:
1. Understand existing patterns in the codebase
2. Write tests alongside your code (contract tests for repos, unit tests for logic)
3. Use golden commands to validate:
   - `make preflight` - verify environment and structure
   - `make test-linux` - run Linux tests (fastest feedback)
   - `make test-macos` - run iOS tests (macOS only)
   - `make lint` - format and lint code
4. Update CHANGELOG.md with your changes
5. Include reproduction steps for bug fixes

**What's on Each Platform**:

✅ **Linux & macOS** (via SwiftPM):
- Domain models and helpers
- UseCases (reorder, checklist, fuzzy lookup)
- Import/Export (Trello, backup/restore)
- GRDB persistence and migrations
- CLIs (hc-import, hc-backup, hc-migrate)
- Contract tests for repositories
- Unit and property tests

🍎 **macOS Only**:
- iOS app UI (SwiftUI)
- SwiftData adapter
- CloudKit sync
- App Intents
- UI/snapshot tests
- Xcode project generation (via XcodeGen)

**Loop Breaker**: If the same failure repeats 3 times, run `make preflight ARGS="--autofix"` then commit.

⸻

## Common Tasks

### Adding a New Feature

1. **Decide where it belongs**:
   - Pure logic → UseCases (Linux-compatible)
   - Data access → Repository protocol + implementations
   - UI → App/UI (macOS only)

2. **Follow established patterns**:
   - Use repository protocols for data access
   - Keep business logic in UseCases
   - Use actors for thread-safe services
   - Write contract tests for repositories

3. **Test thoroughly**:
   - Unit tests for logic
   - Contract tests for repositories
   - UI tests for user-facing changes

4. **Update documentation**:
   - CHANGELOG.md for all changes
   - README.md if user-facing
   - PLAN.md if adding major features

### Fixing a Bug

1. Write a failing test that reproduces the bug
2. Fix the bug
3. Verify the test passes
4. Document the fix in CHANGELOG.md
5. Include reproduction steps in PR/commit

### Adding a New CLI Tool

1. Create directory: `CLIs/new-tool/`
2. Add `main.swift` with your implementation
3. Update Package.swift to add executable target
4. Add tests under Tests/
5. Update Makefile if needed
6. Document usage in README.md

⸻

## Definition of Done

Before considering work complete:

- ✅ Preflight passes locally (`make preflight`)
- ✅ Code compiles with warnings as errors
- ✅ Tests pass on target platform(s)
  - `make test-linux` for core logic
  - `make test-macos` for iOS features
- ✅ Lint/format pass (`make lint`)
- ✅ CHANGELOG.md updated
- ✅ Screenshots attached for UI changes
- ✅ Documentation updated if needed
