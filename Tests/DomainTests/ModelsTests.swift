// Tests/DomainTests/ModelsTests.swift
// Tests for domain models

import XCTest
@testable import Domain

final class ModelsTests: XCTestCase {
    // MARK: - ID Types Tests

    func testBoardIDCreation() {
        let id1 = BoardID()
        let id2 = BoardID()

        XCTAssertNotEqual(id1, id2, "Two new BoardIDs should be different")
    }

    func testBoardIDFromUUID() {
        let uuid = UUID()
        let id = BoardID(rawValue: uuid)

        XCTAssertEqual(id.rawValue, uuid)
    }

    func testColumnIDCreation() {
        let id1 = ColumnID()
        let id2 = ColumnID()

        XCTAssertNotEqual(id1, id2, "Two new ColumnIDs should be different")
    }

    func testCardIDCreation() {
        let id1 = CardID()
        let id2 = CardID()

        XCTAssertNotEqual(id1, id2, "Two new CardIDs should be different")
    }

    func testListIDCreation() {
        let id1 = ListID()
        let id2 = ListID()

        XCTAssertNotEqual(id1, id2, "Two new ListIDs should be different")
    }

    func testRecipeIDCreation() {
        let id1 = RecipeID()
        let id2 = RecipeID()

        XCTAssertNotEqual(id1, id2, "Two new RecipeIDs should be different")
    }

    // MARK: - ChecklistItem Tests

    func testChecklistItemCreation() {
        let item = ChecklistItem(
            text: "Buy milk",
            isDone: false,
            quantity: 2.0,
            unit: "liters",
            note: "Low fat"
        )

        XCTAssertEqual(item.text, "Buy milk")
        XCTAssertFalse(item.isDone)
        XCTAssertEqual(item.quantity, 2.0)
        XCTAssertEqual(item.unit, "liters")
        XCTAssertEqual(item.note, "Low fat")
    }

    func testChecklistItemDefaults() {
        let item = ChecklistItem(text: "Task")

        XCTAssertFalse(item.isDone)
        XCTAssertNil(item.quantity)
        XCTAssertNil(item.unit)
        XCTAssertNil(item.note)
    }

    func testChecklistItemEquality() {
        let id = UUID()
        let item1 = ChecklistItem(id: id, text: "Buy milk")
        let item2 = ChecklistItem(id: id, text: "Buy milk")

        XCTAssertEqual(item1, item2)
    }

    func testChecklistItemCodable() throws {
        let item = ChecklistItem(
            text: "Buy milk",
            isDone: true,
            quantity: 2.0,
            unit: "liters"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(item)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChecklistItem.self, from: data)

        XCTAssertEqual(item, decoded)
    }

    // MARK: - Board Tests

    func testBoardCreation() {
        let board = Board(title: "My Board")

        XCTAssertEqual(board.title, "My Board")
        XCTAssertTrue(board.columns.isEmpty)
    }

    func testBoardWithColumns() {
        let col1 = ColumnID()
        let col2 = ColumnID()
        let board = Board(title: "My Board", columns: [col1, col2])

        XCTAssertEqual(board.columns.count, 2)
        XCTAssertEqual(board.columns[0], col1)
        XCTAssertEqual(board.columns[1], col2)
    }

    func testBoardEquality() {
        let id = BoardID()
        let date = Date()
        let board1 = Board(id: id, title: "Board", createdAt: date, updatedAt: date)
        let board2 = Board(id: id, title: "Board", createdAt: date, updatedAt: date)

        XCTAssertEqual(board1, board2)
    }

    func testBoardCodable() throws {
        let board = Board(title: "My Board")

        let encoder = JSONEncoder()
        let data = try encoder.encode(board)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Board.self, from: data)

