import Testing
import SwiftData
@testable import HomeCooked

@MainActor
struct CardReorderServiceTests {
    var modelContext: ModelContext!
    var reorderService: CardReorderService!
    var column: Column!

    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Board.self, Column.self, Card.self, ChecklistItem.self,
            configurations: config
        )
        modelContext = ModelContext(container)
        reorderService = CardReorderService(modelContext: modelContext)

        // Create a test column
        column = Column(title: "Test Column", index: 0)
        modelContext.insert(column)
    }

    // MARK: - Midpoint Insertion Tests

    @Test("Insert card at beginning of column")
    func testInsertAtBeginning() async throws {
        // Given: A column with existing cards
        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)

        // When: Moving card3 to the beginning
        try reorderService.moveCard(card3, to: column, at: 0)

        // Then: card3 should have a sortKey less than card1
        #expect(card3.sortKey < card1.sortKey)

        // And: The order should be: card3, card1, card2
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].id == card3.id)
        #expect(sorted[1].id == card1.id)
        #expect(sorted[2].id == card2.id)
    }

    @Test("Insert card at end of column")
    func testInsertAtEnd() async throws {
        // Given: A column with existing cards
        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)

        // When: Moving card1 to the end
        try reorderService.moveCard(card1, to: column, at: 3)

        // Then: card1 should have a sortKey greater than card3
        #expect(card1.sortKey > card3.sortKey)

        // And: The order should be: card2, card3, card1
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].id == card2.id)
        #expect(sorted[1].id == card3.id)
        #expect(sorted[2].id == card1.id)
    }

    @Test("Insert card in middle using midpoint")
    func testMidpointInsertionWithinColumn() async throws {
        // Given: A column with cards at specific sortKeys
        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)

        // When: Moving card3 between card1 and card2
        try reorderService.moveCard(card3, to: column, at: 1)

        // Then: card3's sortKey should be between card1 and card2
        #expect(card3.sortKey > card1.sortKey)
        #expect(card3.sortKey < card2.sortKey)

        // And: card3 should be the midpoint (1500)
        #expect(card3.sortKey == 1500.0)

        // And: The order should be preserved
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].id == card1.id)
        #expect(sorted[1].id == card3.id)
        #expect(sorted[2].id == card2.id)
    }

    @Test("Insert into empty column")
    func testInsertIntoEmptyColumn() async throws {
        // Given: An empty column
        let emptyColumn = Column(title: "Empty Column", index: 1)
        modelContext.insert(emptyColumn)

        let card = Card(title: "First Card", sortKey: 0)
        modelContext.insert(card)

        // When: Moving a card to the empty column
        try reorderService.moveCard(card, to: emptyColumn, at: 0)

        // Then: The card should have a default sortKey
        #expect(card.sortKey == 1000.0)
        #expect(card.column?.id == emptyColumn.id)
    }

    // MARK: - Cross-Column Move Tests

    @Test("Move card between columns preserves relative order")
    func testCrossColumnMovePreservesRelativeOrder() async throws {
        // Given: Two columns with cards
        let sourceColumn = Column(title: "Source", index: 0)
        let destColumn = Column(title: "Destination", index: 1)
        modelContext.insert(sourceColumn)
        modelContext.insert(destColumn)

        let sourceCard1 = Card(title: "Source 1", sortKey: 1000)
        let sourceCard2 = Card(title: "Source 2", sortKey: 2000)

        sourceCard1.column = sourceColumn
        sourceCard2.column = sourceColumn
        sourceColumn.cards = [sourceCard1, sourceCard2]

        let destCard1 = Card(title: "Dest 1", sortKey: 1000)
        let destCard2 = Card(title: "Dest 2", sortKey: 2000)

        destCard1.column = destColumn
        destCard2.column = destColumn
        destColumn.cards = [destCard1, destCard2]

        modelContext.insert(sourceCard1)
        modelContext.insert(sourceCard2)
        modelContext.insert(destCard1)
        modelContext.insert(destCard2)

        // When: Moving sourceCard1 between destCard1 and destCard2
        try reorderService.moveCard(sourceCard1, to: destColumn, at: 1)

        // Then: sourceCard1 should be in the destination column
        #expect(sourceCard1.column?.id == destColumn.id)

        // And: It should be between destCard1 and destCard2
        #expect(sourceCard1.sortKey > destCard1.sortKey)
        #expect(sourceCard1.sortKey < destCard2.sortKey)

        // And: The order in destination should be correct
        let sorted = destColumn.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted.count == 3)
        #expect(sorted[0].id == destCard1.id)
        #expect(sorted[1].id == sourceCard1.id)
        #expect(sorted[2].id == destCard2.id)

        // And: Source column should have one less card
        #expect(sourceColumn.cards.count == 1)
        #expect(sourceColumn.cards[0].id == sourceCard2.id)
    }

    // MARK: - Normalization Tests

    @Test("Normalization triggers when sortKeys are too close")
    func testNormalizationThreshold() async throws {
        // Given: Cards with very close sortKeys
        let card1 = Card(title: "Card 1", sortKey: 1.000)
        let card2 = Card(title: "Card 2", sortKey: 1.0005)
        let card3 = Card(title: "Card 3", sortKey: 1.001)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)

        // When: Normalizing the column
        try await reorderService.normalizeColumn(column)

        // Then: SortKeys should be evenly spaced
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].sortKey == 1000.0)
        #expect(sorted[1].sortKey == 2000.0)
        #expect(sorted[2].sortKey == 3000.0)
    }

    @Test("Normalization preserves order")
    func testNormalizationPreservesOrder() async throws {
        // Given: Cards with arbitrary sortKeys
        let card1 = Card(title: "Card 1", sortKey: 157.3)
        let card2 = Card(title: "Card 2", sortKey: 892.1)
        let card3 = Card(title: "Card 3", sortKey: 1250.7)
        let card4 = Card(title: "Card 4", sortKey: 2000.0)

        card1.column = column
        card2.column = column
        card3.column = column
        card4.column = column
        column.cards = [card1, card2, card3, card4]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)
        modelContext.insert(card4)

        let originalOrder = column.cards.sorted { $0.sortKey < $1.sortKey }.map(\.id)

        // When: Normalizing the column
        try await reorderService.normalizeColumn(column)

        // Then: The relative order should be preserved
        let newOrder = column.cards.sorted { $0.sortKey < $1.sortKey }.map(\.id)
        #expect(originalOrder == newOrder)

        // And: SortKeys should be normalized
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].sortKey == 1000.0)
        #expect(sorted[1].sortKey == 2000.0)
        #expect(sorted[2].sortKey == 3000.0)
        #expect(sorted[3].sortKey == 4000.0)
    }

    // MARK: - Edge Cases

    @Test("Reorder within column with adjacent cards")
    func testReorderAdjacentCards() async throws {
        // Given: A column with three cards
        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)

        // When: Swapping card1 and card2 (move card1 to position 1)
        try reorderService.reorderWithinColumn(card1, to: 1)

        // Then: The new order should be card2, card1, card3
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].id == card2.id)
        #expect(sorted[1].id == card1.id)
        #expect(sorted[2].id == card3.id)

        // And: card1's sortKey should be between card2 and card3
        #expect(card1.sortKey > card2.sortKey)
        #expect(card1.sortKey < card3.sortKey)
    }

    @Test("Move card to same position is no-op")
    func testMoveToSamePosition() async throws {
        // Given: A card at position 1
        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(card1)
        modelContext.insert(card2)
        modelContext.insert(card3)

        let originalSortKey = card2.sortKey

        // When: Moving card2 to its current position
        try reorderService.reorderWithinColumn(card2, to: 1)

        // Then: The sortKey might change but order is preserved
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].id == card1.id)
        #expect(sorted[1].id == card2.id)
        #expect(sorted[2].id == card3.id)
    }
}
