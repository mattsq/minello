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
- Swift Package Manager package definition (Package.swift) for build infrastructure
- GitHub Actions CI/CD pipeline with build, test, and lint jobs
- Comprehensive README.md with project setup, development workflow, and CI documentation
- Beads issue tracking fully integrated with detailed task management
- Kanban board UI with horizontally scrollable columns (BoardDetailView)
- Drag-and-drop card reordering within and across columns using floating sortKey midpoint insertion
- CardReorderService with background normalization to prevent sortKey precision issues
- CardRow component with accessible drag handles and VoiceOver support
- ColumnView component with drop zone indicators and haptic feedback
- Haptics utility for success, error, and selection feedback during drag-and-drop
- Comprehensive unit tests for CardReorderService (midpoint insertion, cross-column moves, normalization)
- UI snapshot tests for BoardDetailView in light and dark modes
- Integration tests for drag-and-drop persistence (DragAndDropIntegrationTests)

### Changed
- N/A

### Deprecated
- N/A

### Removed
- N/A

### Fixed
- **Cascade Delete CI Failures (Final Fix)**: Fixed `testCascadingDelete` failures in CI by removing the re-fetch pattern in `BoardsRepository.delete()` and `ListsRepository.delete()`. The root cause was object identity mismatch in SwiftData 15.4 (CI environment) - re-fetching created new object instances, leaving original objects as orphans. Solution: Use the passed-in object directly and rely on SwiftData's lazy loading for relationships. Updated `testCascadingDelete` to verify NO orphaned children exist (using broad queries) rather than checking specific object IDs, making the test robust to SwiftData version differences.
- Ensured BoardsRepository wires relationships before relying on SwiftData cascades so deletes don't leave orphans or crash CI (`minello-727`, `minello-729`).
- Brought BoardDetailView back into SwiftFormat compliance (import sort, operator spacing, preview indentation) to clear lint failures (`minello-727`).
- Hydrated BoardsRepository fetches by filtering columns/cards/checklists in-memory with persistentModelID comparisons (plus verbose logging) to keep CI tests from returning empty relationships, and reformatted BoardDetail previews plus supporting files to satisfy SwiftFormat (`minello-6rk`).
- Added UUID-based fallback filtering + fetch descriptors (with expanded logging) so BoardsRepository columns/cards/checklists still hydrate correctly on CI's older SwiftData stack (`minello-bbq`).
- Persisted parent UUIDs on Column/Card/ChecklistItem (with a new SchemaV3 migration stage) so repository fetches can fall back to explicit IDs without re-triggering SwiftData relationships, preventing CI's `Board.columns.getter` crash (`minello-aq8`).
- Switched BoardsRepository fetches to primary `FetchDescriptor` predicates on the stored parent UUIDs (with relationship-based filtering as a final fallback) so CI no longer needs to hydrate entire stores before filtering, eliminating the lingering `Board.columns.getter` crashes (`minello-d6f`).
- Added descriptor retries that target `parent?.persistentModelID` and `parent?.id` whenever the stored UUID predicate returns zero rows so CI's SwiftData build still hydrates BoardsRepository columns/cards/checklists without flaking (`minello-lci`).
- Reverted the descriptor retries to the broader fetch descriptors when no rows are returned (while keeping the UUID + relationship filtering in-memory) because SwiftData 15.4 crashes when predicates reference `parent?.persistentModelID` / `.id` (`minello-0zd`).

### Security
- N/A

### Notes
- ⚠️ Xcode project file needs to be created on macOS before the app can be built (issue minello-hwp)
- ⚠️ CI pipeline is configured but will not run successfully until Xcode project is created

## [0.0.0] - 2025-12-20

### Added
- Project initialization
- Beads issue tracking integration
- Development workflow documentation in CLAUDE.md
