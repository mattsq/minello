// Tests/IntentsTests/AddListItemIntentTests.swift
// Integration tests for AddListItemIntent (card-centric)

#if canImport(AppIntents)
import XCTest
import Domain
import PersistenceInterfaces
import PersistenceGRDB
@testable import UseCases

@available(iOS 16.0, macOS 13.0, *)
final class AddListItemIntentTests: XCTestCase {
    var boardsRepo: GRDBBoardsRepository!
    var listsRepo: GRDBListsRepository!
    var dbURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create temporary in-memory database
        let tempDir = FileManager.default.temporaryDirectory
        dbURL = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")

        let provider = try GRDBRepositoryProvider(databaseURL: dbURL)
        boardsRepo = provider.boardsRepository as? GRDBBoardsRepository
        listsRepo = provider.listsRepository as? GRDBListsRepository
    }

    override func tearDown() async throws {
        boardsRepo = nil
        listsRepo = nil
        if let dbURL = dbURL {
            try? FileManager.default.removeItem(at: dbURL)
        }
        try await super.tearDown()
    }

    // MARK: - Board Lookup Tests

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
        let result = EntityLookup.findBestBoard(query: "Hom", in: allBoards)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Home")
    }

    // MARK: - Card Lookup Tests

    func testFindCardExactMatch() async throws {
        // Create board, column, and cards
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        let shopping = Card(column: column.id, title: "Shopping", sortKey: 0)
        let cleaning = Card(column: column.id, title: "Cleaning", sortKey: 1)
        try await boardsRepo.saveCards([shopping, cleaning])

        // Test exact match
        let allColumns = try await boardsRepo.loadColumns(forBoard: board.id)
        let allCards = try await boardsRepo.loadCards(forBoard: board.id)
        let result = EntityLookup.findBestCard(
            query: "Shopping",
            inBoard: board,
            columns: allColumns,
            cards: allCards
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.card.title, "Shopping")
        XCTAssertEqual(result?.column.title, "To Do")
        XCTAssertEqual(result?.board.title, "Home")
    }

    func testFindCardFuzzyMatch() async throws {
        // Create board, column, and card
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        let shopping = Card(column: column.id, title: "Shopping", sortKey: 0)
        try await boardsRepo.saveCards([shopping])

        // Test fuzzy match
        let allColumns = try await boardsRepo.loadColumns(forBoard: board.id)
        let allCards = try await boardsRepo.loadCards(forBoard: board.id)
        let result = EntityLookup.findBestCard(
            query: "Shop",
            inBoard: board,
            columns: allColumns,
            cards: allCards
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.card.title, "Shopping")
    }

    func testCardNotFoundReturnsNil() async throws {
        // Create board and column but no cards
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        // Test no match
        let allColumns = try await boardsRepo.loadColumns(forBoard: board.id)
        let allCards = try await boardsRepo.loadCards(forBoard: board.id)
        let result = EntityLookup.findBestCard(
            query: "Shopping",
            inBoard: board,
            columns: allColumns,
            cards: allCards
        )

        XCTAssertNil(result)
    }

    // MARK: - Card-Centric List Operations

    func testAddItemToExistingCardWithList() async throws {
        // Create board, column, and card
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        var card = Card(column: column.id, title: "Shopping", sortKey: 0)
        try await boardsRepo.saveCards([card])

        // Create list for card
        let list = PersonalList(cardID: card.id, title: "Shopping List", items: [])
        try await listsRepo.createList(list)

        // Update card's listID
        card.listID = list.id
        try await boardsRepo.saveCards([card])

        // Verify card has list
        let (loadedCard, loadedList) = try await boardsRepo.loadCardWithList(card.id)
        XCTAssertNotNil(loadedList)
        XCTAssertEqual(loadedCard.listID, list.id)

        // Add item to list
        var updatedList = loadedList!
        updatedList.items.append(ChecklistItem(text: "Milk", isDone: false))
        try await listsRepo.updateList(updatedList)

        // Verify item added
        let final = try await listsRepo.loadList(list.id)
        XCTAssertEqual(final.items.count, 1)
        XCTAssertEqual(final.items[0].text, "Milk")
    }

    func testAddItemToCardWithoutListCreatesNewList() async throws {
        // Create board, column, and card (no list)
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        let card = Card(column: column.id, title: "Shopping", sortKey: 0)
        try await boardsRepo.saveCards([card])

        // Verify card has no list
        let (loadedCard, loadedList) = try await boardsRepo.loadCardWithList(card.id)
        XCTAssertNil(loadedList)
        XCTAssertNil(loadedCard.listID)

        // Create list for card
        let newList = PersonalList(cardID: card.id, title: "Shopping List", items: [
            ChecklistItem(text: "Milk", isDone: false)
        ])
        try await listsRepo.createList(newList)

        // Update card's listID
        var updatedCard = loadedCard
        updatedCard.listID = newList.id
        try await boardsRepo.saveCards([updatedCard])

        // Verify list created and linked
        let (finalCard, finalList) = try await boardsRepo.loadCardWithList(card.id)
        XCTAssertNotNil(finalList)
        XCTAssertEqual(finalCard.listID, newList.id)
        XCTAssertEqual(finalList?.items.count, 1)
        XCTAssertEqual(finalList?.items[0].text, "Milk")
    }

    func testAddItemWithQuantityAndUnit() async throws {
        // Create board, column, and card with list
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        var card = Card(column: column.id, title: "Shopping", sortKey: 0)
        try await boardsRepo.saveCards([card])

        let list = PersonalList(cardID: card.id, title: "Shopping List", items: [])
        try await listsRepo.createList(list)

        card.listID = list.id
        try await boardsRepo.saveCards([card])

        // Add item with quantity and unit
        var updatedList = list
        updatedList.items.append(ChecklistItem(
            text: "Milk",
            isDone: false,
            quantity: 2.0,
            unit: "liters"
        ))
        try await listsRepo.updateList(updatedList)

        // Verify
        let final = try await listsRepo.loadList(list.id)
        XCTAssertEqual(final.items.count, 1)
        XCTAssertEqual(final.items[0].text, "Milk")
        XCTAssertEqual(final.items[0].quantity, 2.0)
        XCTAssertEqual(final.items[0].unit, "liters")
    }

    func testCreateCardWhenNotFound() async throws {
        // Create board and column (no cards)
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        // Verify no cards exist
        let initialCards = try await boardsRepo.loadCards(forBoard: board.id)
        XCTAssertEqual(initialCards.count, 0)

        // Create new card
        let newCard = Card(column: column.id, title: "Shopping", sortKey: 0)
        try await boardsRepo.saveCards([newCard])

        // Verify card created
        let finalCards = try await boardsRepo.loadCards(forBoard: board.id)
        XCTAssertEqual(finalCards.count, 1)
        XCTAssertEqual(finalCards[0].title, "Shopping")
    }

    func testCardSortKeyCalculation() async throws {
        // Create board, column, and existing cards
        let board = Board(title: "Home")
        try await boardsRepo.createBoard(board)

        let column = Column(board: board.id, title: "To Do", index: 0)
        try await boardsRepo.saveColumns([column])

        let card1 = Card(column: column.id, title: "Card 1", sortKey: 0)
        let card2 = Card(column: column.id, title: "Card 2", sortKey: 1)
        try await boardsRepo.saveCards([card1, card2])

        // Calculate sort key for new card
        let existingCards = try await boardsRepo.loadCards(forBoard: board.id)
        let cardsInColumn = existingCards.filter { $0.column == column.id }
        let maxSortKey = cardsInColumn.map { $0.sortKey }.max() ?? 0
        let newSortKey = maxSortKey + 1

        // Verify new sort key is correct
        XCTAssertEqual(newSortKey, 2.0)

        // Create new card with calculated sort key
        let newCard = Card(column: column.id, title: "Card 3", sortKey: newSortKey)
        try await boardsRepo.saveCards([newCard])

        // Verify all cards have correct order
        let finalCards = try await boardsRepo.loadCards(forBoard: board.id)
        let sorted = finalCards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].title, "Card 1")
        XCTAssertEqual(sorted[1].title, "Card 2")
        XCTAssertEqual(sorted[2].title, "Card 3")
    }
}
#endif
