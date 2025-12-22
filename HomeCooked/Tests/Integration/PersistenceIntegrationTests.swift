import SwiftData
import XCTest
@testable import HomeCooked

final class PersistenceIntegrationTests: XCTestCase {
    var container: ModelContainer!
    var boardsRepo: SwiftDataBoardsRepository!
    var listsRepo: SwiftDataListsRepository!
    var recipesRepo: SwiftDataRecipesRepository!

    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        container = try ModelContainerFactory.createInMemory()
        let context = container.mainContext
        boardsRepo = SwiftDataBoardsRepository(modelContext: context)
        listsRepo = SwiftDataListsRepository(modelContext: context)
        recipesRepo = SwiftDataRecipesRepository(modelContext: context)
    }

    @MainActor
    override func tearDown() async throws {
        container = nil
        boardsRepo = nil
        listsRepo = nil
        recipesRepo = nil
        try await super.tearDown()
    }

    @MainActor
    func testRoundTripCreateFetchDelete() async throws {
        // Test Board round trip
        let board = Board(title: "Integration Test Board")
        let column = Column(title: "Testing", index: 0)
        let card = Card(title: "Test Card", sortKey: 100)
        // Set up relationships (SwiftData maintains inverse relationships)
        column.cards = [card]
        board.columns = [column]

        try await boardsRepo.create(board: board)
        let fetchedBoard = try await boardsRepo.fetch(id: board.id)
        logBoardState(fetchedBoard, context: "Round-trip fetched board")
        XCTAssertNotNil(fetchedBoard)
        XCTAssertEqual(fetchedBoard?.title, "Integration Test Board")
        XCTAssertEqual(fetchedBoard?.columns.first?.cards.count, 1)

        try await boardsRepo.delete(board: board)
        let deletedBoard = try await boardsRepo.fetch(id: board.id)
        logBoardState(deletedBoard, context: "After board delete")
        XCTAssertNil(deletedBoard)

        // Test PersonalList round trip
        let list = PersonalList(title: "Groceries")
        let item = ChecklistItem(
            text: "Milk",
            quantity: 2,
            unit: "L"
        )
        // Set up relationship (SwiftData maintains inverse)
        list.items = [item]

        try await listsRepo.create(list: list)
        let fetchedList = try await listsRepo.fetch(id: list.id)
        XCTAssertNotNil(fetchedList)
        XCTAssertEqual(fetchedList?.title, "Groceries")
        XCTAssertEqual(fetchedList?.items.count, 1)
        XCTAssertEqual(fetchedList?.items.first?.quantity, 2)

        try await listsRepo.delete(list: list)
        let deletedList = try await listsRepo.fetch(id: list.id)
        XCTAssertNil(deletedList)

        // Test Recipe round trip
        let recipe = Recipe(
            title: "Pasta",
            ingredients: "Pasta, Tomato Sauce",
            methodMarkdown: "1. Boil pasta\n2. Add sauce",
            tags: ["Italian", "Quick"]
        )

        try await recipesRepo.create(recipe: recipe)
        let fetchedRecipe = try await recipesRepo.fetch(id: recipe.id)
        XCTAssertNotNil(fetchedRecipe)
        XCTAssertEqual(fetchedRecipe?.title, "Pasta")
        XCTAssertEqual(fetchedRecipe?.tags.count, 2)

        try await recipesRepo.delete(recipe: recipe)
        let deletedRecipe = try await recipesRepo.fetch(id: recipe.id)
        XCTAssertNil(deletedRecipe)
    }

    @MainActor
    func testCascadingDelete() async throws {
        // Given: Board with columns and cards
        let board = Board(title: "Test Board")
        let column = Column(title: "Column", index: 0)
        let card = Card(title: "Card", sortKey: 100)
        // Set up relationships (SwiftData maintains inverse relationships)
        column.cards = [card]
        board.columns = [column]

        try await boardsRepo.create(board: board)

        // When: Delete board
        try await boardsRepo.delete(board: board)

        // Then: Columns and cards should be deleted (cascade)
        let context = container.mainContext
        let columnID = column.id
        let cardID = card.id
        let columnDescriptor = FetchDescriptor<Column>(
            predicate: #Predicate { $0.id == columnID }
        )
        let cardDescriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.id == cardID }
        )

        let fetchedColumns = try context.fetch(columnDescriptor)
        let fetchedCards = try context.fetch(cardDescriptor)

        XCTContext.runActivity(named: "Cascade delete check") { _ in
            print("Columns fetched: \(fetchedColumns.count), Cards fetched: \(fetchedCards.count)")
        }
        XCTAssertTrue(fetchedColumns.isEmpty)
        XCTAssertTrue(fetchedCards.isEmpty)

    }

    private func logBoardState(_ board: Board?, context: String) {
        XCTContext.runActivity(named: "Integration board state: \(context)") { _ in
            guard let board else {
                print("Board is nil")
                return
            }

            print("Board[\(board.id)] title=\(board.title) columns=\(board.columns.count)")
            for column in board.columns {
                print("  Column[\(column.id)] title=\(column.title) index=\(column.index) cards=\(column.cards.count)")
                for card in column.cards {
                    print("    Card[\(card.id)] title=\(card.title) sortKey=\(card.sortKey)")
                }
            }
        }
    }
}