        XCTAssertEqual(board.title, decoded.title)
    }

    // MARK: - Column Tests

    func testColumnCreation() {
        let boardID = BoardID()
        let column = Column(board: boardID, title: "To Do", index: 0)

        XCTAssertEqual(column.title, "To Do")
        XCTAssertEqual(column.index, 0)
        XCTAssertEqual(column.board, boardID)
        XCTAssertTrue(column.cards.isEmpty)
    }

    func testColumnWithCards() {
        let boardID = BoardID()
        let card1 = CardID()
        let card2 = CardID()
        let column = Column(
            board: boardID,
            title: "To Do",
            index: 0,
            cards: [card1, card2]
        )

        XCTAssertEqual(column.cards.count, 2)
    }

    func testColumnCodable() throws {
        let boardID = BoardID()
        let column = Column(board: boardID, title: "To Do", index: 0)

        let encoder = JSONEncoder()
        let data = try encoder.encode(column)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Column.self, from: data)

        XCTAssertEqual(column.title, decoded.title)
        XCTAssertEqual(column.index, decoded.index)
    }

    // MARK: - Card Tests

    func testCardCreation() {
        let columnID = ColumnID()
        let card = Card(
            column: columnID,
            title: "Pay bills",
            details: "Electricity and water"
        )

        XCTAssertEqual(card.title, "Pay bills")
        XCTAssertEqual(card.details, "Electricity and water")
        XCTAssertEqual(card.column, columnID)
        XCTAssertTrue(card.tags.isEmpty)
        XCTAssertTrue(card.checklist.isEmpty)
        XCTAssertNil(card.due)
    }

    func testCardWithAllFields() {
        let columnID = ColumnID()
        let dueDate = Date()
        let item = ChecklistItem(text: "Step 1")

        let card = Card(
            column: columnID,
            title: "Complex task",
            details: "Details",
            due: dueDate,
            tags: ["urgent", "home"],
            checklist: [item],
            sortKey: 1.5
        )

        XCTAssertEqual(card.tags.count, 2)
        XCTAssertEqual(card.checklist.count, 1)
        XCTAssertEqual(card.due, dueDate)
        XCTAssertEqual(card.sortKey, 1.5)
    }

    func testCardCodable() throws {
        let columnID = ColumnID()
        let card = Card(column: columnID, title: "Task", sortKey: 2.0)

        let encoder = JSONEncoder()
        let data = try encoder.encode(card)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Card.self, from: data)

        XCTAssertEqual(card.title, decoded.title)
        XCTAssertEqual(card.sortKey, decoded.sortKey)
    }

    // MARK: - PersonalList Tests

    func testPersonalListCreation() {
        let list = PersonalList(title: "Groceries")

        XCTAssertEqual(list.title, "Groceries")
        XCTAssertTrue(list.items.isEmpty)
    }

    func testPersonalListWithItems() {
        let item1 = ChecklistItem(text: "Milk", quantity: 2, unit: "liters")
        let item2 = ChecklistItem(text: "Bread")
        let list = PersonalList(title: "Groceries", items: [item1, item2])

        XCTAssertEqual(list.items.count, 2)
        XCTAssertEqual(list.items[0].text, "Milk")
    }

    func testPersonalListCodable() throws {
        let list = PersonalList(title: "Groceries")

        let encoder = JSONEncoder()
        let data = try encoder.encode(list)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PersonalList.self, from: data)

        XCTAssertEqual(list.title, decoded.title)
    }

    // MARK: - Recipe Tests

    func testRecipeCreation() {
        let recipe = Recipe(
            title: "Pasta Carbonara",
            methodMarkdown: "# Steps\n1. Boil water"
        )

        XCTAssertEqual(recipe.title, "Pasta Carbonara")
        XCTAssertEqual(recipe.methodMarkdown, "# Steps\n1. Boil water")
        XCTAssertTrue(recipe.ingredients.isEmpty)
        XCTAssertTrue(recipe.tags.isEmpty)
    }

    func testRecipeWithIngredients() {
        let ingredient1 = ChecklistItem(text: "Pasta", quantity: 400, unit: "g")
        let ingredient2 = ChecklistItem(text: "Eggs", quantity: 4, unit: "whole")
        let recipe = Recipe(
            title: "Pasta Carbonara",
            ingredients: [ingredient1, ingredient2],
            tags: ["italian", "pasta"]
        )

        XCTAssertEqual(recipe.ingredients.count, 2)
        XCTAssertEqual(recipe.tags.count, 2)
    }

    func testRecipeCodable() throws {
        let recipe = Recipe(
            title: "Pasta",
            methodMarkdown: "Cook it",
            tags: ["italian"]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(recipe)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Recipe.self, from: data)

        XCTAssertEqual(recipe.title, decoded.title)
        XCTAssertEqual(recipe.methodMarkdown, decoded.methodMarkdown)
        XCTAssertEqual(recipe.tags, decoded.tags)
    }
}
