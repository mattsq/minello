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

    public func loadRecipe(_ id: RecipeID) async throws -> Recipe {
        // TODO: Implement - throw notFound when recipe doesn't exist
        throw PersistenceError.notFound("Recipe with ID \(id.rawValue.uuidString) not found")
    }

    public func updateRecipe(_ recipe: Recipe) async throws {
        // TODO: Implement
    }

    public func deleteRecipe(_ id: RecipeID) async throws {
        // TODO: Implement
    }

    public func searchRecipes(query: String) async throws -> [Recipe] {
        // TODO: Implement
        return []
    }

    public func findRecipesByTag(_ tag: String) async throws -> [Recipe] {
        // TODO: Implement
        return []
    }
}
