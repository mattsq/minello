# Project

"HomeCooked" — a small, local-first task/collab app to replace Trello at home. Core types: Board → Column → Card, ChecklistItem, plus PersonalList (grocery/packing) and Recipe (ingredients + markdown method).
Principle: 80–90% of the code builds/tests on Linux via SwiftPM; the iOS app is a thin shell (SwiftUI) with Apple-only adapters (SwiftData/CloudKit).

⸻

## Architecture (package-first, Linux-first)

```
HomeCooked/
  Package.swift
  Packages/
    Domain/                # Pure value types, IDs, validators (Linux)
    UseCases/              # Reorder logic, search, list ops, markdown (Linux)
    PersistenceInterfaces/ # Repository protocols + errors (Linux)
    PersistenceGRDB/       # SQLite/GRDB implementation (Linux + Apple)
    ImportExport/          # Trello importer; JSON backup/restore (Linux)
    SyncInterfaces/        # Sync protocol only (Linux)
    SyncNoop/              # No-op sync client (Linux)
    # Apple-only (optional packages)
    SyncCloudKit/          # CloudKit impl behind SyncInterfaces (Apple)
  CLIs/
    hc-import/             # swift run hc-import <trello.json> ...
    hc-backup/
    hc-migrate/
  App/                     # iOS app (SwiftUI), adapters, DI, UI tests (Apple)
    PersistenceSwiftData/  # SwiftData adapter conforming to repos (Apple)
    UI/
    Intents/
  Scripts/
    preflight.sh
  .xcode-version           # pin Xcode
  .swift-version           # pin Swift toolchain
  README.md
  CHANGELOG.md
  DEVELOPMENT.md
```

Key idea: Domain, UseCases, Import/Export, GRDB persistence, and CLIs are Linux-buildable. The iOS app wires the same protocols to SwiftData/CloudKit adapters.

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

- SwiftPM builds for Linux work.
- Pin toolchains:
  - `.swift-version`: e.g., 5.10 (or current stable; keep updated in DEVELOPMENT.md).
  - `.xcode-version`: e.g., 16.x (macOS only).
- Format/Lint: swiftformat + swiftlint with repo configs.
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

## Tickets (ready for agents)

Each ticket lists Goal, Constraints, Files, Deliverables, Acceptance (with commands). Tackle in order unless stated.

### 0) Project preflight & app skeleton

**Goal**: Add scripts/preflight.sh and wire make preflight. Autogenerate iOS app skeleton if missing; verify toolchains.
**Constraints**: Works on Linux & macOS; prints one-line summary; exits non-zero on failure.
**Files**: Scripts/preflight.sh, Makefile, DEVELOPMENT.md, .swift-version, .xcode-version.
**Deliverables**: Passing preflight on fresh clone and on a broken tree (after autofix).
**Acceptance**:
- `make preflight` succeeds on Linux (no iOS build).
- On macOS, `make preflight && xcodebuild -list` succeeds.

⸻

### 1) Domain models & validators

