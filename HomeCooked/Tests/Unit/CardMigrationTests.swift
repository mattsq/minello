import SwiftData
import XCTest
@testable import HomeCooked

@MainActor
final class CardMigrationTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
        context = container.mainContext
    }

    override func tearDown() async throws {
        container = nil
        context = nil
        try await super.tearDown()
    }

    func testSortKeyInitializedAscending() async throws {
        // Given: Create a column with cards (simulating pre-migration state)
        let board = Board(title: "Test Board")
        let column = Column(title: "To Do", index: 0, board: board)
        let card1 = Card(title: "First", column: column, sortKey: 0)
        let card2 = Card(title: "Second", column: column, sortKey: 0)
        let card3 = Card(title: "Third", column: column, sortKey: 0)

        column.cards = [card1, card2, card3]
        board.columns = [column]

        context.insert(board)
        try context.save()

        // When: Apply migration
        try CardSortKeyMigration.MigrateV0toV1.apply(to: context)

        // Then: SortKeys should be initialized in ascending order
        let columnID = column.id
        let fetchedColumn = try context.fetch(
            FetchDescriptor<Column>(predicate: #Predicate { $0.id == columnID })
        ).first

        XCTAssertNotNil(fetchedColumn)
        XCTAssertEqual(fetchedColumn?.cards.count, 3)

        let sortedCards = fetchedColumn?.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards?[0].sortKey, 0)
        XCTAssertEqual(sortedCards?[1].sortKey, 100)
        XCTAssertEqual(sortedCards?[2].sortKey, 200)
    }

    func testMigrationHandlesMultipleColumns() async throws {
        // Given
        let board = Board(title: "Test Board")
        let column1 = Column(title: "To Do", index: 0, board: board)
        let column2 = Column(title: "Done", index: 1, board: board)

        let card1 = Card(title: "Card 1", column: column1, sortKey: 0)
        let card2 = Card(title: "Card 2", column: column1, sortKey: 0)
        let card3 = Card(title: "Card 3", column: column2, sortKey: 0)

        column1.cards = [card1, card2]
        column2.cards = [card3]
        board.columns = [column1, column2]

        context.insert(board)
        try context.save()

        // When
        try CardSortKeyMigration.MigrateV0toV1.apply(to: context)

        // Then: Each column's cards should have independent sortKey sequences
        let boardID = board.id
        let fetchedBoard = try context.fetch(
            FetchDescriptor<Board>(predicate: #Predicate { $0.id == boardID })
        ).first

        let col1Cards = fetchedBoard?.columns
            .first(where: { $0.title == "To Do" })?
            .cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(col1Cards?.count, 2)
        XCTAssertEqual(col1Cards?[0].sortKey, 0)
        XCTAssertEqual(col1Cards?[1].sortKey, 100)

        let col2Cards = fetchedBoard?.columns
            .first(where: { $0.title == "Done" })?
            .cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(col2Cards?.count, 1)
        XCTAssertEqual(col2Cards?[0].sortKey, 0)
    }
}
