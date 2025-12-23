import SwiftData
import XCTest
@testable import HomeCooked

final class CardMigrationTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
        context = container.mainContext
    }

    @MainActor
    override func tearDown() async throws {
        container = nil
        context = nil
        try await super.tearDown()
    }

    @MainActor
    func testSortKeyInitializedAscending() async throws {
        // Given: Create a column with cards with different sortKeys
        let board = Board(title: "Test Board")
        let column = Column(title: "To Do", index: 0)
        let card1 = Card(title: "First", sortKey: 100)
        let card2 = Card(title: "Second", sortKey: 200)
        let card3 = Card(title: "Third", sortKey: 300)

        // Add cards out of order to test sorting (SwiftData maintains inverse relationships)
        column.cards = [card3, card1, card2]
        board.columns = [column]

        context.insert(board)
        try context.save()

        // When: Fetch and sort by sortKey
        let columnID = column.id
        let fetchedColumn = try context.fetch(
            FetchDescriptor<Column>(predicate: #Predicate { $0.id == columnID })
        ).first

        XCTAssertNotNil(fetchedColumn)
        XCTAssertEqual(fetchedColumn?.cards.count, 3)

        // Then: Cards should be sortable by sortKey in ascending order
        let sortedCards = fetchedColumn?.cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(sortedCards?[0].title, "First")
        XCTAssertEqual(sortedCards?[0].sortKey, 100)
        XCTAssertEqual(sortedCards?[1].title, "Second")
        XCTAssertEqual(sortedCards?[1].sortKey, 200)
        XCTAssertEqual(sortedCards?[2].title, "Third")
        XCTAssertEqual(sortedCards?[2].sortKey, 300)
    }

    @MainActor
    func testMigrationHandlesMultipleColumns() async throws {
        // Given: Multiple columns with cards that have different sortKeys
        let board = Board(title: "Test Board")
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "Done", index: 1)

        let card1 = Card(title: "Card 1", sortKey: 50)
        let card2 = Card(title: "Card 2", sortKey: 150)
        let card3 = Card(title: "Card 3", sortKey: 75)

        // Set up relationships (SwiftData maintains inverse relationships)
        column1.cards = [card1, card2]
        column2.cards = [card3]
        board.columns = [column1, column2]

        context.insert(board)
        try context.save()

        // When: Fetch board and examine cards
        let boardID = board.id
        let fetchedBoard = try context.fetch(
            FetchDescriptor<Board>(predicate: #Predicate { $0.id == boardID })
        ).first

        // Then: Each column's cards should maintain their sortKey values independently
        let col1Cards = fetchedBoard?.columns
            .first(where: { $0.title == "To Do" })?
            .cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(col1Cards?.count, 2)
        XCTAssertEqual(col1Cards?[0].sortKey, 50)
        XCTAssertEqual(col1Cards?[1].sortKey, 150)

        let col2Cards = fetchedBoard?.columns
            .first(where: { $0.title == "Done" })?
            .cards.sorted { $0.sortKey < $1.sortKey }
        XCTAssertEqual(col2Cards?.count, 1)
        XCTAssertEqual(col2Cards?[0].sortKey, 75)
    }
}
