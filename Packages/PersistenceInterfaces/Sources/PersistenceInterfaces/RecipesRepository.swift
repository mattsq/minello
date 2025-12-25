// PersistenceInterfaces/Sources/PersistenceInterfaces/RecipesRepository.swift
// Repository protocol for recipe operations

import Domain
import Foundation

/// Repository for managing recipes
public protocol RecipesRepository: Sendable {
    // MARK: - Recipe Operations

    /// Creates a new recipe
    /// - Parameter recipe: The recipe to create
    /// - Throws: `PersistenceError` if creation fails
    func createRecipe(_ recipe: Recipe) async throws

    /// Loads all recipes
    /// - Returns: Array of all recipes, sorted by creation date
    /// - Throws: `PersistenceError` if loading fails
    func loadRecipes() async throws -> [Recipe]

    /// Loads a specific recipe by ID
    /// - Parameter id: The recipe ID
    /// - Returns: The recipe if found
    /// - Throws: `PersistenceError.notFound` if recipe doesn't exist
    func loadRecipe(_ id: RecipeID) async throws -> Recipe

    /// Updates an existing recipe
    /// - Parameter recipe: The recipe to update
    /// - Throws: `PersistenceError` if update fails or recipe not found
    func updateRecipe(_ recipe: Recipe) async throws

    /// Deletes a recipe
    /// - Parameter id: The recipe ID
    /// - Throws: `PersistenceError` if deletion fails
    func deleteRecipe(_ id: RecipeID) async throws

    // MARK: - Query Operations

    /// Searches for recipes by title or tags
    /// - Parameter query: The search query
    /// - Returns: Array of matching recipes
    /// - Throws: `PersistenceError` if search fails
    func searchRecipes(query: String) async throws -> [Recipe]

    /// Finds recipes by tag
    /// - Parameter tag: The tag to filter by
    /// - Returns: Array of recipes with the specified tag
    /// - Throws: `PersistenceError` if search fails
    func findRecipesByTag(_ tag: String) async throws -> [Recipe]
}
