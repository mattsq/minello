// PersistenceGRDB/Sources/PersistenceGRDB/GRDBRecipesRepository.swift
// GRDB implementation of RecipesRepository

import Domain
import Foundation
import GRDB
import PersistenceInterfaces

/// GRDB-based implementation of RecipesRepository
public actor GRDBRecipesRepository: RecipesRepository {
    private let dbQueue: DatabaseQueue

    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    public func createRecipe(_ recipe: Recipe) async throws {
        // TODO: Implement
    }

    public func loadRecipes() async throws -> [Recipe] {
        // TODO: Implement
        return []
    }

    public func loadRecipe(_ id: RecipeID) async throws -> Recipe? {
        // TODO: Implement
        return nil
    }

    public func updateRecipe(_ recipe: Recipe) async throws {
        // TODO: Implement
    }

    public func deleteRecipe(_ id: RecipeID) async throws {
        // TODO: Implement
    }
}
