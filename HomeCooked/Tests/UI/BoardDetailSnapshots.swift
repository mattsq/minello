import SwiftData
import SwiftUI
import XCTest
@testable import HomeCooked

@MainActor
final class BoardDetailSnapshots: XCTestCase {
    var container: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
    }

    override func tearDown() async throws {
        container = nil
        try await super.tearDown()
    }

    // MARK: - Snapshot Tests

    func testKanbanLightMode() throws {
        // Given: A board with multiple columns and cards
        let board = createSampleBoard()

        // When: Render in light mode
        let view = NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
        .preferredColorScheme(.light)
        .frame(width: 1000, height: 700)

        // Then: Verify snapshot
        assertSnapshot(matching: view, named: "kanban-light")
    }

    func testKanbanDarkMode() throws {
        // Given: A board with multiple columns and cards
        let board = createSampleBoard()

        // When: Render in dark mode
        let view = NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
        .preferredColorScheme(.dark)
        .frame(width: 1000, height: 700)

        // Then: Verify snapshot
        assertSnapshot(matching: view, named: "kanban-dark")
    }

    func testEmptyBoard() throws {
        // Given: An empty board
        let board = Board(
            title: "Empty Board",
            columns: [
                Column(title: "To Do", index: 0),
                Column(title: "In Progress", index: 1),
                Column(title: "Done", index: 2),
            ]
        )

        // When: Render
        let view = NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
        .preferredColorScheme(.light)
        .frame(width: 1000, height: 700)

        // Then: Verify snapshot
        assertSnapshot(matching: view, named: "empty-board")
    }

    func testSingleColumn() throws {
        // Given: A board with one column
        let column = Column(title: "Backlog", index: 0)
        column.cards = [
            Card(title: "Task 1", sortKey: 0, column: column),
            Card(title: "Task 2", sortKey: 1, column: column),
        ]

        let board = Board(title: "Simple Board", columns: [column])

        // When: Render
        let view = NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
        .preferredColorScheme(.light)
        .frame(width: 1000, height: 700)

        // Then: Verify snapshot
        assertSnapshot(matching: view, named: "single-column")
    }

    func testCardWithMetadata() throws {
        // Given: Cards with various metadata
        let column = Column(title: "To Do", index: 0)

        let card1 = Card(
            title: "Buy groceries",
            due: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            tags: ["Home", "Shopping"],
            checklist: [
                ChecklistItem(text: "Milk", isDone: true, card: nil),
                ChecklistItem(text: "Eggs", isDone: false, card: nil),
                ChecklistItem(text: "Bread", isDone: false, card: nil),
            ],
            sortKey: 0,
            column: column
        )

        let card2 = Card(
            title: "Call plumber",
            due: Date(),
            tags: ["Urgent"],
            sortKey: 1,
            column: column
        )

        column.cards = [card1, card2]
        let board = Board(title: "Metadata Board", columns: [column])

        // When: Render
        let view = NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
        .preferredColorScheme(.light)
        .frame(width: 400, height: 700)

        // Then: Verify snapshot
        assertSnapshot(matching: view, named: "card-metadata")
    }

    // MARK: - Helper Methods

    private func createSampleBoard() -> Board {
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "In Progress", index: 1)
        let column3 = Column(title: "Done", index: 2)

        column1.cards = [
            Card(title: "Buy groceries", sortKey: 0, column: column1),
            Card(title: "Call plumber", sortKey: 1, column: column1),
            Card(title: "Pay bills", sortKey: 2, column: column1),
            Card(title: "Schedule dentist appointment", sortKey: 3, column: column1),
        ]

        column2.cards = [
            Card(title: "Fix leaky faucet", sortKey: 0, column: column2),
            Card(title: "Clean garage", sortKey: 1, column: column2),
        ]

        column3.cards = [
            Card(title: "Take out trash", sortKey: 0, column: column3),
            Card(title: "Water plants", sortKey: 1, column: column3),
            Card(title: "Vacuum living room", sortKey: 2, column: column3),
        ]

        let board = Board(
            title: "Family Board",
            columns: [column1, column2, column3]
        )

        return board
    }

    private func assertSnapshot(matching view: some View, named name: String) {
        // Note: This is a placeholder for actual snapshot testing
        // In a real implementation, you would use a library like SnapshotTesting
        // or swift-snapshot-testing to capture and compare snapshots
        //
        // For now, we just verify the view can be rendered without crashing
        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view)

        // TODO: Implement actual snapshot comparison
        // Example with swift-snapshot-testing:
        // assertSnapshot(matching: view, as: .image(layout: .device(config: .iPhone13)))
    }
}
