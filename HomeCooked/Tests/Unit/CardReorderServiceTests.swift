import SwiftData
import XCTest
@testable import HomeCooked

@MainActor
final class CardReorderServiceTests: XCTestCase {
    var container: ModelContainer!
    var service: CardReorderService!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
        modelContext = container.mainContext
        service = CardReorderService(modelContext: modelContext)
    }

    override func tearDown() async throws {
        container = nil
        service = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - Midpoint Insertion Tests

    func testMidpointInsertionWithinColumn() async throws {
        // Given: A column with 3 cards in order
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 0, column: column)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column)
        let card3 = Card(title: "Card 3", sortKey: 2, column: column)
        column.cards = [card1, card2, card3]

        modelContext.insert(column)
        try modelContext.save()

        // When: Move card3 between card1 and card2
        try await service.reorderWithinColumn(
            card: card3,
            fromIndex: 2,
            toIndex: 1,
            inColumn: column
        )

        // Then: card3's sortKey should be between card1 and card2
        XCTAssertEqual(card1.sortKey, 0)
        XCTAssertEqual(card2.sortKey, 1)
        XCTAssertEqual(card3.sortKey, 0.5, accuracy: 0.001)

        // Verify order
        let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards.map(\.title), ["Card 1", "Card 3", "Card 2"])
    }

    func testMidpointInsertionAtBeginning() async throws {
        // Given
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 0, column: column)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column)
        let card3 = Card(title: "Card 3", sortKey: 2, column: column)
        column.cards = [card1, card2, card3]

        modelContext.insert(column)
        try modelContext.save()

        // When: Move card3 to the beginning
        try await service.reorderWithinColumn(
            card: card3,
            fromIndex: 2,
            toIndex: 0,
            inColumn: column
        )

        // Then: card3's sortKey should be less than card1
        XCTAssertLessThan(card3.sortKey, card1.sortKey)
        XCTAssertEqual(card3.sortKey, -1.0)

        // Verify order
        let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards.map(\.title), ["Card 3", "Card 1", "Card 2"])
    }

    func testMidpointInsertionAtEnd() async throws {
        // Given
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 0, column: column)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column)
        let card3 = Card(title: "Card 3", sortKey: 2, column: column)
        column.cards = [card1, card2, card3]

        modelContext.insert(column)
        try modelContext.save()

        // When: Move card1 to the end
        try await service.reorderWithinColumn(
            card: card1,
            fromIndex: 0,
            toIndex: 2,
            inColumn: column
        )

        // Then: card1's sortKey should be greater than card3
        XCTAssertGreaterThan(card1.sortKey, card3.sortKey)
        XCTAssertEqual(card1.sortKey, 3.0)

        // Verify order
        let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards.map(\.title), ["Card 2", "Card 3", "Card 1"])
    }

    // MARK: - Cross-Column Move Tests

    func testCrossColumnMovePreservesRelativeOrder() async throws {
        // Given: Two columns with cards
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "In Progress", index: 1)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column1)
        let card2 = Card(title: "Card 2", sortKey: 1, column: column1)
        column1.cards = [card1, card2]

        let card3 = Card(title: "Card 3", sortKey: 0, column: column2)
        let card4 = Card(title: "Card 4", sortKey: 1, column: column2)
        column2.cards = [card3, card4]

        modelContext.insert(column1)
        modelContext.insert(column2)
        try modelContext.save()

        // When: Move card1 between card3 and card4 in column2
        try await service.moveToColumn(
            card: card1,
            fromColumn: column1,
            toColumn: column2,
            atIndex: 1
        )

        // Then: Verify card1 is in column2
        XCTAssertEqual(card1.column?.id, column2.id)

        // Verify order in column2
        let sortedCards = column2.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards.map(\.title), ["Card 3", "Card 1", "Card 4"])

        // Verify card1's sortKey is between card3 and card4
        XCTAssertGreaterThan(card1.sortKey, card3.sortKey)
        XCTAssertLessThan(card1.sortKey, card4.sortKey)
        XCTAssertEqual(card1.sortKey, 0.5, accuracy: 0.001)
    }

    func testMoveToEmptyColumn() async throws {
        // Given
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "Empty", index: 1)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column1)
        column1.cards = [card1]
        column2.cards = []

        modelContext.insert(column1)
        modelContext.insert(column2)
        try modelContext.save()

        // When: Move card to empty column
        try await service.moveToColumn(
            card: card1,
            fromColumn: column1,
            toColumn: column2,
            atIndex: 0
        )

        // Then: Verify card1 is in column2 with sortKey 0
        XCTAssertEqual(card1.column?.id, column2.id)
        XCTAssertEqual(card1.sortKey, 0.0)
        XCTAssertEqual(column2.cards.count, 1)
    }

    func testMoveToBeginningOfColumn() async throws {
        // Given
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "In Progress", index: 1)

        let card1 = Card(title: "Card 1", sortKey: 0, column: column1)
        column1.cards = [card1]

        let card2 = Card(title: "Card 2", sortKey: 10, column: column2)
        let card3 = Card(title: "Card 3", sortKey: 20, column: column2)
        column2.cards = [card2, card3]

        modelContext.insert(column1)
        modelContext.insert(column2)
        try modelContext.save()

        // When: Move card1 to beginning of column2
        try await service.moveToColumn(
            card: card1,
            fromColumn: column1,
            toColumn: column2,
            atIndex: 0
        )

        // Then
        XCTAssertEqual(card1.column?.id, column2.id)
        XCTAssertLessThan(card1.sortKey, card2.sortKey)

        let sortedCards = column2.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards.map(\.title), ["Card 1", "Card 2", "Card 3"])
    }

    // MARK: - Normalization Tests

    func testNormalizationOccursWhenKeysAreTooClose() async throws {
        // Given: Cards with very close sortKeys
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 0.0000, column: column)
        let card2 = Card(title: "Card 2", sortKey: 0.0001, column: column)
        let card3 = Card(title: "Card 3", sortKey: 0.0002, column: column)
        column.cards = [card1, card2, card3]

        modelContext.insert(column)
        try modelContext.save()

        // When: Trigger normalization
        try await service.normalizeColumn(column)

        // Then: Keys should be normalized to integers
        XCTAssertEqual(card1.sortKey, 0.0)
        XCTAssertEqual(card2.sortKey, 1.0)
        XCTAssertEqual(card3.sortKey, 2.0)
    }

    func testNormalizationPreservesOrder() async throws {
        // Given: Cards with random sortKeys
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 5.3, column: column)
        let card2 = Card(title: "Card 2", sortKey: 17.9, column: column)
        let card3 = Card(title: "Card 3", sortKey: 1.2, column: column)
        column.cards = [card1, card2, card3]

        modelContext.insert(column)
        try modelContext.save()

        // When: Normalize
        try await service.normalizeColumn(column)

        // Then: Order preserved, keys are sequential integers
        let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards.map(\.title), ["Card 3", "Card 1", "Card 2"])
        XCTAssertEqual(sortedCards[0].sortKey, 0.0)
        XCTAssertEqual(sortedCards[1].sortKey, 1.0)
        XCTAssertEqual(sortedCards[2].sortKey, 2.0)
    }

    func testNoOpWhenIndicesAreIdentical() async throws {
        // Given
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 0, column: column)
        column.cards = [card1]

        modelContext.insert(column)
        try modelContext.save()

        let originalSortKey = card1.sortKey

        // When: Try to reorder to same position
        try await service.reorderWithinColumn(
            card: card1,
            fromIndex: 0,
            toIndex: 0,
            inColumn: column
        )

        // Then: sortKey unchanged
        XCTAssertEqual(card1.sortKey, originalSortKey)
    }
}
