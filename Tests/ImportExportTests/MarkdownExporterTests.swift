// Tests/ImportExportTests/MarkdownExporterTests.swift
// Tests for Markdown export functionality

import Domain
import Foundation
import ImportExport
import PersistenceInterfaces
import XCTest

// MARK: - Tests

final class MarkdownExporterTests: XCTestCase {
    var boardsRepository: InMemoryBoardsRepository!
    var listsRepository: InMemoryListsRepository!
    var recipesRepository: InMemoryRecipesRepository!
    var exporter: MarkdownExporter!

    override func setUp() async throws {
        boardsRepository = InMemoryBoardsRepository()
        listsRepository = InMemoryListsRepository()
        recipesRepository = InMemoryRecipesRepository()
        exporter = MarkdownExporter(
            boardsRepository: boardsRepository,
            recipesRepository: recipesRepository,
            listsRepository: listsRepository
        )
    }

    // MARK: - Basic Export Tests

    func testExportEmptyBoard() async throws {
        let board = Board(title: "Empty Board")
        try await boardsRepository.createBoard(board)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("# Empty Board"))
        XCTAssertTrue(markdown.contains("_Created:"))
    }

    func testExportBoardWithEmptyColumn() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepository.createColumn(column)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("# Test Board"))
        XCTAssertTrue(markdown.contains("## To Do"))
        XCTAssertTrue(markdown.contains("_No cards_"))
    }

    func testExportBoardWithSimpleCard() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepository.createColumn(column)

        let card = Card(
            column: column.id,
            title: "Test Task",
            details: "Test details",
            sortKey: 0
        )
        try await boardsRepository.createCard(card)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("# Test Board"))
        XCTAssertTrue(markdown.contains("## To Do"))
        XCTAssertTrue(markdown.contains("### Test Task"))
        XCTAssertTrue(markdown.contains("Test details"))
    }

    // MARK: - Card with Metadata Tests

    func testExportCardWithDueDate() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepository.createColumn(column)

        let dueDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01
        let card = Card(
            column: column.id,
            title: "Urgent Task",
            due: dueDate,
            sortKey: 0
        )
        try await boardsRepository.createCard(card)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("### Urgent Task"))
        XCTAssertTrue(markdown.contains("📅 **Due:**"))
    }

    func testExportCardWithTags() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepository.createColumn(column)

        let card = Card(
            column: column.id,
            title: "Tagged Task",
            tags: ["urgent", "important"],
            sortKey: 0
        )
        try await boardsRepository.createCard(card)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("### Tagged Task"))
        XCTAssertTrue(markdown.contains("🏷️ **Tags:** urgent, important"))
    }

    func testExportCardWithChecklist() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepository.createColumn(column)

        let checklistItems = [
            ChecklistItem(text: "Item 1", isDone: false),
            ChecklistItem(text: "Item 2", isDone: true),
            ChecklistItem(text: "Item 3", isDone: false, quantity: 2.5, unit: "kg", note: "Fresh")
        ]

        let card = Card(
            column: column.id,
            title: "Checklist Task",
            checklist: checklistItems,
            sortKey: 0
        )
        try await boardsRepository.createCard(card)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("### Checklist Task"))
        XCTAssertTrue(markdown.contains("**Checklist:**"))
        XCTAssertTrue(markdown.contains("- [ ] Item 1"))
        XCTAssertTrue(markdown.contains("- [x] Item 2"))
        XCTAssertTrue(markdown.contains("- [ ] Item 3 (2.5 kg) - _Fresh_"))
    }

    // MARK: - Recipe Export Tests

    func testExportCardWithRecipe() async throws {
        let board = Board(title: "Meal Planning")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "Dinner Ideas", index: 0)
        try await boardsRepository.createColumn(column)

        let recipeID = RecipeID()
        let card = Card(
            column: column.id,
            title: "Pasta Night",
            details: "Italian dinner",
            sortKey: 0,
            recipeID: recipeID
        )
        try await boardsRepository.createCard(card)

        let ingredients = [
            ChecklistItem(text: "Pasta", quantity: 500, unit: "g"),
            ChecklistItem(text: "Tomato Sauce", quantity: 400, unit: "ml"),
            ChecklistItem(text: "Garlic", quantity: 3, unit: "cloves", note: "minced")
        ]

        let recipe = Recipe(
            id: recipeID,
            cardID: card.id,
            title: "Simple Pasta",
            ingredients: ingredients,
            methodMarkdown: "1. Boil pasta\n2. Heat sauce\n3. Combine and serve",
            tags: ["italian", "quick"]
        )
        try await recipesRepository.createRecipe(recipe)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("### Pasta Night"))
        XCTAssertTrue(markdown.contains("#### 🍳 Recipe: Simple Pasta"))
        XCTAssertTrue(markdown.contains("**Tags:** italian, quick"))
        XCTAssertTrue(markdown.contains("**Ingredients:**"))
        XCTAssertTrue(markdown.contains("- 500 g Pasta"))
        XCTAssertTrue(markdown.contains("- 400 ml Tomato Sauce"))
        XCTAssertTrue(markdown.contains("- 3 cloves Garlic - _minced_"))
        XCTAssertTrue(markdown.contains("**Method:**"))
        XCTAssertTrue(markdown.contains("1. Boil pasta"))
    }

    // MARK: - List Export Tests

    func testExportCardWithList() async throws {
        let board = Board(title: "Shopping")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "This Week", index: 0)
        try await boardsRepository.createColumn(column)

        let listID = ListID()
        let card = Card(
            column: column.id,
            title: "Grocery Shopping",
            sortKey: 0,
            listID: listID
        )
        try await boardsRepository.createCard(card)

        let items = [
            ChecklistItem(text: "Milk", isDone: false, quantity: 2, unit: "L"),
            ChecklistItem(text: "Bread", isDone: true, quantity: 1, unit: "loaf"),
            ChecklistItem(text: "Eggs", isDone: false, quantity: 12, unit: "count")
        ]

        let list = PersonalList(
            id: listID,
            cardID: card.id,
            title: "Groceries",
            items: items
        )
        try await listsRepository.createList(list)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("### Grocery Shopping"))
        XCTAssertTrue(markdown.contains("#### 📝 List: Groceries"))
        XCTAssertTrue(markdown.contains("- [ ] 2 L Milk"))
        XCTAssertTrue(markdown.contains("- [x] 1 loaf Bread"))
        XCTAssertTrue(markdown.contains("- [ ] 12 count Eggs"))
    }

    // MARK: - Combined Export Tests

    func testExportCardWithBothRecipeAndList() async throws {
        let board = Board(title: "Meal Prep")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "Planning", index: 0)
        try await boardsRepository.createColumn(column)

        let recipeID = RecipeID()
        let listID = ListID()
        let card = Card(
            column: column.id,
            title: "Sunday Dinner",
            sortKey: 0,
            recipeID: recipeID,
            listID: listID
        )
        try await boardsRepository.createCard(card)

        let recipe = Recipe(
            id: recipeID,
            cardID: card.id,
            title: "Roast Chicken",
            ingredients: [ChecklistItem(text: "Chicken", quantity: 1, unit: "whole")],
            methodMarkdown: "Roast at 180°C for 1 hour"
        )
        try await recipesRepository.createRecipe(recipe)

        let list = PersonalList(
            id: listID,
            cardID: card.id,
            title: "Shopping List",
            items: [ChecklistItem(text: "Chicken", isDone: false)]
        )
        try await listsRepository.createList(list)

        let markdown = try await exporter.exportBoard(board.id)

        XCTAssertTrue(markdown.contains("### Sunday Dinner"))
        XCTAssertTrue(markdown.contains("#### 🍳 Recipe: Roast Chicken"))
        XCTAssertTrue(markdown.contains("#### 📝 List: Shopping List"))
    }

    // MARK: - Multiple Boards and Columns Tests

    func testExportMultipleColumnsInOrder() async throws {
        let board = Board(title: "Kanban Board")
        try await boardsRepository.createBoard(board)

        let column1 = Column(board: board.id, title: "To Do", index: 0)
        let column2 = Column(board: board.id, title: "In Progress", index: 1)
        let column3 = Column(board: board.id, title: "Done", index: 2)

        try await boardsRepository.createColumn(column1)
        try await boardsRepository.createColumn(column2)
        try await boardsRepository.createColumn(column3)

        let card1 = Card(column: column1.id, title: "Task 1", sortKey: 0)
        let card2 = Card(column: column2.id, title: "Task 2", sortKey: 0)
        let card3 = Card(column: column3.id, title: "Task 3", sortKey: 0)

        try await boardsRepository.createCard(card1)
        try await boardsRepository.createCard(card2)
        try await boardsRepository.createCard(card3)

        let markdown = try await exporter.exportBoard(board.id)

        // Verify columns appear in order
        let todoRange = markdown.range(of: "## To Do")!
        let inProgressRange = markdown.range(of: "## In Progress")!
        let doneRange = markdown.range(of: "## Done")!

        XCTAssertTrue(todoRange.lowerBound < inProgressRange.lowerBound)
        XCTAssertTrue(inProgressRange.lowerBound < doneRange.lowerBound)
    }

    func testExportAllBoards() async throws {
        let board1 = Board(title: "Board 1")
        let board2 = Board(title: "Board 2")

        try await boardsRepository.createBoard(board1)
        try await boardsRepository.createBoard(board2)

        let markdown = try await exporter.exportAll()

        XCTAssertTrue(markdown.contains("# HomeCooked Export"))
        XCTAssertTrue(markdown.contains("**Total Boards:** 2"))
        XCTAssertTrue(markdown.contains("# Board 1"))
        XCTAssertTrue(markdown.contains("# Board 2"))
    }

    // MARK: - File Export Tests

    func testExportToFile() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(board: board.id, title: "Column", index: 0)
        try await boardsRepository.createColumn(column)

        let recipeID = RecipeID()
        let listID = ListID()
        let card = Card(
            column: column.id,
            title: "Card",
            sortKey: 0,
            recipeID: recipeID,
            listID: listID
        )
        try await boardsRepository.createCard(card)

        let recipe = Recipe(
            id: recipeID,
            cardID: card.id,
            title: "Recipe",
            ingredients: []
        )
        try await recipesRepository.createRecipe(recipe)

        let list = PersonalList(
            id: listID,
            cardID: card.id,
            title: "List",
            items: []
        )
        try await listsRepository.createList(list)

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("test-export.md")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let result = try await exporter.exportToFile(tempURL)

        // Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: tempURL.path))

        // Verify result stats
        XCTAssertEqual(result.boardsExported, 1)
        XCTAssertEqual(result.columnsExported, 1)
        XCTAssertEqual(result.cardsExported, 1)
        XCTAssertEqual(result.recipesExported, 1)
        XCTAssertEqual(result.listsExported, 1)

        // Verify file contents
        let contents = try String(contentsOf: tempURL, encoding: .utf8)
        XCTAssertTrue(contents.contains("# HomeCooked Export"))
        XCTAssertTrue(contents.contains("# Test Board"))
    }

    func testExportBoardToFile() async throws {
        let board = Board(title: "Single Board")
        try await boardsRepository.createBoard(board)

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("single-board.md")
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let result = try await exporter.exportBoardToFile(board.id, to: tempURL)

        XCTAssertEqual(result.boardsExported, 1)

        let contents = try String(contentsOf: tempURL, encoding: .utf8)
        XCTAssertTrue(contents.contains("# Single Board"))
        XCTAssertFalse(contents.contains("# HomeCooked Export"))
    }

    // MARK: - Summary Tests

    func testExportResultSummary() {
        let result = MarkdownExportResult(
            boardsExported: 2,
            columnsExported: 5,
            cardsExported: 10,
            recipesExported: 3,
            listsExported: 4
        )

        let summary = result.summary

        XCTAssertTrue(summary.contains("Boards: 2"))
        XCTAssertTrue(summary.contains("Columns: 5"))
        XCTAssertTrue(summary.contains("Cards: 10"))
        XCTAssertTrue(summary.contains("Recipes: 3"))
        XCTAssertTrue(summary.contains("Lists: 4"))
    }
}
