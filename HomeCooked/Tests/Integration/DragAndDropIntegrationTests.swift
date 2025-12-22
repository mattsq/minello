import SwiftData
import Testing
@testable import HomeCooked

/// Integration tests for drag-and-drop functionality with persistence
@MainActor
struct DragAndDropIntegrationTests {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var reorderService: CardReorderService!

    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
            for: Board.self, Column.self, Card.self, ChecklistItem.self,
            configurations: config
        )
        modelContext = ModelContext(modelContainer)
        reorderService = CardReorderService(modelContext: modelContext)
    }

    @Test("Drop updates repository and persists changes")
    func dropUpdatesRepository() async throws {
        // Given: A board with columns and cards
        let board = Board(title: "Test Board")
        let sourceColumn = Column(title: "Source", index: 0)
        let destColumn = Column(title: "Destination", index: 1)

        let card = Card(title: "Test Card", sortKey: 1000)
        card.column = sourceColumn
        sourceColumn.cards = [card]

        sourceColumn.board = board
        destColumn.board = board
        board.columns = [sourceColumn, destColumn]

        modelContext.insert(board)
        modelContext.insert(sourceColumn)
        modelContext.insert(destColumn)
        modelContext.insert(card)

        try modelContext.save()

        // When: Moving the card to destination column
        try reorderService.moveCard(card, to: destColumn, at: 0)
        try modelContext.save()

        // Then: Card should be persisted in the new column
        #expect(card.column?.id == destColumn.id)
        #expect(destColumn.cards.contains { $0.id == card.id })
        #expect(!sourceColumn.cards.contains { $0.id == card.id })

        // And: Changes should be saved in context
        let fetchDescriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.id == card.id }
        )
        let fetchedCards = try modelContext.fetch(fetchDescriptor)

        #expect(fetchedCards.count == 1)
        #expect(fetchedCards.first?.column?.id == destColumn.id)
    }

    @Test("Multiple drag operations maintain consistency")
    func multipleDragOperationsMaintainConsistency() async throws {
        // Given: A board with multiple columns and cards
        let board = Board(title: "Multi-Op Board")
        let column1 = Column(title: "Column 1", index: 0)
        let column2 = Column(title: "Column 2", index: 1)
        let column3 = Column(title: "Column 3", index: 2)

        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column1
        card2.column = column1
        card3.column = column1
        column1.cards = [card1, card2, card3]

        column1.board = board
        column2.board = board
        column3.board = board
        board.columns = [column1, column2, column3]

        modelContext.insert(board)

        // When: Performing multiple drag operations
        // 1. Move card2 to column2
        try reorderService.moveCard(card2, to: column2, at: 0)
        try modelContext.save()

        // 2. Move card1 to column3
        try reorderService.moveCard(card1, to: column3, at: 0)
        try modelContext.save()

        // 3. Move card3 to column2 at the end
        try reorderService.moveCard(card3, to: column2, at: 1)
        try modelContext.save()

        // Then: All cards should be in correct columns
        #expect(column1.cards.isEmpty)
        #expect(column2.cards.count == 2)
        #expect(column3.cards.count == 1)

        #expect(card1.column?.id == column3.id)
        #expect(card2.column?.id == column2.id)
        #expect(card3.column?.id == column2.id)

        // And: Cards in column2 should be in correct order
        let sorted = column2.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].id == card2.id)
        #expect(sorted[1].id == card3.id)
    }

    @Test("Reordering within column persists correctly")
    func reorderWithinColumnPersists() async throws {
        // Given: A column with multiple cards
        let column = Column(title: "Test Column", index: 0)

        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)
        let card3 = Card(title: "Card 3", sortKey: 3000)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(column)

        let originalOrder = column.cards.sorted { $0.sortKey < $1.sortKey }.map(\.id)
        #expect(originalOrder == [card1.id, card2.id, card3.id])

        // When: Moving card3 to the beginning
        try reorderService.reorderWithinColumn(card3, to: 0)
        try modelContext.save()

        // Then: Order should be updated
        let newOrder = column.cards.sorted { $0.sortKey < $1.sortKey }.map(\.id)
        #expect(newOrder == [card3.id, card1.id, card2.id])

        // And: Changes should be persisted
        let fetchDescriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.column?.id == column.id }
        )
        let fetchedCards = try modelContext.fetch(fetchDescriptor)

        let persistedOrder = fetchedCards.sorted { $0.sortKey < $1.sortKey }.map(\.id)
        #expect(persistedOrder == [card3.id, card1.id, card2.id])
    }

    @Test("Normalization preserves order after save")
    func normalizationPreservesOrderAfterSave() async throws {
        // Given: A column with cards that need normalization
        let column = Column(title: "Normalize Test", index: 0)

        let card1 = Card(title: "Card 1", sortKey: 100.5)
        let card2 = Card(title: "Card 2", sortKey: 100.501)
        let card3 = Card(title: "Card 3", sortKey: 100.502)

        card1.column = column
        card2.column = column
        card3.column = column
        column.cards = [card1, card2, card3]

        modelContext.insert(column)

        let originalOrder = column.cards.sorted { $0.sortKey < $1.sortKey }.map(\.id)

        // When: Normalizing the column
        try await reorderService.normalizeColumn(column)

        // Then: Order should be preserved
        let newOrder = column.cards.sorted { $0.sortKey < $1.sortKey }.map(\.id)
        #expect(originalOrder == newOrder)

        // And: SortKeys should be normalized
        let sorted = column.cards.sorted { $0.sortKey < $1.sortKey }
        #expect(sorted[0].sortKey == 1000.0)
        #expect(sorted[1].sortKey == 2000.0)
        #expect(sorted[2].sortKey == 3000.0)

        // And: Normalized values should be persisted
        let fetchDescriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.column?.id == column.id }
        )
        let fetchedCards = try modelContext.fetch(fetchDescriptor)

        let persistedSorted = fetchedCards.sorted { $0.sortKey < $1.sortKey }
        #expect(persistedSorted[0].sortKey == 1000.0)
        #expect(persistedSorted[1].sortKey == 2000.0)
        #expect(persistedSorted[2].sortKey == 3000.0)
    }

    @Test("Moving card updates updatedAt timestamp")
    func moveUpdatesTimestamp() async throws {
        // Given: A card with a known timestamp
        let column1 = Column(title: "Column 1", index: 0)
        let column2 = Column(title: "Column 2", index: 1)

        let card = Card(title: "Test Card", sortKey: 1000)
        card.column = column1
        column1.cards = [card]

        modelContext.insert(column1)
        modelContext.insert(column2)
        modelContext.insert(card)

        let originalTimestamp = card.updatedAt

        // Wait a brief moment to ensure timestamp changes
        try await Task.sleep(for: .milliseconds(10))

        // When: Moving the card
        try reorderService.moveCard(card, to: column2, at: 0)

        // Then: updatedAt should be changed
        #expect(card.updatedAt > originalTimestamp)
    }

    @Test("Cards in different columns maintain independent sortKeys")
    func independentSortKeysAcrossColumns() async throws {
        // Given: Multiple columns with cards
        let column1 = Column(title: "Column 1", index: 0)
        let column2 = Column(title: "Column 2", index: 1)

        let card1a = Card(title: "Card 1A", sortKey: 1000)
        let card1b = Card(title: "Card 1B", sortKey: 2000)

        let card2a = Card(title: "Card 2A", sortKey: 1000)
        let card2b = Card(title: "Card 2B", sortKey: 2000)

        card1a.column = column1
        card1b.column = column1
        column1.cards = [card1a, card1b]

        card2a.column = column2
        card2b.column = column2
        column2.cards = [card2a, card2b]

        modelContext.insert(column1)
        modelContext.insert(column2)

        // When: Reordering cards in column1
        try reorderService.reorderWithinColumn(card1b, to: 0)

        // Then: Only column1 cards should be affected
        #expect(card1b.sortKey < card1a.sortKey)

        // And: column2 cards should remain unchanged
        #expect(card2a.sortKey == 1000.0)
        #expect(card2b.sortKey == 2000.0)
    }

    @Test("Empty column accepts first card correctly")
    func emptyColumnAcceptsFirstCard() async throws {
        // Given: An empty column and a card in another column
        let sourceColumn = Column(title: "Source", index: 0)
        let emptyColumn = Column(title: "Empty", index: 1)

        let card = Card(title: "Test Card", sortKey: 1000)
        card.column = sourceColumn
        sourceColumn.cards = [card]

        modelContext.insert(sourceColumn)
        modelContext.insert(emptyColumn)
        modelContext.insert(card)

        #expect(emptyColumn.cards.isEmpty)

        // When: Moving card to empty column
        try reorderService.moveCard(card, to: emptyColumn, at: 0)
        try modelContext.save()

        // Then: Card should be in the empty column
        #expect(emptyColumn.cards.count == 1)
        #expect(emptyColumn.cards.first?.id == card.id)
        #expect(card.column?.id == emptyColumn.id)

        // And: Card should have default sortKey
        #expect(card.sortKey == 1000.0)
    }
}
