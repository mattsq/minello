# Agents.md

## Project

Home-cooked, local-first iOS app to replace Trello for family use. Core entities: Board → Column → Card, ChecklistItem; plus PersonalList (grocery/packing) and Recipe (ingredients + method markdown). Tech: SwiftUI + SwiftData, optional CloudKit sync/sharing.

⸻

## Ground rules for agents

• **Privacy & safety**: Never commit secrets, provisioning profiles, or personal data. Don't add analytics or third-party SDKs.
• **Quality bar**: All code compiles with warnings as errors, passes tests, runs on iOS 17+.
• **Formatting**: SwiftFormat + SwiftLint (strict). No magic strings; prefer enum/let.
• **Tests**: Add unit + snapshot tests for each UI, plus integration tests for persistence.
• **Docs**: Update this file's "Deliverables" checklist per ticket; keep CHANGELOG.md.
• **Commits/PRs**: Conventional Commits (feat:, fix:, refactor:, test:). Include screenshots for UI PRs.
• **No scope creep**. If unsure, implement the minimal version described in the ticket.
• **Task tracking**: Use beads (bd) for all task and issue tracking. Create issues for discovered work, update status as you progress, track dependencies between tasks.

⸻

## Repo layout (expected)

```
HomeCooked/
  App/                 // App entry, DI, model container
  Features/
    Boards/
    BoardDetail/
    CardDetail/
    Lists/
    Recipes/
  DesignSystem/
  Persistence/         // Repositories, migrations
  ImportExport/        // Trello import; backup/export
  Intents/             // App Intents / Shortcuts
  Tests/
    Unit/
    UI/
    Integration/
    Fixtures/
  Tooling/
    swiftlint.yml
    swiftformat.yml
  .beads/              // Beads issue tracker (git-backed)
    beads.db           // SQLite cache
    issues.jsonl       // Issue data (version controlled)
    config.yaml        // Beads configuration
  Agents.md            // Pointer to CLAUDE.md
  CLAUDE.md            // This file - agent instructions
  GEMINI.md            // Pointer to CLAUDE.md
  CHANGELOG.md
  LICENSE
  README.md
```

⸻

## Tooling & scripts agents can run

• **Build**: `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' build`
• **Test**: `xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' test`
• **Lint/format**: `swiftformat . && swiftlint --strict`
• **Snapshots (record)**: set RECORD_SNAPSHOTS=1 env var for UI test target

### Beads (bd) - Issue Tracking

• **Find ready work**: `$HOME/go/bin/bd ready` - Show unblocked, open tasks
• **Create issue**: `$HOME/go/bin/bd create "Issue title" -d "Description" -p 0` (priority 0-4, 0=highest)
• **List issues**: `$HOME/go/bin/bd list --status open --json`
• **Show details**: `$HOME/go/bin/bd show <issue-id>`
• **Update status**: `$HOME/go/bin/bd update <issue-id> --status in_progress`
• **Add dependency**: `$HOME/go/bin/bd dep add <blocked-issue> <blocking-issue>` (blocking-issue must complete first)
• **Close issue**: `$HOME/go/bin/bd close <issue-id> --reason "Completion note"`
• **Sync with git**: `$HOME/go/bin/bd sync` (auto-syncs to .beads/issues.jsonl)

⸻

## Data model sketch (for reference)

SwiftData @Model types: Board(id,title,columns,createdAt,updatedAt), Column(id,title,index,cards,board), Card(id,title,details,due,tags:[String],checklist:[ChecklistItem],column,sortKey,createdAt,updatedAt), ChecklistItem(id,text,isDone,quantity?,unit?,note?), PersonalList(id,title,items), Recipe(id,title,ingredients,methodMarkdown,tags).

⸻

## Beads workflow for agents

This project uses **beads** (bd) for distributed, git-backed issue tracking. All issues live in `.beads/issues.jsonl` and sync via git.

### Core workflow

1. **Start session**: Run `$HOME/go/bin/bd ready --json` to find available work
2. **Claim task**: Update status to in_progress: `$HOME/go/bin/bd update <id> --status in_progress`
3. **Discover new work**: Create issues immediately when you find bugs, missing features, or tech debt
4. **Track dependencies**: Use `$HOME/go/bin/bd dep add` to chain tasks (e.g., "write tests" depends on "implement feature")
5. **Complete work**: Close with context: `$HOME/go/bin/bd close <id> --reason "Fixed in commit abc123"`
6. **Sync regularly**: Run `$HOME/go/bin/bd sync` before git push (auto-syncs in most cases)

