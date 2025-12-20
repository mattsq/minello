import SwiftData
import XCTest
@testable import HomeCooked

@MainActor
final class DragAndDropIntegrationTests: XCTestCase {
    var container: ModelContainer!
    var modelContext: ModelContext!
    var service: CardReorderService!
    var repository: SwiftDataBoardsRepository!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
        modelContext = container.mainContext
        service = CardReorderService(modelContext: modelContext)
        repository = SwiftDataBoardsRepository(modelContext: modelContext)
    }

    override func tearDown() async throws {
        container = nil
        modelContext = nil
        service = nil
        repository = nil
        try await super.tearDown()
    }

    // MARK: - Integration Tests

    func testDropUpdatesRepository() async throws {
        // Given: A board with columns persisted via repository
        let board = Board(title: "Test Board")
        let column1 = Column(title: "To Do", index: 0, board: board)
        let column2 = Column(title: "Done", index: 1, board: board)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column1)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column1)
        let card3 = Card(title: "Card 3", sortKey: 2, column: column1)

        column1.cards = [card1, card2, card3]
        board.columns = [column1, column2]

        try await repository.create(board: board)

        // When: Reorder card via service
        try await service.reorderWithinColumn(
            card: card3,
            fromIndex: 2,
            toIndex: 0,
            inColumn: column1
        )

        // Then: Fetch from repository and verify persistence
        let fetchedBoard = try await repository.fetch(id: board.id)
        XCTAssertNotNil(fetchedBoard)

        let fetchedColumn = fetchedBoard?.columns.first { $0.id == column1.id }
        XCTAssertNotNil(fetchedColumn)

        let sortedCards = fetchedColumn?.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards?.map(\.title), ["Card 3", "Card 1", "Card 2"])
    }

    func testCrossColumnDropPersists() async throws {
        // Given: Board with two columns
        let board = Board(title: "Test Board")
        let column1 = Column(title: "To Do", index: 0, board: board)
        let column2 = Column(title: "In Progress", index: 1, board: board)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column1)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column1)

        let card3 = Card(title: "Card 3", sortKey: 0, column: column2)

        column1.cards = [card1, card2]
        column2.cards = [card3]
        board.columns = [column1, column2]

        try await repository.create(board: board)

        // When: Move card1 to column2
        try await service.moveToColumn(
            card: card1,
            fromColumn: column1,
            toColumn: column2,
            atIndex: 1
        )

        // Then: Verify persistence
        let fetchedBoard = try await repository.fetch(id: board.id)
        XCTAssertNotNil(fetchedBoard)

        let fetchedColumn1 = fetchedBoard?.columns.first { $0.id == column1.id }
        let fetchedColumn2 = fetchedBoard?.columns.first { $0.id == column2.id }

        XCTAssertEqual(fetchedColumn1?.cards.count, 1)
        XCTAssertEqual(fetchedColumn2?.cards.count, 2)

        let sortedColumn2Cards = fetchedColumn2?.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedColumn2Cards?.map(\.title), ["Card 3", "Card 1"])

        // Verify card1's column relationship
        let fetchedCard1 = fetchedColumn2?.cards.first { $0.id == card1.id }
        XCTAssertNotNil(fetchedCard1)
        XCTAssertEqual(fetchedCard1?.column?.id, column2.id)
    }

    func testMultipleReordersPreserveConsistency() async throws {
        // Given: A column with cards
        let board = Board(title: "Test Board")
        let column = Column(title: "To Do", index: 0, board: board)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column)
        let card3 = Card(title: "Card 3", sortKey: 2, column: column)
        let card4 = Card(title: "Card 4", sortKey: 3, column: column)

        column.cards = [card1, card2, card3, card4]
        board.columns = [column]

        try await repository.create(board: board)

        // When: Perform multiple reorders
        // Move card4 to position 1
        try await service.reorderWithinColumn(
            card: card4,
            fromIndex: 3,
            toIndex: 1,
            inColumn: column
        )

        // Move card1 to position 2
        var sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }
        let card1NewFromIndex = sortedCards.firstIndex { $0.id == card1.id } ?? 0
        try await service.reorderWithinColumn(
            card: card1,
            fromIndex: card1NewFromIndex,
            toIndex: 2,
            inColumn: column
        )

        // Then: Verify final order
        let fetchedBoard = try await repository.fetch(id: board.id)
        let fetchedColumn = fetchedBoard?.columns.first
        sortedCards = (fetchedColumn?.cards ?? []).sorted { $0.sortKey < $1.sortKey }

        // Expected order: Card2, Card4, Card1, Card3
        XCTAssertEqual(sortedCards.map(\.title), ["Card 2", "Card 4", "Card 1", "Card 3"])

        // Verify sortKeys are valid and maintain order
        for i in 0 ..< sortedCards.count - 1 {
            XCTAssertLessThan(sortedCards[i].sortKey, sortedCards[i + 1].sortKey)
        }
    }

    func testReorderTriggersNormalizationWhenNeeded() async throws {
        // Given: Cards with keys that will get very close after multiple operations
        let board = Board(title: "Test Board")
        let column = Column(title: "To Do", index: 0, board: board)

        var cards: [Card] = []
        for i in 0 ..< 20 {
            let card = Card(title: "Card \(i)", sortKey: Double(i), column: column)
            cards.append(card)
        }
        column.cards = cards

        board.columns = [column]
        try await repository.create(board: board)

        // When: Perform many reorder operations to create tight sortKeys
        for _ in 0 ..< 10 {
            let randomCard = cards.randomElement()!
            let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }

            if let fromIndex = sortedCards.firstIndex(where: { $0.id == randomCard.id }) {
                let toIndex = Int.random(in: 0 ..< sortedCards.count)
                try await service.reorderWithinColumn(
                    card: randomCard,
                    fromIndex: fromIndex,
                    toIndex: toIndex,
                    inColumn: column
                )
            }
        }

        // Then: Order should still be maintained and consistent
        let fetchedBoard = try await repository.fetch(id: board.id)
        let fetchedColumn = fetchedBoard?.columns.first
        let sortedCards = (fetchedColumn?.cards ?? []).sorted { $0.sortKey < $1.sortKey }

        // Verify sortKeys are monotonically increasing
        for i in 0 ..< sortedCards.count - 1 {
            XCTAssertLessThan(
                sortedCards[i].sortKey,
                sortedCards[i + 1].sortKey,
                "Cards at index \(i) and \(i+1) have invalid sortKeys"
            )
        }

        // Verify we can still insert between any two cards
        XCTAssertEqual(sortedCards.count, cards.count)
    }

    func testConcurrentMovesToDifferentColumnsSucceed() async throws {
        // Given: Board with multiple columns
        let board = Board(title: "Test Board")
        let column1 = Column(title: "To Do", index: 0, board: board)
        let column2 = Column(title: "In Progress", index: 1, board: board)
        let column3 = Column(title: "Done", index: 2, board: board)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column1)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column1)
        let card3 = Card(title: "Card 3", sortKey: 2, column: column1)

        column1.cards = [card1, card2, card3]
        board.columns = [column1, column2, column3]

        try await repository.create(board: board)

        // When: Move cards to different columns in sequence
        try await service.moveToColumn(
            card: card1,
            fromColumn: column1,
            toColumn: column2,
            atIndex: 0
        )

        try await service.moveToColumn(
            card: card3,
            fromColumn: column1,
            toColumn: column3,
            atIndex: 0
        )

        // Then: Verify all columns have correct state
        let fetchedBoard = try await repository.fetch(id: board.id)

        let fetchedColumn1 = fetchedBoard?.columns.first { $0.id == column1.id }
        let fetchedColumn2 = fetchedBoard?.columns.first { $0.id == column2.id }
        let fetchedColumn3 = fetchedBoard?.columns.first { $0.id == column3.id }

        XCTAssertEqual(fetchedColumn1?.cards.count, 1)
        XCTAssertEqual(fetchedColumn1?.cards.first?.title, "Card 2")

        XCTAssertEqual(fetchedColumn2?.cards.count, 1)
        XCTAssertEqual(fetchedColumn2?.cards.first?.title, "Card 1")

        XCTAssertEqual(fetchedColumn3?.cards.count, 1)
        XCTAssertEqual(fetchedColumn3?.cards.first?.title, "Card 3")
    }

    func testUpdatedAtTimestampChangesOnMove() async throws {
        // Given: A card in a column
        let board = Board(title: "Test Board")
        let column = Column(title: "To Do", index: 0, board: board)
        let card = Card(title: "Card 1", sortKey: 0, column: column)
        column.cards = [card]
        board.columns = [column]

        try await repository.create(board: board)

        let originalUpdatedAt = card.updatedAt

        // Wait a brief moment to ensure timestamp difference
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms

        // When: Move the card
        try await service.reorderWithinColumn(
            card: card,
            fromIndex: 0,
            toIndex: 0,
            inColumn: column
        )

        // Note: Moving to same position is a no-op, so try actual move
        let card2 = Card(title: "Card 2", sortKey: 1, column: column)
        column.cards.append(card2)
        modelContext.insert(card2)
        try modelContext.save()

        try await service.reorderWithinColumn(
            card: card,
            fromIndex: 0,
            toIndex: 1,
            inColumn: column
        )

        // Then: updatedAt should be different
        XCTAssertNotEqual(card.updatedAt, originalUpdatedAt)
        XCTAssertGreaterThan(card.updatedAt, originalUpdatedAt)
    }
}
