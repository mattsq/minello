# Changelog

All notable changes to the HomeCooked project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial SwiftData model layer with `@Model` types for Board, Column, Card, ChecklistItem, PersonalList, and Recipe
- Repository pattern with protocols for BoardsRepository, ListsRepository, and RecipesRepository
- SwiftData implementations for all repositories with async CRUD operations
- ModelContainerFactory with support for persistent and in-memory containers
- Card.sortKey field for drag-and-drop ordering support
- CardSortKeyMigration for v0→v1 migration with automatic sortKey initialization
- Comprehensive unit tests for repositories (BoardsRepositoryTests)
- Migration tests (CardMigrationTests) validating sortKey initialization
- Integration tests (PersistenceIntegrationTests) for round-trip persistence and cascade delete
- SwiftFormat configuration for consistent code formatting
- SwiftLint configuration with strict rules and warnings as errors
- Project directory structure following feature-based organization

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

## [0.0.0] - 2025-12-20

### Added
- Project initialization
- Beads issue tracking integration
- Development workflow documentation in CLAUDE.md
