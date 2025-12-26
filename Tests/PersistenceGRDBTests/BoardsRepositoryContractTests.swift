// Tests/PersistenceGRDBTests/BoardsRepositoryContractTests.swift
// Contract tests for BoardsRepository that can run against any implementation

import Domain
import Foundation
import PersistenceGRDB
import PersistenceInterfaces
import XCTest

/// Contract tests for BoardsRepository
/// These tests can be run against any implementation of BoardsRepository
final class BoardsRepositoryContractTests: XCTestCase {
    var repository: BoardsRepository!

    override func setUp() async throws {
        try await super.setUp()
        // Use in-memory GRDB for testing
        repository = try GRDBBoardsRepository.inMemory()
    }

    override func tearDown() async throws {
        repository = nil
        try await super.tearDown()
    }

    // MARK: - Board Tests

    func testCreateAndLoadBoard() async throws {
        let board = Board(
            id: BoardID(),
            title: "Test Board",
            columns: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        try await repository.createBoard(board)

        let loaded = try await repository.loadBoard(board.id)
        XCTAssertEqual(loaded.id, board.id)
        XCTAssertEqual(loaded.title, board.title)
        XCTAssertEqual(loaded.columns, board.columns)
    }

    func testLoadAllBoards() async throws {
        let board1 = Board(title: "Board 1")
        let board2 = Board(title: "Board 2")

        try await repository.createBoard(board1)
        try await repository.createBoard(board2)

        let boards = try await repository.loadBoards()
        XCTAssertEqual(boards.count, 2)
        XCTAssertTrue(boards.contains { $0.id == board1.id })
        XCTAssertTrue(boards.contains { $0.id == board2.id })
    }

    func testUpdateBoard() async throws {
        var board = Board(title: "Original Title")
        try await repository.createBoard(board)

        board.title = "Updated Title"
        board.updatedAt = Date()
        try await repository.updateBoard(board)

        let loaded = try await repository.loadBoard(board.id)
        XCTAssertEqual(loaded.title, "Updated Title")
    }

    func testDeleteBoard() async throws {
        let board = Board(title: "To Delete")
        try await repository.createBoard(board)

        try await repository.deleteBoard(board.id)

        do {
            _ = try await repository.loadBoard(board.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testLoadNonexistentBoard() async throws {
        let nonexistentID = BoardID()

        do {
            _ = try await repository.loadBoard(nonexistentID)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    // MARK: - Column Tests

    func testCreateAndLoadColumn() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(
            id: ColumnID(),
            board: board.id,
            title: "To Do",
            index: 0,
            cards: []
        )

        try await repository.createColumn(column)

        let loaded = try await repository.loadColumn(column.id)
        XCTAssertEqual(loaded.id, column.id)
        XCTAssertEqual(loaded.board, board.id)
        XCTAssertEqual(loaded.title, column.title)
        XCTAssertEqual(loaded.index, column.index)
    }

    func testLoadColumnsForBoard() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column1 = Column(board: board.id, title: "To Do", index: 0)
        let column2 = Column(board: board.id, title: "In Progress", index: 1)
        let column3 = Column(board: board.id, title: "Done", index: 2)

        try await repository.createColumn(column1)
        try await repository.createColumn(column2)
        try await repository.createColumn(column3)

        let columns = try await repository.loadColumns(for: board.id)
        XCTAssertEqual(columns.count, 3)
        // Verify they're sorted by index
        XCTAssertEqual(columns[0].title, "To Do")
        XCTAssertEqual(columns[1].title, "In Progress")
        XCTAssertEqual(columns[2].title, "Done")
    }

    func testUpdateColumn() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        var column = Column(board: board.id, title: "Original", index: 0)
        try await repository.createColumn(column)

        column.title = "Updated"
        column.updatedAt = Date()
        try await repository.updateColumn(column)

        let loaded = try await repository.loadColumn(column.id)
        XCTAssertEqual(loaded.title, "Updated")
    }

    func testSaveMultipleColumns() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let columns = [
            Column(board: board.id, title: "Col 1", index: 0),
            Column(board: board.id, title: "Col 2", index: 1),
            Column(board: board.id, title: "Col 3", index: 2),
        ]

        try await repository.saveColumns(columns)

        let loaded = try await repository.loadColumns(for: board.id)
        XCTAssertEqual(loaded.count, 3)
    }

    func testDeleteColumn() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Delete", index: 0)
        try await repository.createColumn(column)

        try await repository.deleteColumn(column.id)

        do {
            _ = try await repository.loadColumn(column.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testDeleteBoardCascadesToColumns() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "Column", index: 0)
        try await repository.createColumn(column)

        try await repository.deleteBoard(board.id)

        // Column should also be deleted due to cascade
        do {
            _ = try await repository.loadColumn(column.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    // MARK: - Card Tests

    func testCreateAndLoadCard() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let card = Card(
            id: CardID(),
            column: column.id,
            title: "Test Card",
            details: "Card details",
            due: nil,
            tags: ["test", "important"],
            checklist: [
                ChecklistItem(text: "Item 1", isDone: false),
                ChecklistItem(text: "Item 2", isDone: true),
            ],
            sortKey: 1.0
        )

        try await repository.createCard(card)

        let loaded = try await repository.loadCard(card.id)
        XCTAssertEqual(loaded.id, card.id)
        XCTAssertEqual(loaded.column, column.id)
        XCTAssertEqual(loaded.title, card.title)
        XCTAssertEqual(loaded.details, card.details)
        XCTAssertEqual(loaded.tags, card.tags)
        XCTAssertEqual(loaded.checklist.count, 2)
        XCTAssertEqual(loaded.sortKey, card.sortKey)
    }

    func testLoadCardsForColumn() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let card1 = Card(column: column.id, title: "Card 1", sortKey: 1.0)
        let card2 = Card(column: column.id, title: "Card 2", sortKey: 0.5)
        let card3 = Card(column: column.id, title: "Card 3", sortKey: 2.0)

        try await repository.createCard(card1)
        try await repository.createCard(card2)
        try await repository.createCard(card3)

        let cards = try await repository.loadCards(for: column.id)
        XCTAssertEqual(cards.count, 3)
        // Verify they're sorted by sortKey
        XCTAssertEqual(cards[0].title, "Card 2")
        XCTAssertEqual(cards[1].title, "Card 1")
        XCTAssertEqual(cards[2].title, "Card 3")
    }

    func testUpdateCard() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        var card = Card(column: column.id, title: "Original Title", sortKey: 1.0)
        try await repository.createCard(card)

        card.title = "Updated Title"
        card.details = "New details"
        card.updatedAt = Date()
        try await repository.updateCard(card)

        let loaded = try await repository.loadCard(card.id)
        XCTAssertEqual(loaded.title, "Updated Title")
        XCTAssertEqual(loaded.details, "New details")
    }

    func testSaveMultipleCards() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let cards = [
            Card(column: column.id, title: "Card 1", sortKey: 1.0),
            Card(column: column.id, title: "Card 2", sortKey: 2.0),
            Card(column: column.id, title: "Card 3", sortKey: 3.0),
        ]

        try await repository.saveCards(cards)

        let loaded = try await repository.loadCards(for: column.id)
        XCTAssertEqual(loaded.count, 3)
    }

    func testDeleteCard() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let card = Card(column: column.id, title: "To Delete", sortKey: 1.0)
        try await repository.createCard(card)

        try await repository.deleteCard(card.id)

        do {
            _ = try await repository.loadCard(card.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testDeleteColumnCascadesToCards() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let card = Card(column: column.id, title: "Card", sortKey: 1.0)
        try await repository.createCard(card)

        try await repository.deleteColumn(column.id)

        // Card should also be deleted due to cascade
        do {
            _ = try await repository.loadCard(card.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    // MARK: - Query Tests

    func testSearchCards() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let card1 = Card(column: column.id, title: "Buy groceries", details: "milk and bread", sortKey: 1.0)
        let card2 = Card(column: column.id, title: "Call dentist", details: "schedule appointment", sortKey: 2.0)
        let card3 = Card(column: column.id, title: "Fix bug", details: "grocery list feature", sortKey: 3.0)

        try await repository.createCard(card1)
        try await repository.createCard(card2)
        try await repository.createCard(card3)

        print("=== TEST DEBUG: testSearchCards ===")
        print("Created 3 cards:")
        print("  Card1: title=\"\(card1.title)\" details=\"\(card1.details)\"")
        print("  Card2: title=\"\(card2.title)\" details=\"\(card2.details)\"")
        print("  Card3: title=\"\(card3.title)\" details=\"\(card3.details)\"")
        print("Search query: \"grocery\"")

        let results = try await repository.searchCards(query: "grocery")

        print("Search returned \(results.count) results:")
        for (i, card) in results.enumerated() {
            print("  Result[\(i)]: title=\"\(card.title)\" details=\"\(card.details)\"")
        }
        print("Expected 2 results: \"Buy groceries\" and \"Fix bug\"")
        print("=== END DEBUG ===")

        XCTAssertEqual(results.count, 2, "Expected 2 cards matching 'grocery', got \(results.count). Titles: \(results.map { $0.title })")
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Buy groceries"), "Expected to find 'Buy groceries' in results")
        XCTAssertTrue(titles.contains("Fix bug"), "Expected to find 'Fix bug' in results")
    }

    func testFindCardsByTag() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let card1 = Card(column: column.id, title: "Card 1", tags: ["urgent", "important"], sortKey: 1.0)
        let card2 = Card(column: column.id, title: "Card 2", tags: ["low-priority"], sortKey: 2.0)
        let card3 = Card(column: column.id, title: "Card 3", tags: ["urgent"], sortKey: 3.0)

        try await repository.createCard(card1)
        try await repository.createCard(card2)
        try await repository.createCard(card3)

        let results = try await repository.findCards(byTag: "urgent")
        XCTAssertEqual(results.count, 2)
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Card 1"))
        XCTAssertTrue(titles.contains("Card 3"))
    }

    func testFindCardsByDueDate() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: today)!

        let card1 = Card(column: column.id, title: "Due Tomorrow", due: tomorrow, sortKey: 1.0)
        let card2 = Card(column: column.id, title: "Due Next Week", due: nextWeek, sortKey: 2.0)
        let card3 = Card(column: column.id, title: "Due Next Month", due: nextMonth, sortKey: 3.0)

        try await repository.createCard(card1)
        try await repository.createCard(card2)
        try await repository.createCard(card3)

        let results = try await repository.findCards(dueBetween: today, and: nextWeek)
        XCTAssertEqual(results.count, 2)
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Due Tomorrow"))
        XCTAssertTrue(titles.contains("Due Next Week"))
    }

    func testCardWithDueDate() async throws {
        let board = Board(title: "Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await repository.createColumn(column)

        let dueDate = Date()
        let card = Card(column: column.id, title: "Card with due", due: dueDate, sortKey: 1.0)
        try await repository.createCard(card)

        let loaded = try await repository.loadCard(card.id)
        XCTAssertNotNil(loaded.due)
        if let loadedDue = loaded.due {
            // Allow 1 second difference for rounding
            XCTAssertEqual(loadedDue.timeIntervalSince1970, dueDate.timeIntervalSince1970, accuracy: 1.0)
        }
    }
}
