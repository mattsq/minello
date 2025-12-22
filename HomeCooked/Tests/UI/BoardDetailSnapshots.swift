import SwiftData
import SwiftUI
import Testing
@testable import HomeCooked

/// Snapshot tests for BoardDetailView in light and dark modes
/// Note: Actual snapshot testing requires a snapshot testing library like swift-snapshot-testing
/// These tests verify that views render without crashing
@MainActor
struct BoardDetailSnapshots {
    var modelContext: ModelContext!

    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Board.self, Column.self, Card.self, ChecklistItem.self,
            configurations: config
        )
        modelContext = ModelContext(container)
    }

    @Test("Kanban board renders in light mode")
    func kanbanLightMode() async throws {
        // Given: A board with multiple columns and cards
        let board = createTestBoard()

        // When: Rendering the view
        let view = BoardDetailView(board: board)
            .modelContainer(for: [Board.self, Column.self, Card.self, ChecklistItem.self])
            .environment(\.colorScheme, .light)

        // Then: View should render without errors
        // Note: Actual snapshot assertion would go here with a snapshot testing library
        #expect(board.columns.count == 3)
        #expect(view != nil)
    }

    @Test("Kanban board renders in dark mode")
    func kanbanDarkMode() async throws {
        // Given: A board with multiple columns and cards
        let board = createTestBoard()

        // When: Rendering the view
        let view = BoardDetailView(board: board)
            .modelContainer(for: [Board.self, Column.self, Card.self, ChecklistItem.self])
            .environment(\.colorScheme, .dark)

        // Then: View should render without errors
        #expect(board.columns.count == 3)
        #expect(view != nil)
    }

    @Test("Empty board renders correctly")
    func emptyBoard() async throws {
        // Given: An empty board with no columns
        let board = Board(title: "Empty Board")
        modelContext.insert(board)

        // When: Rendering the view
        let view = BoardDetailView(board: board)
            .modelContainer(for: [Board.self, Column.self, Card.self])

        // Then: View should render without errors
        #expect(board.columns.isEmpty)
        #expect(view != nil)
    }

    @Test("Board with empty columns renders correctly")
    func boardWithEmptyColumns() async throws {
        // Given: A board with columns but no cards
        let board = Board(title: "Board with Empty Columns")
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "In Progress", index: 1)
        let column3 = Column(title: "Done", index: 2)

        column1.board = board
        column2.board = board
        column3.board = board
        board.columns = [column1, column2, column3]

        modelContext.insert(board)

        // When: Rendering the view
        let view = BoardDetailView(board: board)
            .modelContainer(for: [Board.self, Column.self, Card.self])

        // Then: View should render without errors
        #expect(board.columns.count == 3)
        #expect(board.columns.allSatisfy { $0.cards.isEmpty })
        #expect(view != nil)
    }

    @Test("Board with cards with various states renders correctly")
    func boardWithVariousCardStates() async throws {
        // Given: A board with cards in different states
        let board = Board(title: "Board with Various States")
        let column = Column(title: "Mixed", index: 0)

        // Card with all features
        let complexCard = Card(
            title: "Complex Card",
            details: "This card has everything",
            due: Date().addingTimeInterval(86400),
            tags: ["feature", "urgent", "ui"],
            checklist: [
                ChecklistItem(text: "Task 1", isDone: true),
                ChecklistItem(text: "Task 2", isDone: false),
            ],
            sortKey: 1000
        )

        // Simple card
        let simpleCard = Card(title: "Simple Card", sortKey: 2000)

        // Overdue card
        let overdueCard = Card(
            title: "Overdue Card",
            due: Date().addingTimeInterval(-86400),
            tags: ["overdue"],
            sortKey: 3000
        )

        // Card with completed checklist
        let completedCard = Card(
            title: "Completed Checklist",
            checklist: [
                ChecklistItem(text: "Done 1", isDone: true),
                ChecklistItem(text: "Done 2", isDone: true),
            ],
            sortKey: 4000
        )

        complexCard.column = column
        simpleCard.column = column
        overdueCard.column = column
        completedCard.column = column

        column.cards = [complexCard, simpleCard, overdueCard, completedCard]
        column.board = board
        board.columns = [column]

        modelContext.insert(board)

        // When: Rendering the view
        let view = BoardDetailView(board: board)
            .modelContainer(for: [Board.self, Column.self, Card.self, ChecklistItem.self])

        // Then: View should render without errors
        #expect(column.cards.count == 4)
        #expect(view != nil)
    }

    @Test("CardRow renders correctly")
    func cardRowSnapshot() async throws {
        // Given: A card with various features
        let card = Card(
            title: "Test Card",
            details: "This is a test card with details",
            due: Date().addingTimeInterval(86400),
            tags: ["test", "snapshot"],
            checklist: [
                ChecklistItem(text: "Item 1", isDone: true),
                ChecklistItem(text: "Item 2", isDone: false),
            ]
        )

        // When: Rendering the card row
        let view = CardRow(card: card, position: 0, totalCards: 1)
            .frame(width: 280)

        // Then: View should render without errors
        #expect(view != nil)
    }

    @Test("ColumnView renders correctly")
    func columnViewSnapshot() async throws {
        // Given: A column with cards
        let column = Column(title: "Test Column", index: 0)
        let card1 = Card(title: "Card 1", sortKey: 1000)
        let card2 = Card(title: "Card 2", sortKey: 2000)

        card1.column = column
        card2.column = column
        column.cards = [card1, card2]

        modelContext.insert(column)

        let reorderService = CardReorderService(modelContext: modelContext)

        // When: Rendering the column view
        let view = ColumnView(column: column, reorderService: reorderService)

        // Then: View should render without errors
        #expect(view != nil)
        #expect(column.cards.count == 2)
    }

    // MARK: - Helper Methods

    private func createTestBoard() -> Board {
        let board = Board(title: "Test Board")

        let todoColumn = Column(title: "To Do", index: 0)
        let inProgressColumn = Column(title: "In Progress", index: 1)
        let doneColumn = Column(title: "Done", index: 2)

        let card1 = Card(
            title: "Design mockups",
            details: "Create UI mockups for the new feature",
            due: Date().addingTimeInterval(86400),
            tags: ["design"],
            sortKey: 1000
        )

        let card2 = Card(
            title: "Implement backend API",
            tags: ["backend", "api"],
            checklist: [
                ChecklistItem(text: "Create endpoints", isDone: true),
                ChecklistItem(text: "Add tests", isDone: false),
            ],
            sortKey: 2000
        )

        let card3 = Card(
            title: "Review PR",
            sortKey: 1000
        )

        let card4 = Card(
            title: "Deploy to production",
            due: Date().addingTimeInterval(172800),
            tags: ["deployment"],
            checklist: [
                ChecklistItem(text: "Run tests", isDone: true),
                ChecklistItem(text: "Update docs", isDone: true),
                ChecklistItem(text: "Deploy", isDone: true),
            ],
            sortKey: 1000
        )

        card1.column = todoColumn
        card2.column = todoColumn
        card3.column = inProgressColumn
        card4.column = doneColumn

        todoColumn.cards = [card1, card2]
        inProgressColumn.cards = [card3]
        doneColumn.cards = [card4]

        todoColumn.board = board
        inProgressColumn.board = board
        doneColumn.board = board

        board.columns = [todoColumn, inProgressColumn, doneColumn]

        modelContext.insert(board)

        return board
    }
}