### Best practices

• **JSON output**: Always use `--json` flag for programmatic parsing in scripts
• **Issue naming**: Issues auto-named as `minello-<hash>` (e.g., minello-a3f2dd)
• **Priority levels**: 0=critical, 1=high, 2=medium (default), 3=low, 4=backlog
• **Status values**: open, in_progress, closed, blocked
• **Dependencies prevent duplicates**: Before starting work, check if an issue exists or is blocked
• **Create issues liberally**: Better to track than forget; close duplicates if found
• **Tie to commits**: Reference issue IDs in commit messages (e.g., "fix: resolve minello-a3f2dd")

### Agent collaboration patterns

• **Serial work**: Agent A creates issue → Agent B claims via `bd ready` → marks in_progress → completes
• **Parallel work**: Multiple agents can work on independent issues (no blocking deps)
• **Discovery chains**: Agent finds issue X needs prerequisite Y → creates both, links with `bd dep add X Y`
• **Hand-offs**: Closing issue with detailed reason provides context for next agent/session

### Integration with tickets below

The numbered tickets (1-8) below are the main feature deliverables. Use beads to:
- Break tickets into subtasks if needed (e.g., ticket 1 → multiple issues for models, repos, migrations)
- Track bugs found during implementation
- Manage test failures and fixes
- Document tech debt discovered while working

⸻

## Tickets (ready to run)

Each ticket includes: Goal, Constraints, Files to touch, Deliverables, Acceptance tests.

⸻

### 1) Scaffold SwiftData models + repository layer + v0→v1 migration

**Goal**: Implement domain models above, plus repository protocols (so we can swap storage later). Include a migration adding Card.sortKey: Double (v1).

**Constraints**
• SwiftData @Model for all entities.
• Repositories: BoardsRepository, ListsRepository, RecipesRepository with async CRUD.
• Provide in-memory ModelContainer factory for tests.
• Add lightweight MigrationPlanner that ensures sortKey exists and is initialized per list order.

