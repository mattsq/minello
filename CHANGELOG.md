# Changelog

All notable changes to the HomeCooked project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Domain package with core value types and models:
  - Type-safe ID wrappers: BoardID, ColumnID, CardID, ListID, RecipeID
  - Domain models: Board, Column, Card, ChecklistItem, PersonalList, Recipe
  - All models are Codable, Equatable, Hashable, and Sendable
  - Pure Swift with minimal Foundation dependencies (Date, UUID only)
- Domain helper utilities:
  - TagHelpers: sanitize tags (lowercase, alphanumeric + hyphens/underscores)
  - ChecklistHelpers: toggle, mark all done/undone, count completed, filter, reorder
  - IDFactory: factory methods for creating typed IDs
- Comprehensive unit tests for Domain package:
  - ModelsTests: tests for all domain models, Codable compliance, equality
  - HelpersTests: tests for tag sanitization, checklist operations, ID factories
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
- PersistenceInterfaces package with repository protocols:
  - BoardsRepository protocol for managing boards, columns, and cards
  - CRUD operations for all entity types
  - Query operations: search cards, find by tag, find by due date
  - Typed PersistenceError enum for error handling
- PersistenceGRDB package with SQLite/GRDB implementation:
  - Database schema v1 with boards, columns, and cards tables
  - Foreign key constraints with cascade delete
  - Indices on common query paths (created_at, column_id, sort_key, due date)
  - Full-text search support for card titles and details
  - ISO8601 date formatting for consistent date storage
  - GRDB record types mapping domain models to database rows
  - GRDBBoardsRepository implementing BoardsRepository protocol
  - HomeCookedMigrator with idempotent migrations
- hc-migrate CLI tool for database migrations:
  - List applied and pending migrations
  - Run pending migrations
  - Dry-run mode to preview changes
- Contract tests for BoardsRepository:
  - Comprehensive test suite covering all CRUD operations
  - Tests for cascade deletes (board → columns → cards)
  - Query tests (search, tag filtering, due date ranges)
  - Tests run against GRDB implementation (can be extended to SwiftData)
- Placeholder packages for future tickets:
  - UseCases, ImportExport, SyncInterfaces, SyncNoop
  - hc-import and hc-backup CLI stubs

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
