// PersistenceGRDB/Sources/PersistenceGRDB/GRDBRecipesRepository.swift
// GRDB implementation of RecipesRepository

import Domain
import Foundation
import GRDB
import PersistenceInterfaces

/// GRDB-based implementation of RecipesRepository
public final class GRDBRecipesRepository: RecipesRepository {
    private let dbQueue: DatabaseQueue

    /// Creates a new GRDB repository
    /// - Parameter dbQueue: The GRDB database queue
    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    /// Creates a new in-memory database for testing
    /// - Returns: A new repository with an in-memory database
    public static func inMemory() throws -> GRDBRecipesRepository {
        let dbQueue = try DatabaseQueue()
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBRecipesRepository(dbQueue: dbQueue)
    }

    /// Creates a new file-based database
    /// - Parameter path: Path to the database file
    /// - Returns: A new repository with a file-based database
    public static func onDisk(at path: String) throws -> GRDBRecipesRepository {
        let dbQueue = try DatabaseQueue(path: path)
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBRecipesRepository(dbQueue: dbQueue)
    }

    // MARK: - Recipe Operations

    public func createRecipe(_ recipe: Recipe) async throws {
        try await dbQueue.write { db in
            let record = try RecipeRecord(from: recipe)
            try record.insert(db)
        }
    }

    public func loadRecipes() async throws -> [Recipe] {
        try await dbQueue.read { db in
            let records = try RecipeRecord
                .order(Column("created_at").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func loadRecipe(_ id: RecipeID) async throws -> Recipe {
        try await dbQueue.read { db in
            let idString = id.rawValue.uuidString
            guard let record = try RecipeRecord.fetchOne(db, key: idString) else {
                throw PersistenceError.notFound("Recipe with ID \(idString) not found")
            }
            return try record.toDomain()
        }
    }

    public func updateRecipe(_ recipe: Recipe) async throws {
        do {
            try await dbQueue.write { db in
                let record = try RecipeRecord(from: recipe)
                try record.update(db)
            }
        } catch let error as GRDB.RecordError {
            // GRDB throws RecordError.recordNotFound when trying to update a non-existent record
            throw PersistenceError.notFound("Recipe with ID \(recipe.id.rawValue.uuidString) not found")
        } catch {
            // Other database errors
            throw PersistenceError.databaseError(error.localizedDescription)
        }
    }

    public func deleteRecipe(_ id: RecipeID) async throws {
        try await dbQueue.write { db in
            let idString = id.rawValue.uuidString
            let deleted = try RecipeRecord.deleteOne(db, key: idString)
            if !deleted {
                throw PersistenceError.notFound("Recipe with ID \(idString) not found")
            }
        }
    }

    // MARK: - Query Operations

    public func searchRecipes(query: String) async throws -> [Recipe] {
        try await dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: query)
            let sql = """
                SELECT recipes.* FROM recipes
                JOIN recipes_fts ON recipes.rowid = recipes_fts.rowid
                WHERE recipes_fts MATCH ?
                ORDER BY recipes.created_at ASC
                """
            let records = try RecipeRecord.fetchAll(db, sql: sql, arguments: [pattern])
            return try records.map { try $0.toDomain() }
        }
    }

    public func findRecipesByTag(_ tag: String) async throws -> [Recipe] {
        try await dbQueue.read { db in
            // Fetch all recipes and filter in memory since tags are JSON
            let allRecords = try RecipeRecord
                .order(Column("created_at").asc)
                .fetchAll(db)

            let allRecipes = try allRecords.map { try $0.toDomain() }

            // Filter recipes that contain the specified tag (case-insensitive)
            return allRecipes.filter { recipe in
                recipe.tags.contains { $0.lowercased() == tag.lowercased() }
            }
        }
    }
}
