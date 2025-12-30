// Tests/UseCasesTests/Lookup/EntityLookupTests.swift
// Unit tests for EntityLookup

import XCTest
import Domain
@testable import UseCases

final class EntityLookupTests: XCTestCase {

    // MARK: - Board Lookup

    func testFindBoardsExactMatch() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Work"),
            Board(title: "Personal")
        ]

        let results = EntityLookup.findBoards(query: "Home", in: boards)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].board.title, "Home")
        XCTAssertEqual(results[0].score, 1.0, accuracy: 0.01)
    }

    func testFindBoardsFuzzyMatch() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Homework"),
            Board(title: "Work")
        ]

        let results = EntityLookup.findBoards(query: "Home", in: boards)

        XCTAssertGreaterThanOrEqual(results.count, 1)
        XCTAssertEqual(results[0].board.title, "Home") // Exact match first
    }

    func testFindBoardsNoMatch() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Work")
        ]

        let results = EntityLookup.findBoards(query: "xyz", in: boards)

        XCTAssertTrue(results.isEmpty)
    }

    func testFindBestBoard() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Work"),
            Board(title: "Homework")
        ]

        let best = EntityLookup.findBestBoard(query: "Home", in: boards)

        XCTAssertNotNil(best)
        XCTAssertEqual(best?.title, "Home")
    }

    func testFindBestBoardNoMatch() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Work")
        ]

        let best = EntityLookup.findBestBoard(query: "xyz", in: boards)

        XCTAssertNil(best)
    }

    func testFindBoardsCaseInsensitive() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Work")
        ]

        let results = EntityLookup.findBoards(query: "home", in: boards)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].board.title, "Home")
    }

    // MARK: - Column Lookup

    func testFindColumnsExactMatch() {
        let board = Board(title: "Home")
        let columns = [
            Column(board: board.id, title: "To Do", index: 0),
            Column(board: board.id, title: "In Progress", index: 1),
            Column(board: board.id, title: "Done", index: 2)
        ]

        let results = EntityLookup.findColumns(
            query: "To Do",
            in: columns,
            boards: [board]
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].column.title, "To Do")
        XCTAssertEqual(results[0].board.title, "Home")
        XCTAssertEqual(results[0].score, 1.0, accuracy: 0.01)
    }

    func testFindColumnsFuzzyMatch() {
        let board = Board(title: "Home")
        let columns = [
            Column(board: board.id, title: "To Do", index: 0),
            Column(board: board.id, title: "Done", index: 1)
        ]

        let results = EntityLookup.findColumns(
            query: "todo",
            in: columns,
            boards: [board]
        )

        XCTAssertGreaterThanOrEqual(results.count, 1, "Expected at least 1 result for query 'todo'")
        XCTAssertFalse(results.isEmpty, "Results should not be empty")
        XCTAssertEqual(results[0].column.title, "To Do")
    }

    func testFindBestColumn() {
        let board = Board(title: "Home")
        let columns = [
            Column(board: board.id, title: "To Do", index: 0),
            Column(board: board.id, title: "Done", index: 1)
        ]

        let best = EntityLookup.findBestColumn(
            query: "To Do",
            in: columns,
            boards: [board]
        )

        XCTAssertNotNil(best)
        XCTAssertEqual(best?.column.title, "To Do")
        XCTAssertEqual(best?.board.title, "Home")
    }

    func testFindColumnsInBoard() {
        let homeBoard = Board(title: "Home")
        let workBoard = Board(title: "Work")

        let columns = [
            Column(board: homeBoard.id, title: "To Do", index: 0),
            Column(board: homeBoard.id, title: "Done", index: 1),
            Column(board: workBoard.id, title: "To Do", index: 0)
        ]

        let results = EntityLookup.findColumns(
            query: "To Do",
            inBoard: homeBoard,
            columns: columns
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].column.title, "To Do")
        XCTAssertEqual(results[0].board.id, homeBoard.id)
    }

    func testFindColumnsWithMissingBoard() {
        let board = Board(title: "Home")
        let columns = [
            Column(board: BoardID(), title: "To Do", index: 0) // Different board ID
        ]

        let results = EntityLookup.findColumns(
            query: "To Do",
            in: columns,
            boards: [board]
        )

        XCTAssertTrue(results.isEmpty) // Column's board not in provided boards
    }

    // MARK: - List Lookup

    func testFindListsExactMatch() {
        let lists = [
            PersonalList(cardID: CardID(), title: "Groceries"),
            PersonalList(cardID: CardID(), title: "Packing"),
            PersonalList(cardID: CardID(), title: "Shopping")
        ]

        let results = EntityLookup.findLists(query: "Groceries", in: lists)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].list.title, "Groceries")
        XCTAssertEqual(results[0].score, 1.0, accuracy: 0.01)
    }

    func testFindListsFuzzyMatch() {
        let lists = [
            PersonalList(cardID: CardID(), title: "Groceries"),
            PersonalList(cardID: CardID(), title: "Shopping")
        ]

        let results = EntityLookup.findLists(query: "groc", in: lists)

        XCTAssertGreaterThanOrEqual(results.count, 1)
        XCTAssertEqual(results[0].list.title, "Groceries")
    }

    func testFindBestList() {
        let lists = [
            PersonalList(cardID: CardID(), title: "Groceries"),
            PersonalList(cardID: CardID(), title: "Packing")
        ]

        let best = EntityLookup.findBestList(query: "Groceries", in: lists)

        XCTAssertNotNil(best)
        XCTAssertEqual(best?.title, "Groceries")
    }

    func testFindBestListNoMatch() {
        let lists = [
            PersonalList(cardID: CardID(), title: "Groceries"),
            PersonalList(cardID: CardID(), title: "Packing")
        ]

        let best = EntityLookup.findBestList(query: "xyz", in: lists)

        XCTAssertNil(best)
    }

    func testFindListsCaseInsensitive() {
        let lists = [
            PersonalList(cardID: CardID(), title: "Groceries")
        ]

        let results = EntityLookup.findLists(query: "groceries", in: lists)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].list.title, "Groceries")
    }

    // MARK: - Threshold Tests

    func testFindBoardsWithCustomThreshold() {
        let boards = [
            Board(title: "Home"),
            Board(title: "Work")
        ]

        // Use high threshold - only exact or very close matches
        let results = EntityLookup.findBoards(query: "Hom", in: boards, threshold: 0.85)

        XCTAssertGreaterThanOrEqual(results.count, 1)
        XCTAssertEqual(results[0].board.title, "Home")
    }

    func testFindListsWithLowThreshold() {
        let lists = [
            PersonalList(cardID: CardID(), title: "Groceries"),
            PersonalList(cardID: CardID(), title: "Shopping")
        ]

        // Use low threshold - more permissive matching
        let results = EntityLookup.findLists(query: "shop", in: lists, threshold: 0.3)

        XCTAssertGreaterThanOrEqual(results.count, 1)
    }

    // MARK: - Sorting Tests

    func testResultsSortedByScore() {
        let boards = [
            Board(title: "Homework"),
            Board(title: "Home"),
            Board(title: "Work Home")
        ]

        let results = EntityLookup.findBoards(query: "Home", in: boards, threshold: 0.3)

        // Results should be sorted by score (descending)
        for i in 0..<(results.count - 1) {
            XCTAssertGreaterThanOrEqual(results[i].score, results[i + 1].score)
        }

        // Exact match should be first
        XCTAssertEqual(results[0].board.title, "Home")
    }
}
