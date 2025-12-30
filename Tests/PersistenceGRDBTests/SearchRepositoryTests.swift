// Tests/PersistenceGRDBTests/SearchRepositoryTests.swift
// Tests for card-centric search and filtering

import Domain
@testable import PersistenceGRDB
import PersistenceInterfaces
import XCTest
import GRDB

final class SearchRepositoryTests: XCTestCase {
    var dbQueue: DatabaseQueue!
    var boardsRepo: GRDBBoardsRepository!
    var recipesRepo: GRDBRecipesRepository!
    var listsRepo: GRDBListsRepository!
    var searchRepo: GRDBSearchRepository!

    override func setUp() async throws {
        try await super.setUp()

        // Create shared in-memory database
        dbQueue = try DatabaseQueue()
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)

        // Initialize all repositories with the shared database
        boardsRepo = GRDBBoardsRepository(dbQueue: dbQueue)
        recipesRepo = GRDBRecipesRepository(dbQueue: dbQueue)
        listsRepo = GRDBListsRepository(dbQueue: dbQueue)
        searchRepo = GRDBSearchRepository(dbWriter: dbQueue)
    }

    override func tearDown() async throws {
        boardsRepo = nil
        recipesRepo = nil
        listsRepo = nil
        searchRepo = nil
        dbQueue = nil
        try await super.tearDown()
    }

    // MARK: - Test Helpers

    func createTestBoard(title: String) async throws -> Board {
        let board = Board(title: title)
        try await boardsRepo.createBoard(board)
        return board
    }

    func createTestColumn(board: BoardID, title: String, index: Int) async throws -> Domain.Column {
        let column = Domain.Column(board: board, title: title, index: index)
        try await boardsRepo.createColumn(column)
        return column
    }

    func createTestCard(
        column: ColumnID,
        title: String,
        details: String = "",
        tags: [String] = [],
        due: Date? = nil,
        recipeID: RecipeID? = nil,
        listID: ListID? = nil
    ) async throws -> Card {
        let card = Card(
            column: column,
            title: title,
            details: details,
            due: due,
            tags: tags,
            recipeID: recipeID,
            listID: listID
        )
        try await boardsRepo.createCard(card)
        return card
    }

    // MARK: - Text Search Tests

    func testSearchCardsByText_MatchesTitle() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card1 = try await createTestCard(column: column.id, title: "Buy groceries")
        let card2 = try await createTestCard(column: column.id, title: "Clean house")
        let card3 = try await createTestCard(column: column.id, title: "Buy tickets")

        let results = try await searchRepo.searchCardsByText("Buy")

        XCTAssertEqual(results.count, 2)
        let resultIDs = Set(results.map { $0.id })
        XCTAssertTrue(resultIDs.contains(card1.id))
        XCTAssertTrue(resultIDs.contains(card3.id))
        XCTAssertFalse(resultIDs.contains(card2.id))
    }

    func testSearchCardsByText_MatchesDetails() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card1 = try await createTestCard(column: column.id, title: "Task 1", details: "Important meeting")
        let card2 = try await createTestCard(column: column.id, title: "Task 2", details: "Regular work")

        let results = try await searchRepo.searchCardsByText("Important")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, card1.id)
    }

    func testSearchCardsByText_CaseInsensitive() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card = try await createTestCard(column: column.id, title: "UPPERCASE")

        let results = try await searchRepo.searchCardsByText("uppercase")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, card.id)
    }

    // MARK: - Recipe Filter Tests

    func testFindCardsWithRecipe_ReturnsOnlyCardsWithRecipes() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        // Create card with recipe
        let card1 = try await createTestCard(column: column.id, title: "Dinner card")
        let recipe = Recipe(cardID: card1.id, title: "Pasta")
        try await recipesRepo.createRecipe(recipe)

        // Update card with recipeID
        var updatedCard1 = card1
        updatedCard1.recipeID = recipe.id
        try await boardsRepo.updateCard(updatedCard1)

        // Create card without recipe
        let card2 = try await createTestCard(column: column.id, title: "Shopping")

        let results = try await searchRepo.findCardsWithRecipe(boardID: nil)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, updatedCard1.id)
        XCTAssertNotNil(results[0].recipeID)
    }

    func testFindCardsWithRecipe_FiltersByBoard() async throws {
        // Create two boards
        let board1 = try await createTestBoard(title: "Board 1")
        let column1 = try await createTestColumn(board: board1.id, title: "Todo", index: 0)

        let board2 = try await createTestBoard(title: "Board 2")
        let column2 = try await createTestColumn(board: board2.id, title: "Todo", index: 0)

        // Create cards with recipes on different boards
        let card1 = try await createTestCard(column: column1.id, title: "Card 1")
        let recipe1 = Recipe(cardID: card1.id, title: "Recipe 1")
        try await recipesRepo.createRecipe(recipe1)
        var updatedCard1 = card1
        updatedCard1.recipeID = recipe1.id
        try await boardsRepo.updateCard(updatedCard1)

        let card2 = try await createTestCard(column: column2.id, title: "Card 2")
        let recipe2 = Recipe(cardID: card2.id, title: "Recipe 2")
        try await recipesRepo.createRecipe(recipe2)
        var updatedCard2 = card2
        updatedCard2.recipeID = recipe2.id
        try await boardsRepo.updateCard(updatedCard2)

        // Search only board 1
        let results = try await searchRepo.findCardsWithRecipe(boardID: board1.id)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, updatedCard1.id)
    }

    // MARK: - List Filter Tests

    func testFindCardsWithList_ReturnsOnlyCardsWithLists() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        // Create card with list
        let card1 = try await createTestCard(column: column.id, title: "Shopping card")
        let list = PersonalList(cardID: card1.id, title: "Groceries")
        try await listsRepo.createList(list)

        // Update card with listID
        var updatedCard1 = card1
        updatedCard1.listID = list.id
        try await boardsRepo.updateCard(updatedCard1)

        // Create card without list
        let card2 = try await createTestCard(column: column.id, title: "Task card")

        let results = try await searchRepo.findCardsWithList(boardID: nil)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, updatedCard1.id)
        XCTAssertNotNil(results[0].listID)
    }

    // MARK: - Tag Filter Tests

    func testFindCardsByTag_MatchesTag() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card1 = try await createTestCard(column: column.id, title: "Card 1", tags: ["urgent", "work"])
        let card2 = try await createTestCard(column: column.id, title: "Card 2", tags: ["personal"])
        let card3 = try await createTestCard(column: column.id, title: "Card 3", tags: ["urgent"])

        let results = try await searchRepo.findCardsByTag("urgent", boardID: nil)

        XCTAssertEqual(results.count, 2)
        let resultIDs = Set(results.map { $0.id })
        XCTAssertTrue(resultIDs.contains(card1.id))
        XCTAssertTrue(resultIDs.contains(card3.id))
        XCTAssertFalse(resultIDs.contains(card2.id))
    }

    func testFindCardsByTag_FiltersByBoard() async throws {
        let board1 = try await createTestBoard(title: "Board 1")
        let column1 = try await createTestColumn(board: board1.id, title: "Todo", index: 0)

        let board2 = try await createTestBoard(title: "Board 2")
        let column2 = try await createTestColumn(board: board2.id, title: "Todo", index: 0)

        let card1 = try await createTestCard(column: column1.id, title: "Card 1", tags: ["urgent"])
        let card2 = try await createTestCard(column: column2.id, title: "Card 2", tags: ["urgent"])

        let results = try await searchRepo.findCardsByTag("urgent", boardID: board1.id)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].id, card1.id)
    }

    // MARK: - Due Date Filter Tests

    func testFindCardsByDueDate_MatchesRange() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: today)!
        let nextMonth = Calendar.current.date(byAdding: .day, value: 30, to: today)!

        let card1 = try await createTestCard(column: column.id, title: "Card 1", due: tomorrow)
        let card2 = try await createTestCard(column: column.id, title: "Card 2", due: nextWeek)
        let card3 = try await createTestCard(column: column.id, title: "Card 3", due: nextMonth)

        let results = try await searchRepo.findCardsByDueDate(from: today, to: nextWeek, boardID: nil)

        XCTAssertEqual(results.count, 2)
        let resultIDs = Set(results.map { $0.id })
        XCTAssertTrue(resultIDs.contains(card1.id))
        XCTAssertTrue(resultIDs.contains(card2.id))
        XCTAssertFalse(resultIDs.contains(card3.id))
    }

    // MARK: - Advanced Search Tests

    func testSearchCards_MultipleFilters() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        // Create card matching all filters
        let card1 = try await createTestCard(
            column: column.id,
            title: "Important task",
            tags: ["urgent"]
        )
        let recipe1 = Recipe(cardID: card1.id, title: "Recipe")
        try await recipesRepo.createRecipe(recipe1)
        var updatedCard1 = card1
        updatedCard1.recipeID = recipe1.id
        try await boardsRepo.updateCard(updatedCard1)

        // Create card matching some filters
        let card2 = try await createTestCard(column: column.id, title: "Regular task", tags: ["urgent"])

        // Create card matching no filters
        let card3 = try await createTestCard(column: column.id, title: "Other task")

        let filter = CardFilter(
            text: "task",
            hasRecipe: true,
            tag: "urgent"
        )

        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].card.id, updatedCard1.id)
        XCTAssertTrue(results[0].hasRecipe)
        XCTAssertFalse(results[0].hasList)
    }

    func testSearchCards_ReturnsFullContext() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card = try await createTestCard(column: column.id, title: "Test card")

        let filter = CardFilter(text: "Test")
        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 1)

        let result = results[0]
        XCTAssertEqual(result.card.id, card.id)
        XCTAssertEqual(result.column.id, column.id)
        XCTAssertEqual(result.board.id, board.id)
        XCTAssertEqual(result.board.title, "Test Board")
        XCTAssertEqual(result.column.title, "Todo")
    }

    func testSearchCards_FilterByHasRecipeTrue() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        // Card with recipe
        let card1 = try await createTestCard(column: column.id, title: "Card 1")
        let recipe = Recipe(cardID: card1.id, title: "Recipe")
        try await recipesRepo.createRecipe(recipe)
        var updatedCard1 = card1
        updatedCard1.recipeID = recipe.id
        try await boardsRepo.updateCard(updatedCard1)

        // Card without recipe
        let card2 = try await createTestCard(column: column.id, title: "Card 2")

        let filter = CardFilter(hasRecipe: true)
        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].card.id, updatedCard1.id)
        XCTAssertTrue(results[0].hasRecipe)
    }

    func testSearchCards_FilterByHasRecipeFalse() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        // Card with recipe
        let card1 = try await createTestCard(column: column.id, title: "Card 1")
        let recipe = Recipe(cardID: card1.id, title: "Recipe")
        try await recipesRepo.createRecipe(recipe)
        var updatedCard1 = card1
        updatedCard1.recipeID = recipe.id
        try await boardsRepo.updateCard(updatedCard1)

        // Card without recipe
        let card2 = try await createTestCard(column: column.id, title: "Card 2")

        let filter = CardFilter(hasRecipe: false)
        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].card.id, card2.id)
        XCTAssertFalse(results[0].hasRecipe)
    }

    func testSearchCards_FilterByBoardID() async throws {
        let board1 = try await createTestBoard(title: "Board 1")
        let column1 = try await createTestColumn(board: board1.id, title: "Todo", index: 0)

        let board2 = try await createTestBoard(title: "Board 2")
        let column2 = try await createTestColumn(board: board2.id, title: "Todo", index: 0)

        let card1 = try await createTestCard(column: column1.id, title: "Card on Board 1")
        let card2 = try await createTestCard(column: column2.id, title: "Card on Board 2")

        let filter = CardFilter(boardID: board1.id)
        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].card.id, card1.id)
        XCTAssertEqual(results[0].board.id, board1.id)
    }

    func testSearchCards_EmptyFilter_ReturnsAllCards() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card1 = try await createTestCard(column: column.id, title: "Card 1")
        let card2 = try await createTestCard(column: column.id, title: "Card 2")

        let filter = CardFilter()
        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 2)
    }

    func testSearchCards_NoMatches_ReturnsEmpty() async throws {
        let board = try await createTestBoard(title: "Test Board")
        let column = try await createTestColumn(board: board.id, title: "Todo", index: 0)

        let card = try await createTestCard(column: column.id, title: "Card")

        let filter = CardFilter(text: "nonexistent")
        let results = try await searchRepo.searchCards(filter: filter)

        XCTAssertEqual(results.count, 0)
    }
}
