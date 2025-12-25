# HomeCooked Development Guide

## Overview

HomeCooked is a local-first task and collaboration app designed to replace Trello for home use. The project follows a package-first, Linux-first architecture where 80-90% of the code builds and tests on Linux via SwiftPM, with the iOS app serving as a thin shell.

## Toolchain Requirements

### Swift

- **Version**: 5.10 (see `.swift-version`)
- **Installation**:
  - **macOS**: Install Xcode 16.0+ or Swift toolchain from swift.org
  - **Linux**: Download from [swift.org/download](https://swift.org/download/)

Verify installation:
```bash
swift --version
```

### Xcode (macOS only)

- **Version**: 16.0 (see `.xcode-version`)
- **Installation**: Download from the Mac App Store or [developer.apple.com](https://developer.apple.com/xcode/)

Verify installation:
```bash
xcodebuild -version
```

## Getting Started

### 1. Clone and Verify

```bash
git clone <repository-url>
cd minello
make preflight
```

The preflight check will:
- Verify Swift and Xcode versions
- Check Package.swift structure
- Auto-generate iOS app skeleton if missing
- Validate package targets
- Test SwiftPM build

If preflight fails, run with auto-fix:
```bash
make preflight ARGS="--autofix"
```

### 2. Build the Project

**Linux/macOS (SwiftPM)**:
```bash
swift build
```

**macOS (Xcode)**:
```bash
# Generate Xcode project if needed
swift package generate-xcodeproj

# Or use xcodebuild directly with SPM
xcodebuild -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### 3. Run Tests

**Linux tests** (Domain, UseCases, Persistence, Import/Export):
```bash
make test-linux
```

**macOS tests** (including iOS app and UI tests):
```bash
make test-macos
```

## Project Structure

```
HomeCooked/
├── Package.swift              # SwiftPM package manifest
├── Makefile                   # Build automation
├── scripts/
│   └── preflight.sh          # Pre-build verification script
├── Packages/                  # Linux-compatible packages
│   ├── Domain/               # Pure value types, IDs, validators
│   ├── UseCases/             # Business logic (reorder, search, lists)
│   ├── PersistenceInterfaces/# Repository protocols
│   ├── PersistenceGRDB/      # SQLite/GRDB implementation
│   ├── ImportExport/         # Trello import, JSON backup/restore
│   ├── SyncInterfaces/       # Sync protocol
│   └── SyncNoop/             # No-op sync client
├── CLIs/                      # Command-line tools
│   ├── hc-import/            # Trello importer
│   ├── hc-backup/            # Backup/restore
│   └── hc-migrate/           # Database migrations
├── App/                       # iOS app (macOS only)
│   ├── HomeCookedApp.swift   # App entry point
│   ├── UI/                   # SwiftUI screens
│   ├── PersistenceSwiftData/ # SwiftData adapter
│   └── Intents/              # App Intents
└── Tests/                     # Test suites
    ├── DomainTests/
    ├── UseCasesTests/
    ├── PersistenceGRDBTests/
    └── Fixtures/             # Test data
```

## Development Workflow

### Golden Commands

These commands should work at any point in development:

```bash
# Verify environment and structure
make preflight

# Run Linux tests (fastest)
make test-linux

# Run all tests including iOS (macOS only)
make test-macos

# Lint and format code
make lint

# Import sample Trello data
make import-sample

# Create backup
make backup-sample
```

### Adding a New Package

1. Create directory: `mkdir -p Packages/NewPackage/Sources/NewPackage`
2. Add package manifest files
3. Update `Package.swift` to include the new target
4. Run `make preflight` to verify

### Adding a New CLI

1. Create directory: `mkdir -p CLIs/new-cli`
2. Add `main.swift`
3. Update `Package.swift` to add executable target
4. Build: `swift build`
5. Run: `swift run new-cli`

### iOS Development (macOS only)

The iOS app lives in `App/` and uses SwiftUI. It's a thin shell that:
- Uses repository protocols to access data (SwiftData or GRDB)
- Implements UI screens for boards, lists, recipes
- Provides App Intents for Siri/Shortcuts

**Running the app**:
```bash
# Via Xcode
open HomeCooked.xcworkspace  # if available
# or
swift package generate-xcodeproj && open HomeCooked.xcodeproj

# Via xcodebuild
xcodebuild -scheme HomeCooked \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

## Testing Strategy

### Contract Tests

Repository protocols have contract test suites that run against multiple implementations:
- `PersistenceGRDB` (Linux + macOS)
- `PersistenceSwiftData` (macOS only)

This ensures all implementations behave identically.

### Unit Tests

Pure business logic in `Domain` and `UseCases` has comprehensive unit tests that run on Linux.

### UI Tests

SwiftUI screens have snapshot tests (macOS only) for visual regression testing.

**Recording snapshots**:
```bash
RECORD_SNAPSHOTS=1 make test-macos
```

### Property Tests

Critical algorithms (reorder, normalization) use property-based testing for edge cases.

## CI/CD

The project uses a fail-fast CI approach:

1. **Linux Job**: SwiftPM build and test
2. **macOS Job**: iOS build and test

No `continue-on-error`. First failure stops the pipeline.

**Loop Breaker**: If the same CI step fails 3 times, run:
```bash
make preflight ARGS="--autofix"
git add -A
git commit -m "fix: apply preflight auto-fixes"
```

## Code Standards

### Swift Style

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftFormat and SwiftLint (configs in repo)
- Warnings are treated as errors
- Document all public APIs

### Error Handling

- Use typed errors in repository interfaces
- Avoid `fatalError` (except for programmer errors)
- Never silently swallow errors

### Logging

- Use lightweight, structured logging
- Redact personally identifiable information (PII)
- No secrets in logs or test artifacts

### Git Workflow

- **Commits**: Use [Conventional Commits](https://www.conventionalcommits.org/)
  - `feat:` new feature
  - `fix:` bug fix
  - `refactor:` code restructuring
  - `test:` test additions/changes
  - `docs:` documentation
- **Pull Requests**: Include screenshots for UI changes
- **Branches**: Use descriptive names (e.g., `feature/cloudkit-sync`, `fix/reorder-bug`)

## Dependencies

The project minimizes third-party dependencies:

- **GRDB.swift**: SQLite database toolkit (Linux + macOS)

**Adding new dependencies requires explicit approval via ticket.**

## Performance

### Normalization

Card sort keys are normalized in the background to prevent floating-point precision issues:
- Debounced on idle
- Never blocks UI thread
- Runs automatically when gaps become too small

### Database

- Foreign keys enabled
- Indices on common queries
- Migrations are idempotent

## Accessibility

All interactive UI must:
- Have VoiceOver labels
- Support Dynamic Type
- Provide alternative actions to drag-and-drop
- Expose position updates for screen readers

## Privacy

- No provisioning profiles or secrets in repo
- No personal data in logs or commits
- CloudKit sharing is opt-in
- All sync happens in private database by default

## Troubleshooting

### Preflight Fails

Run with auto-fix to resolve common issues:
```bash
make preflight ARGS="--autofix"
```

### Build Fails on Linux

Ensure you're using Swift 5.10:
```bash
swift --version
```

### Xcode Issues

1. Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
2. Regenerate project: `swift package generate-xcodeproj`
3. Verify Xcode version matches `.xcode-version`

### Tests Fail

1. Check that fixtures are up to date
2. Verify migrations have run: `swift run hc-migrate --dry-run`
3. Run contract tests individually to isolate failures

## Resources

- [CLAUDE.md](./CLAUDE.md) - Comprehensive project documentation and tickets
- [Swift.org](https://swift.org/) - Swift language documentation
- [GRDB.swift](https://github.com/groue/GRDB.swift) - Database documentation

## Questions?

Check the [CLAUDE.md](./CLAUDE.md) file for detailed architecture, domain model, and implementation guidance.
