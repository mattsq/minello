// Tests/IntentsTests/AddRecipeIntentTests.swift
// Integration tests for AddRecipeIntent (card-centric)

#if canImport(AppIntents)
import XCTest
import Domain
import PersistenceInterfaces
import PersistenceGRDB
@testable import UseCases

@available(iOS 16.0, macOS 13.0, *)
final class AddRecipeIntentTests: XCTestCase {
    var boardsRepo: GRDBBoardsRepository!
    var recipesRepo: GRDBRecipesRepository!
    var dbURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create temporary in-memory database
        let tempDir = FileManager.default.temporaryDirectory
        dbURL = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")

        let provider = try GRDBRepositoryProvider(databaseURL: dbURL)
        boardsRepo = provider.boardsRepository as? GRDBBoardsRepository
        recipesRepo = provider.recipesRepository as? GRDBRecipesRepository
    }

    override func tearDown() async throws {
        boardsRepo = nil
        recipesRepo = nil
        if let dbURL = dbURL {
            try? FileManager.default.removeItem(at: dbURL)
        }
        try await super.tearDown()
    }

    // MARK: - Ingredient Parsing Tests

    func testParseIngredientsFromCommas() {
        let ingredientsText = "flour, sugar, eggs, butter"
        let items = parseIngredients(ingredientsText)

        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items[0].text, "flour")
        XCTAssertEqual(items[1].text, "sugar")
        XCTAssertEqual(items[2].text, "eggs")
        XCTAssertEqual(items[3].text, "butter")
    }

    func testParseIngredientsFromNewlines() {
        let ingredientsText = "flour\nsugar\neggs\nbutter"
        let items = parseIngredients(ingredientsText)

        XCTAssertEqual(items.count, 4)
        XCTAssertEqual(items[0].text, "flour")
        XCTAssertEqual(items[1].text, "sugar")
    }

    func testParseIngredientsMixed() {
        let ingredientsText = "flour, sugar\neggs, butter"
        let items = parseIngredients(ingredientsText)

        XCTAssertEqual(items.count, 4)
    }

    func testParseIngredientsTrimsWhitespace() {
        let ingredientsText = "  flour  ,  sugar  ,  eggs  "
        let items = parseIngredients(ingredientsText)

        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].text, "flour")
        XCTAssertEqual(items[1].text, "sugar")
        XCTAssertEqual(items[2].text, "eggs")
    }

    func testParseIngredientsFiltersEmpty() {
        let ingredientsText = "flour,,,sugar,,eggs"
        let items = parseIngredients(ingredientsText)

        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].text, "flour")
        XCTAssertEqual(items[1].text, "sugar")
        XCTAssertEqual(items[2].text, "eggs")
    }

    // MARK: - Card-Centric Recipe Operations

    func testAddRecipeToExistingCardWithoutRecipe() async throws {
        // Create board, column, and card
        let board = Board(title: "Meal Planning")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Cook", index: 0)
        try await boardsRepo.saveColumns([column])

        let card = Card(column: column.id, title: "Dinner", sortKey: 0)
        try await boardsRepo.saveCards([card])

        // Verify card has no recipe
        let (loadedCard, loadedRecipe) = try await boardsRepo.loadCardWithRecipe(card.id)
        XCTAssertNil(loadedRecipe)
        XCTAssertNil(loadedCard.recipeID)

        // Create recipe for card
        let recipe = Recipe(
            cardID: card.id,
            title: "Pasta Carbonara",
            ingredients: [
                ChecklistItem(text: "pasta", isDone: false),
                ChecklistItem(text: "eggs", isDone: false)
            ],
            methodMarkdown: "",
            tags: []
        )
        try await recipesRepo.createRecipe(recipe)

        // Update card's recipeID
        var updatedCard = loadedCard
        updatedCard.recipeID = recipe.id
        try await boardsRepo.saveCards([updatedCard])

        // Verify recipe created and linked
        let (finalCard, finalRecipe) = try await boardsRepo.loadCardWithRecipe(card.id)
        XCTAssertNotNil(finalRecipe)
        XCTAssertEqual(finalCard.recipeID, recipe.id)
        XCTAssertEqual(finalRecipe?.title, "Pasta Carbonara")
        XCTAssertEqual(finalRecipe?.ingredients.count, 2)
    }

    func testUpdateExistingRecipe() async throws {
        // Create board, column, and card with recipe
        let board = Board(title: "Meal Planning")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Cook", index: 0)
        try await boardsRepo.saveColumns([column])

        var card = Card(column: column.id, title: "Dinner", sortKey: 0)
        try await boardsRepo.saveCards([card])

        let recipe = Recipe(
            cardID: card.id,
            title: "Pasta Carbonara",
            ingredients: [ChecklistItem(text: "pasta")],
            methodMarkdown: "",
            tags: []
        )
        try await recipesRepo.createRecipe(recipe)

        card.recipeID = recipe.id
        try await boardsRepo.saveCards([card])

        // Update recipe
        var updatedRecipe = recipe
        updatedRecipe.title = "Pasta Carbonara Deluxe"
        updatedRecipe.ingredients = [
            ChecklistItem(text: "pasta"),
            ChecklistItem(text: "eggs"),
            ChecklistItem(text: "bacon")
        ]
        try await recipesRepo.updateRecipe(updatedRecipe)

        // Verify update
        let final = try await recipesRepo.loadRecipe(recipe.id)
        XCTAssertEqual(final.title, "Pasta Carbonara Deluxe")
        XCTAssertEqual(final.ingredients.count, 3)
        XCTAssertEqual(final.ingredients[2].text, "bacon")
    }

    func testCreateCardWhenNotFoundForRecipe() async throws {
        // Create board and column (no cards)
        let board = Board(title: "Meal Planning")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Cook", index: 0)
        try await boardsRepo.saveColumns([column])

        // Verify no cards exist
        let initialCards = try await boardsRepo.loadCards(forBoard: board.id)
        XCTAssertEqual(initialCards.count, 0)

        // Create new card
        let newCard = Card(column: column.id, title: "Dinner", sortKey: 0)
        try await boardsRepo.saveCards([newCard])

        // Verify card created
        let finalCards = try await boardsRepo.loadCards(forBoard: board.id)
        XCTAssertEqual(finalCards.count, 1)
        XCTAssertEqual(finalCards[0].title, "Dinner")
    }

    func testRecipeWithNoIngredients() async throws {
        // Create board, column, and card
        let board = Board(title: "Meal Planning")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Cook", index: 0)
        try await boardsRepo.saveColumns([column])

        var card = Card(column: column.id, title: "Dinner", sortKey: 0)
        try await boardsRepo.saveCards([card])

        // Create recipe with empty ingredients
        let recipe = Recipe(
            cardID: card.id,
            title: "Simple Recipe",
            ingredients: [],
            methodMarkdown: "",
            tags: []
        )
        try await recipesRepo.createRecipe(recipe)

        card.recipeID = recipe.id
        try await boardsRepo.saveCards([card])

        // Verify recipe created
        let (_, loadedRecipe) = try await boardsRepo.loadCardWithRecipe(card.id)
        XCTAssertNotNil(loadedRecipe)
        XCTAssertEqual(loadedRecipe?.title, "Simple Recipe")
        XCTAssertEqual(loadedRecipe?.ingredients.count, 0)
    }

    func testRecipeWithMultipleCards() async throws {
        // Create board, column, and multiple cards with recipes
        let board = Board(title: "Meal Planning")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Cook", index: 0)
        try await boardsRepo.saveColumns([column])

        var card1 = Card(column: column.id, title: "Breakfast", sortKey: 0)
        var card2 = Card(column: column.id, title: "Lunch", sortKey: 1)
        try await boardsRepo.saveCards([card1, card2])

        let recipe1 = Recipe(cardID: card1.id, title: "Pancakes", ingredients: [], methodMarkdown: "", tags: [])
        let recipe2 = Recipe(cardID: card2.id, title: "Sandwich", ingredients: [], methodMarkdown: "", tags: [])
        try await recipesRepo.createRecipe(recipe1)
        try await recipesRepo.createRecipe(recipe2)

        card1.recipeID = recipe1.id
        card2.recipeID = recipe2.id
        try await boardsRepo.saveCards([card1, card2])

        // Verify both recipes exist
        let (loadedCard1, loadedRecipe1) = try await boardsRepo.loadCardWithRecipe(card1.id)
        let (loadedCard2, loadedRecipe2) = try await boardsRepo.loadCardWithRecipe(card2.id)

        XCTAssertNotNil(loadedRecipe1)
        XCTAssertNotNil(loadedRecipe2)
        XCTAssertEqual(loadedRecipe1?.title, "Pancakes")
        XCTAssertEqual(loadedRecipe2?.title, "Sandwich")
    }

    // MARK: - Helper Methods

    private func parseIngredients(_ text: String) -> [ChecklistItem] {
        let rawIngredients = text
            .split(whereSeparator: { $0 == "," || $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return rawIngredients.map { text in
            ChecklistItem(
                text: String(text),
                isDone: false,
                quantity: nil,
                unit: nil
            )
        }
    }
}
#endif
