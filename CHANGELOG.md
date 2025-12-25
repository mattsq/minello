# Changelog

All notable changes to the HomeCooked project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Project preflight script (`scripts/preflight.sh`) with auto-fix capability
  - Verifies Swift toolchain (version 5.10)
  - Verifies Xcode version on macOS (version 16.0)
  - Validates Package.swift structure
  - Auto-generates iOS app skeleton if missing
  - Tests SwiftPM build
  - Single-line failure summary
- Makefile with golden commands:
  - `make preflight` - Run preflight checks
  - `make test-linux` - Build and test Linux targets
  - `make test-macos` - Build and test iOS app (macOS only)
  - `make lint` - Run code formatting and linting
  - `make import-sample` - Import sample Trello data
  - `make backup-sample` - Create sample backup
  - `make clean` - Clean build artifacts
- Package.swift manifest defining project structure:
  - Domain, UseCases, PersistenceInterfaces packages
  - PersistenceGRDB with GRDB.swift dependency
  - ImportExport, SyncInterfaces, SyncNoop packages
  - CLIs: hc-import, hc-backup, hc-migrate
- iOS app skeleton (auto-generated):
  - HomeCookedApp.swift - App entry point
  - ContentView.swift - Initial view
  - Info.plist - App metadata
  - Assets.xcassets - Asset catalog structure
- Development documentation:
  - README.md - Project overview and quick start
  - DEVELOPMENT.md - Detailed development guide
  - CHANGELOG.md - This file
- Toolchain version pinning:
  - .swift-version (5.10)
  - .xcode-version (16.0)

### Changed

- N/A

### Deprecated

- N/A

### Removed

- N/A

### Fixed

- N/A

### Security

- N/A

## Release History

No releases yet. This is the initial development version.

---

**Legend:**
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security improvements