**Goal**: Implement Domain structs + helpers (ID factories, tag sanitizer, checklist utilities).
**Constraints**: Pure Swift; no Foundation types in helpers beyond Date/UUID.
**Files**: Packages/Domain/...
**Deliverables**: Compiles + unit tests.
**Acceptance**: `make test-linux` green; tests under DomainTests/*.

⸻

### 2) Repository interfaces + GRDB v1 (boards/columns/cards)

**Goal**: Define repos + implement GRDB schema v1 with indices; CRUD and query helpers.
**Constraints**: Foreign keys ON; migrations idempotent; use ISO8601 dates.
**Files**: PersistenceInterfaces/*, PersistenceGRDB/*
**Deliverables**: GRDB repo + migration v1 + contract tests.
**Acceptance**:
- `swift test --filter BoardsRepositoryContractTests` passes (Linux).
- `hc-migrate --dry-run` prints applied migrations.

⸻

### 3) Reorder service (midpoint + idle normalization)

**Goal**: Implement CardReorderService in UseCases; no persistence details.
**Constraints**: Thread-safe; property tests around extremes (duplicate keys, large deltas).
**Files**: UseCases/Reorder/*
**Deliverables**: Unit + property tests.
**Acceptance**: `swift test --filter ReorderTests` passes (Linux).

⸻

### 4) Trello importer + CLI (hc-import)

**Goal**: Decode Trello JSON; map to Domain; write via repo; print summary.
**Constraints**: Idempotent (dedupe by name+createdAt heuristic); tolerate variant exports.
**Files**: ImportExport/Trello/*, CLIs/hc-import/*, Tests/Fixtures/trello_*.json
**Deliverables**: CLI + unit tests with fixtures.
**Acceptance**:
- `swift run hc-import Tests/Fixtures/trello_minimal.json --db /tmp/hc.db` exits 0.
- `swift test --filter TrelloImporterTests` passes.

⸻

### 5) Backup/export & restore + CLI (hc-backup)

**Goal**: Versioned JSON export and merge/overwrite restore.
**Constraints**: Stable schema; progress logging.
**Files**: ImportExport/Backup/*, CLIs/hc-backup/*
**Deliverables**: Round-trip tests.
**Acceptance**: `swift test --filter BackupRoundTripTests` passes.

⸻

### 6) Lists (PersonalList) & checklist component (Linux logic)

**Goal**: Checklist operations (toggle all, reorder, quantities/units) in UseCases; repo CRUD for lists.
**Constraints**: Bulk actions confirm when >10 items (policy only; UI later).
**Files**: UseCases/Checklist/*, PersistenceInterfaces/ListsRepository.swift, PersistenceGRDB/Lists/*
**Deliverables**: Contract tests for Lists repo.
**Acceptance**: `swift test --filter ListsRepositoryContractTests`.

⸻

### 7) iOS UI skeleton (Boards/Columns/Cards)

**Goal**: SwiftUI skeleton screens; wire to repos via DI (use GRDB or SwiftData via feature flag).
**Constraints**: Accessibility labels; drag/drop hooks; haptics on drop.
**Files**: App/UI/*, App/DI/*
**Deliverables**: Buildable app; smoke UI tests.
**Acceptance**: On macOS: `make test-macos` green; snapshot tests recorded with RECORD_SNAPSHOTS=1.

⸻

### 8) SwiftData adapter (Apple-only)

**Goal**: PersistenceSwiftData that conforms to repos, mapping Domain ↔ SwiftData models.
**Constraints**: Prefer explicit deletes over .cascade; unidirectional relationships.
**Files**: App/PersistenceSwiftData/*
**Deliverables**: Contract tests run also against SwiftData (macOS).
**Acceptance**: macOS test matrix runs contract suite for GRDB and SwiftData.

⸻

### 9) CloudKit private sync (optional)

**Goal**: Implement SyncCloudKit behind SyncInterfaces; private DB only; LWW conflicts.
**Constraints**: App works offline; status UI.
**Files**: Packages/SyncCloudKit/*, App/UI/Settings/SyncStatusView.swift
**Deliverables**: Manual harness + unit tests mapping statuses.
**Acceptance**: macOS CI runs sync unit tests; manual doc SyncManualTests.md.

⸻

### 10) CloudKit sharing per Board (optional)

**Goal**: Share a Board and children; revoke; badge participants count.
**Constraints**: Board-scoped sharing only.
**Files**: App/UI/BoardDetail/Share/*
**Deliverables**: Integration tests (macOS) + snapshot of "Shared" pill.
**Acceptance**: macOS UI tests pass.

⸻

### 11) App Intents (add list item / add card)

**Goal**: "Add milk to Groceries"; "Add 'Pay strata' to 'Home' → 'To Do'".
**Constraints**: Fuzzy name lookup from UseCases; return success phrases.
**Files**: App/Intents/*
**Deliverables**: Unit tests for lookup; intent performs action.
**Acceptance**: macOS unit tests pass; Shortcuts shows intents.

⸻

### 12) CI hardening (fail-fast + artifacts)

**Goal**: Add GitHub Actions (or equivalent) with Linux then macOS stages; artifact uploads; no continue-on-error.
**Constraints**: One-line failure summary; cache DerivedData selectively.
**Files**: .github/workflows/ci.yml
**Deliverables**: Green CI on clean clone.
**Acceptance**: CI passes; on failure, artifacts visible.

⸻

### 13) Accessibility pass (DnD + labels)

**Goal**: VoiceOver announces column and position; actions accessible without drag.
**Constraints**: Provide alternatives (Move Up/Down actions).
**Files**: App/UI/...
**Deliverables**: UI tests for accessibility identifiers.
**Acceptance**: Snapshot + XCTests pass.

⸻

## Coding standards

- Swift API Guidelines; prefer small, composable types.
- Error handling: typed errors in repo interfaces; avoid fatalError.
- Logging: lightweight, redacted; no PII in logs or test artifacts.
- Normalization: run after idle; never block UI thread.
- Migrations: each adds indices; never drop columns in place—use shadow tables if needed.

⸻

## Prompts for code agents

### System prompt (for code-gen agents)

You are a senior Swift engineer. Target Linux (SwiftPM) for most work and keep Apple-only code behind adapters. Produce small, tested PRs. Use the golden commands in each ticket to validate locally. When a failure repeats, run `make preflight --autofix` and rebase. No new dependencies unless the ticket says so. Keep public APIs documented. Warnings are errors.

### Task prompt template

```
Implement ticket: <TITLE>

Context:
- See Agents.md ticket <#> for requirements and acceptance.
- Most targets build on Linux via SwiftPM. Apple-only code lives under App/.
- Repositories live under PersistenceInterfaces with GRDB and SwiftData adapters.

Deliver:
- Code + tests under the listed files.
- Update CHANGELOG.md.
- Include failure reproduction steps if fixing a bug.

Validate with:
- make preflight
- make test-linux (or make test-macos for UI)
- make lint

Do not:
- Change unrelated files.
- Add dependencies.
```

⸻

## What agents can do on Linux (quick map)

- ✅ Domain, UseCases, Import/Export, GRDB persistence, migrations, CLIs, contract tests.
- 🔶 CI authoring (Linux job), schema docs, fixtures.
- ⛔ iOS UI, SwiftData, CloudKit (macOS only).

⸻

## Definition of Done (per ticket)

- Preflight passes locally.
- Code compiles with warnings as errors.
- Tests (unit/contract; UI where applicable) pass on required platform(s).
- Lint/format pass.
- Artifacts/screenshots attached for UI changes.
- CHANGELOG.md updated.
