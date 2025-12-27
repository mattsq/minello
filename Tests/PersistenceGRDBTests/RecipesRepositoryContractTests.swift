// Tests/PersistenceGRDBTests/RecipesRepositoryContractTests.swift
// Contract tests for RecipesRepository that can run against any implementation

import Domain
import Foundation
import PersistenceGRDB
import PersistenceInterfaces
import XCTest

/// Contract tests for RecipesRepository
/// These tests can be run against any implementation of RecipesRepository
final class RecipesRepositoryContractTests: XCTestCase {
    var repository: RecipesRepository!

    override func setUp() async throws {
        try await super.setUp()
        // Use in-memory GRDB for testing
        repository = try GRDBRecipesRepository.inMemory()
    }

    override func tearDown() async throws {
        repository = nil
        try await super.tearDown()
    }

    // MARK: - Recipe Tests

    func testCreateAndLoadRecipe() async throws {
        let recipe = Recipe(
            id: RecipeID(),
            title: "Spaghetti Carbonara",
            ingredients: [
                ChecklistItem(text: "Spaghetti", isDone: false, quantity: 400, unit: "g"),
                ChecklistItem(text: "Eggs", isDone: false, quantity: 4, unit: nil),
                ChecklistItem(text: "Parmesan", isDone: false, quantity: 100, unit: "g"),
                ChecklistItem(text: "Bacon", isDone: false, quantity: 200, unit: "g"),
            ],
            methodMarkdown: """
            # Instructions
            1. Boil pasta in salted water
            2. Fry bacon until crispy
            3. Mix eggs and cheese
            4. Combine everything
            """,
            tags: ["Italian", "Pasta", "Quick"],
            createdAt: Date(),
            updatedAt: Date()
        )

        try await repository.createRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.id, recipe.id)
        XCTAssertEqual(loaded.title, recipe.title)
        XCTAssertEqual(loaded.ingredients.count, 4)
        XCTAssertEqual(loaded.ingredients[0].text, "Spaghetti")
        XCTAssertEqual(loaded.ingredients[0].quantity, 400)
        XCTAssertEqual(loaded.ingredients[0].unit, "g")
        XCTAssertTrue(loaded.methodMarkdown.contains("Boil pasta"))
        XCTAssertEqual(loaded.tags.count, 3)
        XCTAssertTrue(loaded.tags.contains("Italian"))
    }

    func testLoadAllRecipes() async throws {
        let recipe1 = Recipe(title: "Pasta", methodMarkdown: "Cook pasta")
        let recipe2 = Recipe(title: "Salad", methodMarkdown: "Mix vegetables")

        try await repository.createRecipe(recipe1)
        try await repository.createRecipe(recipe2)

        let recipes = try await repository.loadRecipes()
        XCTAssertEqual(recipes.count, 2)
        XCTAssertTrue(recipes.contains { $0.id == recipe1.id })
        XCTAssertTrue(recipes.contains { $0.id == recipe2.id })
    }

    func testUpdateRecipe() async throws {
        var recipe = Recipe(
            title: "Original Recipe",
            ingredients: [ChecklistItem(text: "Ingredient 1")],
            methodMarkdown: "Original method",
            tags: ["Original"]
        )
        try await repository.createRecipe(recipe)

        recipe.title = "Updated Recipe"
        recipe.ingredients.append(ChecklistItem(text: "Ingredient 2"))
        recipe.methodMarkdown = "Updated method"
        recipe.tags.append("Updated")
        recipe.updatedAt = Date()
        try await repository.updateRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.title, "Updated Recipe")
        XCTAssertEqual(loaded.ingredients.count, 2)
        XCTAssertEqual(loaded.methodMarkdown, "Updated method")
        XCTAssertEqual(loaded.tags.count, 2)
        XCTAssertTrue(loaded.tags.contains("Updated"))
    }

    func testDeleteRecipe() async throws {
        let recipe = Recipe(title: "To Delete", methodMarkdown: "Delete me")
        try await repository.createRecipe(recipe)

        try await repository.deleteRecipe(recipe.id)

        do {
            _ = try await repository.loadRecipe(recipe.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testLoadNonexistentRecipe() async throws {
        let nonexistentID = RecipeID()

        do {
            _ = try await repository.loadRecipe(nonexistentID)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testRecipeWithEmptyIngredients() async throws {
        let recipe = Recipe(title: "Simple Recipe", ingredients: [], methodMarkdown: "Just cook it")
        try await repository.createRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.title, "Simple Recipe")
        XCTAssertEqual(loaded.ingredients.count, 0)
    }

    func testRecipeWithComplexIngredients() async throws {
        let recipe = Recipe(
            title: "Complex Recipe",
            ingredients: [
                ChecklistItem(
                    text: "Tomatoes",
                    isDone: false,
                    quantity: 4.5,
                    unit: "lbs",
                    note: "Use San Marzano if possible"
                ),
                ChecklistItem(
                    text: "Olive Oil",
                    isDone: false,
                    quantity: 0.25,
                    unit: "cup",
                    note: nil
                ),
                ChecklistItem(
                    text: "Garlic",
                    isDone: false,
                    quantity: nil,
                    unit: nil,
                    note: "Fresh, not jarred"
                ),
            ],
            methodMarkdown: "Combine ingredients"
        )

        try await repository.createRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.ingredients.count, 3)

        // Check first ingredient
        XCTAssertEqual(loaded.ingredients[0].text, "Tomatoes")
        XCTAssertEqual(loaded.ingredients[0].quantity, 4.5)
        XCTAssertEqual(loaded.ingredients[0].unit, "lbs")
        XCTAssertEqual(loaded.ingredients[0].note, "Use San Marzano if possible")

        // Check second ingredient
        XCTAssertEqual(loaded.ingredients[1].text, "Olive Oil")
        XCTAssertEqual(loaded.ingredients[1].quantity, 0.25)

        // Check third ingredient
        XCTAssertEqual(loaded.ingredients[2].text, "Garlic")
        XCTAssertNil(loaded.ingredients[2].quantity)
        XCTAssertNil(loaded.ingredients[2].unit)
        XCTAssertEqual(loaded.ingredients[2].note, "Fresh, not jarred")
    }

    func testRecipeWithMarkdownMethod() async throws {
        let markdown = """
        # Chocolate Cake

        ## Ingredients preparation
        - Sift flour
        - Melt chocolate

        ## Baking
        1. Mix wet ingredients
        2. Add dry ingredients
        3. Bake at 350°F for 30 minutes

        **Note**: Let cool before frosting!
        """

        let recipe = Recipe(
            title: "Chocolate Cake",
            methodMarkdown: markdown
        )

        try await repository.createRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.methodMarkdown, markdown)
        XCTAssertTrue(loaded.methodMarkdown.contains("Chocolate Cake"))
        XCTAssertTrue(loaded.methodMarkdown.contains("350°F"))
    }

    func testRecipesAreSortedByCreationDate() async throws {
        // Create recipes with slight delays to ensure different creation times
        let recipe1 = Recipe(title: "First Recipe", methodMarkdown: "Method 1")
        try await repository.createRecipe(recipe1)

        // Small delay to ensure different timestamps
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms

        let recipe2 = Recipe(title: "Second Recipe", methodMarkdown: "Method 2")
        try await repository.createRecipe(recipe2)

        let recipes = try await repository.loadRecipes()
        XCTAssertEqual(recipes.count, 2)
        // First created should be first in the list
        XCTAssertEqual(recipes[0].title, "First Recipe")
        XCTAssertEqual(recipes[1].title, "Second Recipe")
    }

    // MARK: - Query Tests

    func testSearchRecipesByTitle() async throws {
        let recipe1 = Recipe(title: "Chocolate Cake", methodMarkdown: "Bake cake")
        let recipe2 = Recipe(title: "Vanilla Cake", methodMarkdown: "Bake vanilla")
        let recipe3 = Recipe(title: "Chocolate Chip Cookies", methodMarkdown: "Bake cookies")

        try await repository.createRecipe(recipe1)
        try await repository.createRecipe(recipe2)
        try await repository.createRecipe(recipe3)

        let results = try await repository.searchRecipes(query: "chocolate")
        XCTAssertEqual(results.count, 2)
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Chocolate Cake"))
        XCTAssertTrue(titles.contains("Chocolate Chip Cookies"))
    }

    func testSearchRecipesByMethod() async throws {
        let recipe1 = Recipe(title: "Recipe 1", methodMarkdown: "Use a food processor to blend")
        let recipe2 = Recipe(title: "Recipe 2", methodMarkdown: "Mix by hand")
        let recipe3 = Recipe(title: "Recipe 3", methodMarkdown: "Process in food processor")

        try await repository.createRecipe(recipe1)
        try await repository.createRecipe(recipe2)
        try await repository.createRecipe(recipe3)

        let results = try await repository.searchRecipes(query: "processor")
        XCTAssertEqual(results.count, 2)
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Recipe 1"))
        XCTAssertTrue(titles.contains("Recipe 3"))
    }

    func testSearchRecipesNoMatches() async throws {
        let recipe = Recipe(title: "Pasta", methodMarkdown: "Boil water")
        try await repository.createRecipe(recipe)

        let results = try await repository.searchRecipes(query: "pizza")
        XCTAssertEqual(results.count, 0)
    }

    func testFindRecipesByTag() async throws {
        let recipe1 = Recipe(title: "Pasta", methodMarkdown: "Cook", tags: ["Italian", "Quick"])
        let recipe2 = Recipe(title: "Risotto", methodMarkdown: "Stir", tags: ["Italian", "Slow"])
        let recipe3 = Recipe(title: "Tacos", methodMarkdown: "Grill", tags: ["Mexican", "Quick"])

        try await repository.createRecipe(recipe1)
        try await repository.createRecipe(recipe2)
        try await repository.createRecipe(recipe3)

        let italianResults = try await repository.findRecipesByTag("Italian")
        XCTAssertEqual(italianResults.count, 2)
        let italianTitles = Set(italianResults.map { $0.title })
        XCTAssertTrue(italianTitles.contains("Pasta"))
        XCTAssertTrue(italianTitles.contains("Risotto"))

        let quickResults = try await repository.findRecipesByTag("Quick")
        XCTAssertEqual(quickResults.count, 2)
        let quickTitles = Set(quickResults.map { $0.title })
        XCTAssertTrue(quickTitles.contains("Pasta"))
        XCTAssertTrue(quickTitles.contains("Tacos"))
    }

    func testFindRecipesByTagCaseInsensitive() async throws {
        let recipe = Recipe(title: "Pasta", methodMarkdown: "Cook", tags: ["Italian"])
        try await repository.createRecipe(recipe)

        let resultsLower = try await repository.findRecipesByTag("italian")
        XCTAssertEqual(resultsLower.count, 1)

        let resultsUpper = try await repository.findRecipesByTag("ITALIAN")
        XCTAssertEqual(resultsUpper.count, 1)

        let resultsMixed = try await repository.findRecipesByTag("ItALiAn")
        XCTAssertEqual(resultsMixed.count, 1)
    }

    func testFindRecipesByTagNoMatches() async throws {
        let recipe = Recipe(title: "Pasta", methodMarkdown: "Cook", tags: ["Italian"])
        try await repository.createRecipe(recipe)

        let results = try await repository.findRecipesByTag("French")
        XCTAssertEqual(results.count, 0)
    }

    func testRecipeWithNoTags() async throws {
        let recipe = Recipe(title: "Simple Recipe", methodMarkdown: "Cook", tags: [])
        try await repository.createRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.tags.count, 0)

        let results = try await repository.findRecipesByTag("Any")
        XCTAssertEqual(results.count, 0)
    }

    func testUpdateRecipePreservesID() async throws {
        let originalID = RecipeID()
        var recipe = Recipe(
            id: originalID,
            title: "Original",
            methodMarkdown: "Method"
        )
        try await repository.createRecipe(recipe)

        recipe.title = "Updated"
        try await repository.updateRecipe(recipe)

        let loaded = try await repository.loadRecipe(originalID)
        XCTAssertEqual(loaded.id, originalID)
        XCTAssertEqual(loaded.title, "Updated")
    }

    func testUpdateNonexistentRecipeThrows() async throws {
        let recipe = Recipe(title: "Nonexistent", methodMarkdown: "Method")

        do {
            try await repository.updateRecipe(recipe)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testDeleteNonexistentRecipeThrows() async throws {
        let nonexistentID = RecipeID()

        do {
            try await repository.deleteRecipe(nonexistentID)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testRecipeWithUnicodeCharacters() async throws {
        let recipe = Recipe(
            title: "Crème Brûlée",
            ingredients: [
                ChecklistItem(text: "Crème fraîche", quantity: 500, unit: "ml"),
            ],
            methodMarkdown: """
            # Préparation
            1. Mélanger les ingrédients
            2. Cuire à 180°C
            """,
            tags: ["Français", "Dessert"]
        )

        try await repository.createRecipe(recipe)

        let loaded = try await repository.loadRecipe(recipe.id)
        XCTAssertEqual(loaded.title, "Crème Brûlée")
        XCTAssertEqual(loaded.ingredients[0].text, "Crème fraîche")
        XCTAssertTrue(loaded.methodMarkdown.contains("180°C"))
        XCTAssertTrue(loaded.tags.contains("Français"))
    }
}