**Files to touch**
• Persistence/Models/*.swift
• Persistence/Repositories/*.swift
• Persistence/Migrations/*.swift
• App/ModelContainerFactory.swift

**Deliverables**
• Compiling models & repos.
• Unit tests for repositories and migration.

**Acceptance tests**
• Unit: BoardsRepositoryTests.testCreateBoardWithColumnsAndCards()
• Unit: CardMigrationTests.testSortKeyInitializedAscending()
• Integration: PersistenceIntegrationTests.testRoundTripCreateFetchDelete()

⸻

### 2) Kanban board UI with drag-and-drop across columns (sortKey midpoint strategy)

**Goal**: Horizontally scrollable board with columns; drag cards to reorder within/between columns using floating sortKey (midpoint insertion), with background normalization.

**Constraints**
• Accessible drag handles; VoiceOver reads position.
• Normalization service keeps keys near integers asynchronously (no visible jump).
• Haptics on successful drop.

**Files to touch**
• Features/BoardDetail/BoardDetailView.swift
• Features/BoardDetail/ColumnView.swift
• Features/BoardDetail/CardRow.swift
• Features/BoardDetail/CardReorderService.swift
• DesignSystem/Haptics.swift

**Deliverables**
• Smooth DnD across columns; persistence updated.

**Acceptance tests**
• Unit: CardReorderServiceTests.testMidpointInsertionWithinColumn()
• Unit: CardReorderServiceTests.testCrossColumnMovePreservesRelativeOrder()
• UI Snapshot: BoardDetailSnapshots.testKanbanLightDark()
• Integration: DragAndDropIntegrationTests.testDropUpdatesRepository()

⸻

### 3) Checklist component (quantities, units, notes) + bulk actions

**Goal**: Reusable checklist view for Cards and PersonalList with add/edit/reorder, quantity/unit fields, "Check all / Uncheck all".

**Constraints**
• Inline add row; swipe to delete; reorder via drag.
• Numeric input for quantity; unit as freeform text for now.
• Bulk actions in toolbar; confirmation for "Uncheck all" if >10 items.

**Files to touch**
• Features/Shared/Checklist/ChecklistView.swift
• Features/Shared/Checklist/ChecklistItemEditor.swift
• Features/Lists/ListsView.swift (use the component)

**Deliverables**
• Component integrated in Card detail and Lists tab.

**Acceptance tests**
• Unit: ChecklistReducerTests.testToggleAllBehaviour()
• UI Snapshot: ChecklistSnapshots.testEditingStates()
• Integration: ListsIntegrationTests.testListPersistsAcrossAppRestarts()

⸻

### 4) Trello JSON importer (one-shot)

**Goal**: Import a Trello board export into our models: lists → columns, cards → cards, checklists → items, labels → tags, markdown desc → Card.details.

**Constraints**
• File import via UIDocumentPickerViewController.
• Idempotent: don't duplicate on repeat import; detect by name+createdAt heuristic.
• Handle missing/archived lists gracefully.

**Files to touch**
• ImportExport/Trello/TrelloModels.swift
• ImportExport/Trello/TrelloImporter.swift
• Features/Boards/BoardsView.swift (Add "Import Trello" button)

**Fixtures**
• Tests/Fixtures/trello_minimal.json (provided in this ticket)
• Tests/Fixtures/trello_with_checklists.json

**Deliverables**
• Import flow + success/failure toasts; summary sheet with counts.

**Acceptance tests**
• Unit: TrelloImporterTests.testParsesMinimalFixture()
• Unit: TrelloImporterTests.testChecklistAndLabelsMapped()
• Integration: ImportFlowTests.testImportCreatesBoardAndColumns()

**Fixture (minimal)**

```json
{
  "lists": [{"id":"L1","name":"To Do","closed":false},{"id":"L2","name":"Done","closed":false}],
  "cards": [
    {"id":"C1","idList":"L1","name":"Buy milk","desc":"2L full cream","closed":false},
    {"id":"C2","idList":"L2","name":"Call plumber","desc":"","closed":false}
  ],
  "checklists": [{
    "id":"CL1","name":"Groceries","checkItems":[
      {"state":"incomplete","name":"Milk 2L"},
      {"state":"complete","name":"Bread"}
    ]}],
  "labels": [{"id":"lab1","name":"Home"}]
}
```

⸻

### 5) CloudKit private sync (Phase 1)

**Goal**: Enable SwiftData CloudKit sync in the private database; background push sync; conflict policy last-write-wins.

**Constraints**
• Use ModelConfiguration(cloudKitContainerIdentifier:) with iCloud.com.yourdomain.HomeCooked.
• Sync is optional: app must work fully offline.
• Background refresh task to nudge sync.
• Settings toggle "Use iCloud Sync" (default on) with basic status indicator.

**Files to touch**
• App/ModelContainerFactory.swift
• App/Settings/SettingsView.swift
• Persistence/Sync/CloudKitSyncStatus.swift

**Deliverables**
• Sync on two simulators with same Apple ID works.

**Acceptance tests**
• Integration (manual harness): SyncManualTests.md executed by CI job (prints logs).
• Unit: CloudKitSyncStatusTests.testStatusMapping()

⸻

### 6) CloudKit sharing for a single Board (Phase 2)

**Goal**: Share an individual Board with family (iCloud sharing UI); badge shared status; allow revoke.

**Constraints**
• Use CloudKit Sharing via UICloudSharingController bridged from SwiftUI.
• Only the Board and its transitive children are shared; others remain private.
• Show pill "Shared" and number of participants.

**Files to touch**
• Features/BoardDetail/Share/BoardShareCoordinator.swift
• Features/BoardDetail/BoardDetailView.swift (share button)
• Persistence/Sharing/SharingRepository.swift

**Deliverables**
• Invite flow works; new participant sees live data after accept.

**Acceptance tests**
• Integration: SharingIntegrationTests.testShareCreatesShareRecord()
• UI Snapshot: ShareBadgeSnapshots.testSharedPill()

⸻

### 7) App Intents & Shortcuts (add list item / add card)

**Goal**: Voice/Shortcuts: "Add milk to Groceries" and "Add a card 'Pay strata' to board 'Home' in column 'To Do'".

**Constraints**
• App Intents with entity lookups for Board/Column/List by name (fuzzy match).
• Return success phrases and open the app to the target item when tapped.

**Files to touch**
• Intents/AddListItemIntent.swift
• Intents/AddCardIntent.swift
• Intents/Entities.swift

**Deliverables**
• Intents visible in Shortcuts app; perform actions reliably.

**Acceptance tests**
• Unit: IntentsTests.testFuzzyLookupPrefersExactMatch()
• Integration: IntentsIntegrationTests.testAddListItemCreatesChecklistItem()

⸻

### 8) Backup/export & restore (JSON)

**Goal**: Manual backup to JSON (all data) and restore (merge or overwrite). Share sheet for export.

**Constraints**
• Schema versioned JSON; top-level { version, exportedAt, boards, lists, recipes }.
• Restore options: Merge (upsert by id) or Overwrite (wipe then import).
• Large data guarded by progress UI.

**Files to touch**
• ImportExport/Backup/BackupExporter.swift
• ImportExport/Backup/BackupImporter.swift
• Features/Settings/BackupView.swift

**Deliverables**
• Round-trip export/import retains counts and relationships.

**Acceptance tests**
• Unit: BackupTests.testRoundTripIdentity()
• Integration: BackupIntegrationTests.testMergeDoesNotDuplicate()
• UI Snapshot: BackupSnapshots.testBackupViewStates()

⸻

## CI (lightweight)

Create .github/workflows/ci.yml:
• Jobs: build, test, lint.
• Cache derived data; run unit + UI tests on iOS simulator.
• Upload snapshots on failure as artifacts.

**Acceptance test**
• CI green on a clean clone: ci.yml runs build+test+lint.

⸻

## Definition of Done (per ticket)

• Code compiles (warnings as errors).
• New/changed code covered by tests.
• Lint/format pass.
• Screenshots for UI changes in PR.
• CHANGELOG.md entry.
• Beads issues updated: close completed work, create issues for discovered follow-ups, sync before push.

⸻

## Prompts for agents

### System prompt (use for code-gen agents)

You are a senior iOS engineer. Produce small, composable PRs. Prefer clarity over cleverness. Follow Swift API Design Guidelines, SOLID, and dependency injection where needed. Always include tests, update CI if necessary, and keep public APIs documented. Do not add third-party deps without explicit instruction.

Use beads (bd) to track your work: claim tasks with `bd ready`, update status as you progress, create issues for discovered work, link dependencies, and close with detailed completion notes. Issues live in `.beads/issues.jsonl` and sync via git.

### Task prompt template

```
Implement ticket: <TITLE>

Context:
- See Agents.md ticket <#> for requirements and acceptance tests.
- Target iOS 17+, Swift 5.10+, SwiftUI + SwiftData.
- Repositories live under Persistence/Repositories.
- Use beads for task tracking: $HOME/go/bin/bd

Workflow:
1. Check for ready work: bd ready --json
2. Create beads issue for this ticket (or claim existing)
3. Update to in_progress: bd update <id> --status in_progress
4. Implement (create sub-issues for bugs/tech debt discovered)
5. Run tests, lint, build
6. Close issue: bd close <id> --reason "Completed in PR #X"
7. Sync: bd sync

Deliver:
- Code changes under the listed files.
- Tests that pass headlessly.
- Update CHANGELOG.md.
- Beads issues closed/created as needed.

Do not:
- Change unrelated files.
- Add dependencies or new targets.
```

⸻

## Notes & pitfalls

• **SwiftData + CloudKit conflicts**: acceptable LWW for family usage; we normalize sortKey to reduce merge churn.
• **DnD & SwiftUI Lists**: prefer LazyVStack + custom reorder to avoid List quirks.
• **Trello export variance**: older exports differ—keep JSON decoding tolerant (optional fields).
• **Beads + git workflow**: Issues auto-sync to `.beads/issues.jsonl` on CRUD operations. Always `bd sync` before `git push` to ensure issue state is committed. If multiple agents/sessions work concurrently, git merge handles JSONL conflicts via beads merge driver.
• **Beads binary location**: Use `$HOME/go/bin/bd` as full path since `bd` may not be in PATH. Consider adding to PATH for convenience: `export PATH=$PATH:$HOME/go/bin`

⸻

If you want, I can also generate the initial folder scaffolding, SwiftLint/SwiftFormat configs, and empty test files matching the names above so your agents can start committing against a real tree.
