import SwiftData
import XCTest
@testable import HomeCooked

final class BoardsRepositoryTests: XCTestCase {
    var container: ModelContainer!
    var repository: SwiftDataBoardsRepository!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
        repository = SwiftDataBoardsRepository(
            modelContext: container.mainContext
        )
    }

    @MainActor
    override func tearDown() async throws {
        container = nil
        repository = nil
        try await super.tearDown()
    }

    @MainActor
    func testCreateBoardWithColumnsAndCards() async throws {
        // Given
        let board = Board(title: "Test Board")
        let column1 = Column(title: "To Do", index: 0)
        let column2 = Column(title: "Done", index: 1)
        let card1 = Card(
            title: "Buy milk",
            sortKey: 100
        )
        let card2 = Card(
            title: "Call plumber",
            sortKey: 200
        )

        // Set up relationships (only set one side, SwiftData maintains inverse)
        board.columns = [column1, column2]
        column1.cards = [card1, card2]

        // When
        try await repository.create(board: board)

        // Then
        let fetchedBoard = try await repository.fetch(id: board.id)
        XCTAssertNotNil(fetchedBoard)
        XCTAssertEqual(fetchedBoard?.title, "Test Board")
        XCTAssertEqual(fetchedBoard?.columns.count, 2)
        XCTAssertEqual(fetchedBoard?.columns.first?.cards.count, 2)
        XCTAssertEqual(fetchedBoard?.columns.first?.cards.first?.title, "Buy milk")
        XCTAssertEqual(fetchedBoard?.columns.first?.cards.first?.sortKey, 100)
    }

    @MainActor
    func testFetchAllReturnsAllBoards() async throws {
        // Given
        let board1 = Board(title: "Board 1")
        let board2 = Board(title: "Board 2")
        try await repository.create(board: board1)
        try await repository.create(board: board2)

        // When
        let boards = try await repository.fetchAll()

        // Then
        XCTAssertEqual(boards.count, 2)
    }

    @MainActor
    func testUpdateBoard() async throws {
        // Given
        let board = Board(title: "Original Title")
        try await repository.create(board: board)

        // When
        board.title = "Updated Title"
        try await repository.update(board: board)

        // Then
        let fetchedBoard = try await repository.fetch(id: board.id)
        XCTAssertEqual(fetchedBoard?.title, "Updated Title")
    }

    @MainActor
    func testDeleteBoard() async throws {
        // Given
        let board = Board(title: "Test Board")
        try await repository.create(board: board)

        // When
        try await repository.delete(board: board)

        // Then
        let fetchedBoard = try await repository.fetch(id: board.id)
        XCTAssertNil(fetchedBoard)
    }
}
