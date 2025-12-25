# HomeCooked

A local-first task and collaboration app for home use, designed to replace Trello with a privacy-focused, self-contained solution.

## Features

- 📋 **Boards, Columns, and Cards** - Organize tasks with familiar Trello-like structure
- ✅ **Smart Checklists** - Grocery lists, packing lists, and recipe ingredients with quantities
- 🍳 **Recipe Management** - Store recipes with ingredients and markdown instructions
- 📱 **iOS Native** - Built with SwiftUI for a native iOS experience
- 🔄 **Import from Trello** - Migrate your existing Trello boards
- 💾 **Backup/Restore** - Export and restore your data as JSON
- 🔒 **Privacy First** - All data stored locally, optional iCloud sync
- 🐧 **Linux-First Development** - 80-90% of code builds and tests on Linux

## Quick Start

### Prerequisites

- **Swift 5.10+** (see `.swift-version`)
- **Xcode 16.0+** (macOS only, see `.xcode-version`)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd minello

# Run preflight checks
make preflight

# If preflight fails, auto-fix issues
make preflight ARGS="--autofix"
```

### Build

**Linux/macOS (Command Line)**:
```bash
swift build
```

**macOS (iOS App)**:
```bash
make test-macos
```

### Run Tests

```bash
# Linux tests (Domain, UseCases, Persistence)
make test-linux

# macOS tests (including iOS app)
make test-macos
```

## Project Structure

```
HomeCooked/
├── Packages/           # Linux-compatible Swift packages
│   ├── Domain/         # Core domain models
│   ├── UseCases/       # Business logic
│   ├── Persistence*/   # Data storage
│   ├── ImportExport/   # Trello import, backups
│   └── Sync*/          # Sync protocols
├── CLIs/               # Command-line tools
│   ├── hc-import/      # Import Trello boards
│   ├── hc-backup/      # Backup/restore data
│   └── hc-migrate/     # Run database migrations
├── App/                # iOS app (SwiftUI)
└── Tests/              # Test suites
```

## Architecture

HomeCooked follows a **package-first, Linux-first** architecture:

- **Core packages** build on Linux via SwiftPM (no Apple dependencies)
- **iOS app** is a thin SwiftUI shell that uses the core packages
- **Multiple persistence backends**: GRDB (SQLite) for Linux, SwiftData for iOS
- **Repository pattern** with contract tests to ensure consistency
- **Command-line tools** for import, backup, and migration

This design enables:
- Fast iteration on business logic (Linux CI)
- Consistent behavior across platforms
- Easy testing without iOS simulator
- Potential Android support in the future

## Core Concepts

### Boards → Columns → Cards

The familiar Trello structure:
- **Board**: Top-level container (e.g., "Home Projects")
- **Column**: Lists within a board (e.g., "To Do", "In Progress", "Done")
- **Card**: Individual tasks with title, details, due date, tags, and checklists

### Smart Checklists

Checklist items support:
- **Quantities and units** - "2 lbs flour"
- **Notes** - Additional context per item
- **Toggle all** - Bulk completion actions
- **Reordering** - Custom sort order

### Recipes

Recipes combine:
- **Ingredients** as checklist items with quantities
- **Method** in markdown format
- **Tags** for categorization and search

### Personal Lists

Standalone lists (not tied to boards) for:
- Grocery shopping
- Packing lists
- Quick to-do items

## Command-Line Tools

### Import from Trello

```bash
swift run hc-import trello_export.json --db ~/homecooked.db
```

### Backup Your Data

```bash
swift run hc-backup --db ~/homecooked.db --output backup.json
```

### Restore from Backup

```bash
swift run hc-backup --restore backup.json --db ~/homecooked.db --mode merge
```

### Database Migrations

```bash
swift run hc-migrate --db ~/homecooked.db --dry-run
```

## Development

See [DEVELOPMENT.md](./DEVELOPMENT.md) for detailed development instructions.

### Golden Commands

```bash
make help          # Show all available commands
make preflight     # Verify environment and structure
make test-linux    # Run Linux tests
make test-macos    # Run iOS tests (macOS only)
make lint          # Run code formatting and linting
```

## Documentation

- **[CLAUDE.md](./CLAUDE.md)** - Comprehensive project guide and implementation tickets
- **[DEVELOPMENT.md](./DEVELOPMENT.md)** - Developer setup and workflow
- **[Agents.md](./Agents.md)** - Additional agent-specific guidance

## Contributing

1. Run `make preflight` to verify your environment
2. Create a feature branch
3. Make your changes with tests
4. Run `make test-linux` (or `make test-macos` for UI)
5. Run `make lint` to format code
6. Submit a pull request

### Commit Conventions

Use [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` new feature
- `fix:` bug fix
- `refactor:` code restructuring
- `test:` test changes
- `docs:` documentation

## Privacy & Security

- **No telemetry** - Your data stays on your device
- **Optional sync** - iCloud sync is opt-in only
- **Open source** - Audit the code yourself
- **Local-first** - Works offline by default

## License

[To be determined]

## Roadmap

See [CLAUDE.md](./CLAUDE.md) for detailed implementation tickets:

- [x] ~~#0: Project preflight & app skeleton~~
- [ ] #1: Domain models & validators
- [ ] #2: Repository interfaces + GRDB
- [ ] #3: Reorder service
- [ ] #4: Trello importer
- [ ] #5: Backup/export & restore
- [ ] #6: Lists & checklist component
- [ ] #7: iOS UI skeleton
- [ ] #8: SwiftData adapter
- [ ] #9: CloudKit private sync (optional)
- [ ] #10: CloudKit sharing (optional)
- [ ] #11: App Intents
- [ ] #12: CI hardening
- [ ] #13: Accessibility pass

---

**HomeCooked** - Made with ❤️ for home task management
