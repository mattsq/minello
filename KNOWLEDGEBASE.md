# Knowledge Base

## TL;DR

**HomeCooked** is a local-first iOS app (SwiftUI + SwiftData) replacing Trello for family use. Core features: kanban boards, personal lists (grocery/packing), recipes with optional CloudKit sync. Built with strict quality requirements: warnings as errors, comprehensive tests, SwiftFormat/SwiftLint enforcement. Uses **beads** for git-native issue tracking. Currently in early development—models and repositories complete, UI pending.

**Stack**: Swift 5.10+, SwiftUI, SwiftData, iOS 17+, Xcode 15.4+
**Build**: macOS only (Xcode project needed)
**Next**: See `CONTINUITY.md` for current focus, `CLAUDE.md` for tickets, `.beads/issues.jsonl` for active tasks

---

## Project Map

```
HomeCooked/
├── App/                        # Entry point, DI, ModelContainerFactory
├── Persistence/
│   ├── Models/                # SwiftData @Model entities (Board, Column, Card, etc.)
│   ├── Repositories/          # Repository pattern (async CRUD, testable)
│   ├── Migrations/            # Schema migrations (v0→v1: Card.sortKey)
│   └── Sync/                  # CloudKit sync (planned)
├── Features/                  # Feature modules (UI components—mostly TBD)
│   ├── Boards/, BoardDetail/, CardDetail/
│   ├── Lists/, Recipes/
├── DesignSystem/              # Shared UI components (planned)
├── ImportExport/              # Trello import, backup/restore (planned)
├── Intents/                   # App Intents / Shortcuts (planned)
├── Tests/
│   ├── Unit/                  # Unit tests for models, repos, business logic
│   ├── Integration/           # End-to-end persistence tests
│   ├── UI/                    # Snapshot tests (planned)
│   └── Fixtures/              # Test data (JSON, mock models)
├── Tooling/                   # swiftformat.yml, swiftlint.yml
├── .beads/                    # Git-native issue tracking
│   ├── issues.jsonl          # Version-controlled issues
│   └── beads.db              # SQLite cache (not committed)
├── docs/                      # Documentation (CI feedback, ADRs)
├── scripts/                   # Build/maintenance scripts
└── .github/workflows/         # CI: build, test, lint on macOS runners
```

**Key files**:
- `CLAUDE.md` – Agent instructions, tickets, beads workflow, prompts
- `CONTINUITY.md` – Session-to-session state, current focus, decisions
- `KNOWLEDGEBASE.md` – This file (durable knowledge)
- `README.md` – User/dev quickstart
- `CHANGELOG.md` – Version history (update on every change)

---

## Build / Test / Run

**Prerequisites**: macOS 14+, Xcode 15.4+, Swift 5.10+

### First-time setup

1. **Create Xcode project** (repo has source files but no `.xcodeproj` yet):
   - New iOS App, SwiftUI + SwiftData, min iOS 17.0
   - Add existing files from `HomeCooked/` subdirectories
   - Configure: warnings as errors, strict concurrency
2. **Install beads** (optional, for task tracking):
   ```bash
   curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
   bd init  # or /root/go/bin/bd init in Claude Code Web
   ```

### Build

> ℹ️ Run all `xcodebuild` commands from the `HomeCooked/` subdirectory (where `HomeCooked.xcodeproj` lives) or add `-project HomeCooked/HomeCooked.xcodeproj`; running from the repo root fails with "does not contain an Xcode project".

```bash
xcodebuild -scheme HomeCooked \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### Test

```bash
xcodebuild -scheme HomeCooked \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

**Snapshot tests** (when implemented): set `RECORD_SNAPSHOTS=1` env var to record new baselines.

### Lint / Format

```bash
swiftformat --config HomeCooked/Tooling/swiftformat.yml HomeCooked/
swiftlint lint --config HomeCooked/Tooling/swiftlint.yml --path HomeCooked/ --strict
```

**CI enforces strict mode**: all warnings are errors; linting failures block PRs.

---

## Conventions

### Code style
- **SwiftFormat + SwiftLint**: Strict enforcement. Run before commit.
- **Naming**: Clear, non-abbreviated. Prefer `currentWorkingDirectory` over `cwd`.
- **No magic strings**: Use enums or `let` constants.
- **Dependency injection**: Repository protocols, testable containers.
- **Swift API Design Guidelines**: Follow Apple's conventions (clarity over brevity).

