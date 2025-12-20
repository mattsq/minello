# HomeCooked

A home-cooked, local-first iOS app to replace Trello for family use.

## Overview

HomeCooked is a SwiftUI + SwiftData app providing kanban boards, personal lists, and recipe management with optional CloudKit sync and sharing.

**Core entities**: Board → Column → Card, ChecklistItem, PersonalList (grocery/packing), Recipe (ingredients + method markdown)

## Requirements

- iOS 17.0+
- Xcode 15.4+
- Swift 5.10+
- macOS 14+ (for development)

## Project Status

⚠️ **Project is in early development**

Current status:
- ✅ SwiftData models and repository layer implemented
- ✅ Unit, migration, and integration tests created
- ✅ CI/CD pipeline configured
- ⏳ Xcode project needs to be created (see below)
- ⏳ UI implementation pending

## Getting Started

### Prerequisites for macOS Development

This project requires Xcode and can only be built on macOS. The repository includes:

1. **Swift Source Files**: Located in `HomeCooked/` directory
2. **Swift Package**: `HomeCooked/Package.swift` for SPM compatibility
3. **CI Pipeline**: `.github/workflows/ci.yml` for automated testing

### Creating the Xcode Project (Required)

**The Xcode project file needs to be created on macOS:**

1. Open Xcode
2. Create a new iOS App project
3. Name it "HomeCooked"
4. Choose SwiftUI for Interface and SwiftData for Storage
5. Set minimum deployment target to iOS 17.0
6. Save the project in the `HomeCooked/` directory
7. Add existing Swift files to the project:
   - `App/ModelContainerFactory.swift`
   - `Persistence/Models/*.swift`
   - `Persistence/Repositories/*.swift`
   - `Persistence/Migrations/*.swift`
8. Create test targets and add files from `Tests/` directory
9. Configure build settings:
   - Treat warnings as errors
   - Swift Language Version: 5.10
   - Enable strict concurrency checking

### Building and Testing

Once the Xcode project is created:

```bash
# Build the project
xcodebuild -scheme HomeCooked \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build

# Run tests
xcodebuild -scheme HomeCooked \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test

# Lint and format
swiftformat --config HomeCooked/Tooling/swiftformat.yml HomeCooked/
swiftlint lint --config HomeCooked/Tooling/swiftlint.yml --path HomeCooked/ --strict
```

## Development Workflow

This project uses [Beads](https://github.com/steveyegge/beads) for git-native issue tracking.

### Task Management with Beads

**Quick setup:**

```bash
# Install beads (if not already installed)
curl -sSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash

# Initialize beads (first time only)
bd init  # or /root/go/bin/bd init on Claude Code Web
```

**Common commands:**

```bash
# View ready tasks
bd ready

# Create a new issue
bd create "Issue title" -d "Description"

# Update issue status
bd update <issue-id> --status in_progress

# Close an issue
bd close <issue-id> --reason "Completion note"

# Sync with git (may fail in Claude Code Web - auto-sync happens on writes)
bd sync
```

**For Claude Code Web environments:**

Beads works great but requires specific flags due to sandboxing. Use:
- Full path: `/root/go/bin/bd` instead of just `bd`
- Add `--no-db --json` for read operations (list, ready, show, blocked)
- Regular commands work for writes (create, update, close)

See `CLAUDE.md` for detailed Claude Code Web setup instructions.

### Agent Instructions

For AI agents working on this project:
- See `CLAUDE.md` for comprehensive agent instructions
- All tasks tracked in Beads (`.beads/issues.jsonl`)
- Follow strict quality bar: compile with warnings as errors, comprehensive tests
- Commit messages follow Conventional Commits (feat:, fix:, test:, etc.)

## Continuous Integration

The project uses GitHub Actions for CI:

- **Build**: Compiles the project on macOS runners
- **Test**: Runs unit, integration, and UI tests
- **Lint**: Enforces SwiftFormat and SwiftLint rules (strict mode)

All jobs must pass for PR approval. Failed snapshot tests are uploaded as artifacts.

## Project Structure

```
HomeCooked/
├── App/                     # App entry point and DI
│   └── ModelContainerFactory.swift
├── Features/                # Feature modules (TBD)
│   ├── Boards/
│   ├── BoardDetail/
│   ├── CardDetail/
│   ├── Lists/
│   └── Recipes/
├── DesignSystem/           # Shared UI components (TBD)
├── Persistence/
│   ├── Models/             # SwiftData @Model types
│   ├── Repositories/       # Repository pattern implementations
│   ├── Migrations/         # Schema migrations
│   └── Sync/              # CloudKit sync (TBD)
├── ImportExport/          # Trello import, backup (TBD)
├── Intents/               # App Intents / Shortcuts (TBD)
├── Tests/
│   ├── Unit/              # Unit tests
│   ├── Integration/       # Integration tests
│   ├── UI/               # UI/snapshot tests (TBD)
│   └── Fixtures/         # Test fixtures
└── Tooling/
    ├── swiftformat.yml   # SwiftFormat config
    └── swiftlint.yml     # SwiftLint config
```

## Roadmap

See `.beads/issues.jsonl` or run `bd list` for the complete task list.

**Major features planned:**
1. ✅ SwiftData models + repository layer + migrations
2. ⏳ Kanban board UI with drag-and-drop
3. ⏳ Checklist component (quantities, units, notes)
4. ⏳ Trello JSON importer
5. ⏳ CloudKit private sync
6. ⏳ CloudKit sharing for boards
7. ⏳ App Intents & Shortcuts
8. ⏳ Backup/export & restore

## Contributing

This is a personal/family project, but follows best practices:

- **Privacy & safety**: No secrets, no analytics, no third-party SDKs
- **Quality**: Warnings as errors, comprehensive tests
- **Formatting**: SwiftFormat + SwiftLint (strict)
- **Documentation**: Update CHANGELOG.md for all changes

## License

See LICENSE file for details.

## Questions?

For agent-specific workflows and detailed ticket specs, see `CLAUDE.md`.
