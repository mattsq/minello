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

    init(databaseURL: URL) throws {
        // Create database queue
        self.dbQueue = try DatabaseQueue(path: databaseURL.path)

        // Run migrations
        try dbQueue.write { db in
            try Migrations.runMigrations(db)
        }

        // Initialize repositories
        self.boardsRepository = GRDBBoardsRepository(dbQueue: dbQueue)
        self.listsRepository = GRDBListsRepository(dbQueue: dbQueue)
        self.recipesRepository = GRDBRecipesRepository(dbQueue: dbQueue)
    }

    /// Create an in-memory database for previews and testing
    static func inMemory() throws -> GRDBRepositoryProvider {
        let dbQueue = try DatabaseQueue()
        try dbQueue.write { db in
            try Migrations.runMigrations(db)
        }

        return try GRDBRepositoryProvider(dbQueue: dbQueue)
    }

    private init(dbQueue: DatabaseQueue) throws {
        self.dbQueue = dbQueue
        self.boardsRepository = GRDBBoardsRepository(dbQueue: dbQueue)
        self.listsRepository = GRDBListsRepository(dbQueue: dbQueue)
        self.recipesRepository = GRDBRecipesRepository(dbQueue: dbQueue)
    }
}