### Testing
- **Coverage**: Every feature needs unit + integration tests; UI features need snapshot tests.
- **Test structure**: Arrange-Act-Assert; use descriptive test names (`testMidpointInsertionWithinColumn()`).
- **Fixtures**: Reusable test data in `Tests/Fixtures/`.
- **In-memory ModelContainer**: Use `ModelContainerFactory.inMemory()` for isolated tests.

### Git / Commits
- **Conventional Commits**: `feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`.
- **Example**: `feat: add sortKey midpoint insertion for card reordering`.
- **No secrets**: Never commit provisioning profiles, API keys, `.env` files.
- **Beads integration**: Reference issue IDs in commit messages (e.g., `fix: resolve minello-a3f2dd`).

### Documentation
- **CHANGELOG.md**: Update for every user-facing or architectural change.
- **Inline docs**: Public APIs documented; avoid redundant comments for self-evident code.
- **ADRs**: Use for lasting architectural decisions (see `docs/adr/`).

### Error handling
- **Expect async/await**: Repository methods throw; handle at call sites.
- **User-facing errors**: Show toast/alert with actionable message.
- **Developer errors**: Prefer `precondition` / `fatalError` for impossible states.

---

## Architecture & Decisions

### Major design choices

1. **SwiftData over Core Data**: Modern API, better SwiftUI integration, automatic CloudKit schema mapping. (See ADR template in `docs/adr/` for format.)
2. **Repository pattern**: Decouple persistence from UI; enables in-memory testing and future storage swaps.
3. **Floating sortKey (Double)**: Cards use midpoint insertion for O(1) reorder without shifting; background normalization keeps values clean. Reduces CloudKit sync churn.
4. **Git-native issue tracking (beads)**: No external service dependency; JSONL merges cleanly; works offline.
5. **CloudKit private + sharing**: Phase 1 = private sync; Phase 2 = per-board sharing with family. Last-write-wins for conflicts (acceptable for family use).
6. **Local-first**: App fully functional offline; sync is optional and opportunistic.

### Technology constraints
- **iOS 17+ only**: Leverage latest SwiftUI APIs, SwiftData maturity.
- **No third-party SDKs**: No analytics, crash reporting, or external dependencies. Privacy-first.
- **macOS-only build**: Xcode required; CI runs on macOS runners.

**Top ADRs** (once written):
- 0001: Repository pattern for persistence abstraction
- 0002: Floating sortKey with midpoint insertion
- 0003: Beads for issue tracking (git-native, distributed)

---

## Common Workflows

### Add a new feature

1. **Find or create issue**: `bd ready` or `bd create "Feature title" -d "Description" -p 1`
2. **Claim**: `bd update <id> --status in_progress`
3. **Branch**: Work on feature branch (e.g., `claude/add-feature-xyz`)
4. **Implement**: Models → Repositories → UI → Tests
5. **Test**: Unit + integration; snapshot if UI changes
6. **Lint**: `swiftformat . && swiftlint --strict`
7. **Commit**: Conventional Commits format, reference issue ID
8. **PR**: Use template checklist (update KNOWLEDGEBASE, CONTINUITY, ADR if needed)
9. **Close issue**: `bd close <id> --reason "Completed in PR #X"`

### Fix a bug

1. **Create issue**: `bd create "Bug: ..." -d "Reproduction steps" -p 0` (high priority)
2. **Add test**: Write failing test that reproduces bug
3. **Fix**: Make test pass
4. **Verify**: Ensure no regressions; check related tests
5. **Commit**: `fix: <description> (closes minello-<id>)`
6. **Close issue**: `bd close <id> --reason "Fixed in commit <hash>"`

### Add a dependency (avoid if possible)

1. **Justify**: Explain in issue or ADR why built-in solution won't work
2. **Review**: Discuss privacy, license, maintenance burden
3. **Add**: Via SPM or Xcode; lock version
4. **Document**: Update KNOWLEDGEBASE, CHANGELOG
5. **ADR**: Write decision record if it's a major dependency

### Release (future)

- Tag version: `v0.1.0`
- Update CHANGELOG with all changes since last tag
- TestFlight build (manual, not automated yet)
- Sync beads issues: ensure all closed

