// App/DI/GRDBRepositoryProvider.swift
// GRDB-based repository provider implementation

import Foundation
import GRDB
import PersistenceGRDB
import PersistenceInterfaces

/// GRDB-based repository provider
@MainActor
final class GRDBRepositoryProvider: RepositoryProvider {
    private let dbQueue: DatabaseQueue

    let boardsRepository: BoardsRepository
    let listsRepository: ListsRepository
    let recipesRepository: RecipesRepository
    let searchRepository: SearchRepository

    init(databaseURL: URL) throws {
        // Create database queue
        self.dbQueue = try DatabaseQueue(path: databaseURL.path)

        // Run migrations
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)

        // Initialize repositories
        self.boardsRepository = GRDBBoardsRepository(dbQueue: dbQueue)
        self.listsRepository = GRDBListsRepository(dbQueue: dbQueue)
        self.recipesRepository = GRDBRecipesRepository(dbQueue: dbQueue)
        self.searchRepository = GRDBSearchRepository(
            dbQueue: dbQueue,
            boardsRepo: boardsRepository,
            listsRepo: listsRepository,
            recipesRepo: recipesRepository
        )
    }

    /// Create an in-memory database for previews and testing
    static func inMemory() throws -> GRDBRepositoryProvider {
        let dbQueue = try DatabaseQueue()

        // Run migrations
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)

        return try GRDBRepositoryProvider(dbQueue: dbQueue)
    }

    private init(dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue
        self.boardsRepository = GRDBBoardsRepository(dbQueue: dbQueue)
        self.listsRepository = GRDBListsRepository(dbQueue: dbQueue)
        self.recipesRepository = GRDBRecipesRepository(dbQueue: dbQueue)
        self.searchRepository = GRDBSearchRepository(
            dbQueue: dbQueue,
            boardsRepo: boardsRepository,
            listsRepo: listsRepository,
            recipesRepo: recipesRepository
        )
    }
}
