// Tests/IntentsTests/AddCardIntentTests.swift
// Integration tests for AddCardIntent

#if canImport(AppIntents)
import XCTest
import Domain
import PersistenceInterfaces
import PersistenceGRDB
@testable import UseCases

@available(iOS 16.0, macOS 13.0, *)
final class AddCardIntentTests: XCTestCase {
    var boardsRepo: GRDBBoardsRepository!
    var dbURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create temporary in-memory database
        let tempDir = FileManager.default.temporaryDirectory
        dbURL = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")

        let provider = try GRDBRepositoryProvider(databaseURL: dbURL)
        boardsRepo = provider.boardsRepository as? GRDBBoardsRepository
    }

    override func tearDown() async throws {
        boardsRepo = nil
        if let dbURL = dbURL {
            try? FileManager.default.removeItem(at: dbURL)
        }
        try await super.tearDown()
    }

    // MARK: - Fuzzy Lookup Tests

    func testFindBoardExactMatch() async throws {
        // Create test boards
        let home = Board(title: "Home")
        let work = Board(title: "Work")

        try await boardsRepo.createBoard(home)
        try await boardsRepo.createBoard(work)

        // Test exact match
        let allBoards = try await boardsRepo.loadBoards()
        let result = EntityLookup.findBestBoard(query: "Home", in: allBoards)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Home")
    }

    func testFindBoardFuzzyMatch() async throws {
        // Create test board
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        // Test fuzzy match
        let allBoards = try await boardsRepo.loadBoards()
        let result = EntityLookup.findBestBoard(query: "hom", in: allBoards)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Home")
    }

    func testFindColumnExactMatch() async throws {
        // Create test board and columns
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        let inProgress = Column(board: home.id, title: "In Progress", index: 1)

        try await boardsRepo.createColumn(toDo)
        try await boardsRepo.createColumn(inProgress)

        // Test exact match
        let allColumns = try await boardsRepo.loadColumns(for: home.id)
        let result = EntityLookup.findBestColumn(
            query: "To Do",
            in: allColumns,
            boards: [home]
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.column.title, "To Do")
        XCTAssertEqual(result?.board.title, "Home")
    }

    func testFindColumnFuzzyMatch() async throws {
        // Create test board and column
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(toDo)

        // Test fuzzy match
        let allColumns = try await boardsRepo.loadColumns(for: home.id)
        let result = EntityLookup.findBestColumn(
            query: "todo",
            in: allColumns,
            boards: [home]
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.column.title, "To Do")
    }

    func testFindColumnInSpecificBoard() async throws {
        // Create test boards and columns
        let home = Board(title: "Home")
        let work = Board(title: "Work")
        try await boardsRepo.createBoard(home)
        try await boardsRepo.createBoard(work)

        let homeColumn = Column(board: home.id, title: "To Do", index: 0)
        let workColumn = Column(board: work.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(homeColumn)
        try await boardsRepo.createColumn(workColumn)

        // Find column in specific board
        let allColumns = try await boardsRepo.loadColumns(for: home.id)
        let results = EntityLookup.findColumns(
            query: "To Do",
            inBoard: home,
            columns: allColumns
        )

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].board.id, home.id)
    }

    // MARK: - Add Card Tests

    func testAddCardToColumn() async throws {
        // Create test board and column
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(toDo)

        // Add card
        let card = Card(
            column: toDo.id,
            title: "Pay strata",
            sortKey: 0
        )
        try await boardsRepo.createCard(card)

        // Verify
        let cards = try await boardsRepo.loadCards(for: toDo.id)
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards[0].title, "Pay strata")
    }

    func testAddCardWithDetails() async throws {
        // Create test board and column
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(toDo)

        // Add card with details
        let card = Card(
            column: toDo.id,
            title: "Pay strata",
            details: "Monthly payment due",
            sortKey: 0
        )
        try await boardsRepo.createCard(card)

        // Verify
        let loaded = try await boardsRepo.loadCard(card.id)
        XCTAssertEqual(loaded.title, "Pay strata")
        XCTAssertEqual(loaded.details, "Monthly payment due")
    }

    func testAddCardWithDueDate() async throws {
        // Create test board and column
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(toDo)

        // Add card with due date
        let dueDate = Date()
        let card = Card(
            column: toDo.id,
            title: "Pay strata",
            due: dueDate,
            sortKey: 0
        )
        try await boardsRepo.createCard(card)

        // Verify
        let loaded = try await boardsRepo.loadCard(card.id)
        XCTAssertEqual(loaded.title, "Pay strata")
        XCTAssertNotNil(loaded.due)
    }

    func testAddMultipleCards() async throws {
        // Create test board and column
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(toDo)

        // Add multiple cards
        let card1 = Card(column: toDo.id, title: "Pay strata", sortKey: 0)
        let card2 = Card(column: toDo.id, title: "Buy groceries", sortKey: 1)
        let card3 = Card(column: toDo.id, title: "Call dentist", sortKey: 2)

        try await boardsRepo.createCard(card1)
        try await boardsRepo.createCard(card2)
        try await boardsRepo.createCard(card3)

        // Verify
        let cards = try await boardsRepo.loadCards(for: toDo.id)
        XCTAssertEqual(cards.count, 3)
        XCTAssertEqual(cards[0].title, "Pay strata")
        XCTAssertEqual(cards[1].title, "Buy groceries")
        XCTAssertEqual(cards[2].title, "Call dentist")
    }

    func testSortKeyIncrement() async throws {
        // Create test board and column
        let home = Board(title: "Home")
        try await boardsRepo.createBoard(home)

        let toDo = Column(board: home.id, title: "To Do", index: 0)
        try await boardsRepo.createColumn(toDo)

        // Simulate the intent's behavior: get max sort key and increment
        var existingCards = try await boardsRepo.loadCards(for: toDo.id)
        var maxSortKey = existingCards.map(\.sortKey).max() ?? 0
        var newSortKey = maxSortKey + 1

        let card1 = Card(column: toDo.id, title: "First", sortKey: newSortKey)
        try await boardsRepo.createCard(card1)

        // Add second card
        existingCards = try await boardsRepo.loadCards(for: toDo.id)
        maxSortKey = existingCards.map(\.sortKey).max() ?? 0
        newSortKey = maxSortKey + 1

        let card2 = Card(column: toDo.id, title: "Second", sortKey: newSortKey)
        try await boardsRepo.createCard(card2)

        // Verify sort keys are incrementing
        let allCards = try await boardsRepo.loadCards(for: toDo.id)
        XCTAssertEqual(allCards.count, 2)
        XCTAssertLessThan(allCards[0].sortKey, allCards[1].sortKey)
    }
}
#endif