---

## Pitfalls / Sharp Edges

### SwiftData + CloudKit conflicts
- **Last-write-wins** for family use: acceptable data loss risk for non-critical app.
- **SortKey churn**: Frequent reordering → many sync ops. Mitigation: background normalization rounds keys to near-integers.

### SwiftData cascade deletes
- **Board deletions**: `ModelContext.delete(board)` alone left orphaned columns/cards in CI; repository now manually deletes children before deleting the board.
- **Checklist chains**: Deleting a card still cascades into ChecklistItem because each card delete explicitly triggers SwiftData's `.cascade` relationship.

### Drag-and-drop in SwiftUI Lists
- **Prefer LazyVStack + custom gesture**: List's built-in reorder has quirks (especially cross-section).
- **Test on device**: Simulator doesn't replicate all touch behaviors.

### Trello export variance
- **Older Trello exports differ**: Keep JSON decoding tolerant (all fields optional, fallbacks).
- **Archived lists**: May or may not appear in export; filter by `closed: false`.

### Beads in Claude Code Web
- **Use full path**: `/root/go/bin/bd` (not in PATH)
- **Read ops**: Add `--no-db --json` to avoid SQLite locking (e.g., `bd --no-db ready --json`)
- **Write ops**: Regular commands work (`bd create`, `bd update`, `bd close`)
- **Avoid**: `bd doctor` (long-running), `bd graph` (crashes in --no-db), `bd dep tree` (locking errors), `bd sync` (auto-sync on writes handles it)

### Xcode project not in repo
- **Deliberate**: Source files committed, `.xcodeproj` is macOS-generated.
- **First-time setup**: Manual Xcode project creation required (see Build section).
- **CI**: Uses Xcode project created in CI script (TODO: document CI project setup).

### Test failures on CI
- **Snapshots**: Upload as artifacts if tests fail; regenerate with `RECORD_SNAPSHOTS=1`.
- **Timing**: Integration tests may flake due to SwiftData async; add waits or retries.

### Warnings as errors
- **Strict**: Deprecation warnings block builds.
- **Fix fast**: Update APIs immediately to avoid blocking team.

### Don't do
- **Don't** add analytics/tracking (privacy requirement).
- **Don't** commit secrets (`.env`, provisioning profiles, API keys).
- **Don't** relax linting (SwiftFormat/SwiftLint configs are strict by design).
- **Don't** skip tests ("it compiles" ≠ "it works").
- **Don't** batch beads updates (create issues immediately when discovered; close as completed).

---

## Glossary

- **beads (bd)**: Git-native issue tracker; issues stored in `.beads/issues.jsonl`.
- **sortKey**: Floating-point field on Card for stable ordering without array indices; uses midpoint insertion.
- **midpoint insertion**: Place new sortKey between neighbors' keys (e.g., insert between 1.0 and 3.0 → 2.0).
- **normalization**: Background task that periodically resets sortKeys to near-integers (reduces drift, fewer CloudKit updates).
- **ModelContainer**: SwiftData's persistence stack; can be in-memory (tests) or SQLite (app).
- **Repository pattern**: Abstraction over SwiftData; protocol-based, enables testing and future swaps.
- **CloudKit private database**: iCloud storage visible only to the signed-in user; auto-syncs SwiftData.
- **CloudKit sharing**: Per-record sharing (e.g., one Board) with family via UICloudSharingController.
- **Conventional Commits**: Structured commit format (`type: description`); enables changelog generation.
- **ADR**: Architecture Decision Record; documents "why" for major technical choices.
- **HomeCooked**: The app name (also the Xcode module name).

---

## Updating This File

**When to update KNOWLEDGEBASE.md**:
- Architectural decision made (also create ADR)
- New convention adopted (style, testing, naming)
- Pitfall discovered (recurring bug, sharp edge)
- Major directory structure change
- Build/test/run commands change

**How to update**:
1. Edit the relevant section (keep concise, bullet-friendly)
2. If it's a decision, also create an ADR in `docs/adr/`
3. If it's session-specific, put it in `CONTINUITY.md` first; promote to KNOWLEDGEBASE if durable
4. Commit with message: `docs: update KNOWLEDGEBASE with [topic]`

**Keep it short**: If a section grows beyond ~15 lines, consider splitting or moving detail to an ADR/doc.
