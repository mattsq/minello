// Tests/PersistenceGRDBTests/SearchRepositoryContractTests.swift
// Contract tests for SearchRepository that can run against any implementation

import Domain
import Foundation
import GRDB
import PersistenceGRDB
import PersistenceInterfaces
import XCTest

/// Contract tests for SearchRepository
/// These tests can be run against any implementation of SearchRepository
final class SearchRepositoryContractTests: XCTestCase {
    var searchRepository: SearchRepository!
    var boardsRepository: BoardsRepository!
    var listsRepository: ListsRepository!
    var recipesRepository: RecipesRepository!

    override func setUp() async throws {
        try await super.setUp()

        // Create in-memory database with all repositories
        let dbQueue = try DatabaseQueue()
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)

        boardsRepository = GRDBBoardsRepository(dbQueue: dbQueue)
        listsRepository = GRDBListsRepository(dbQueue: dbQueue)
        recipesRepository = GRDBRecipesRepository(dbQueue: dbQueue)
        searchRepository = GRDBSearchRepository(
            dbQueue: dbQueue,
            boardsRepo: boardsRepository,
            listsRepo: listsRepository,
            recipesRepo: recipesRepository
        )
    }

    override func tearDown() async throws {
        searchRepository = nil
        boardsRepository = nil
        listsRepository = nil
        recipesRepository = nil
        try await super.tearDown()
    }

    // MARK: - Unified Search Tests

    func testUnifiedSearchAcrossAllEntities() async throws {
        // Create test data
        let board = Board(title: "Shopping Board")
        try await boardsRepository.createBoard(board)

        let column = Column(id: ColumnID(), board: board.id, title: "To Buy", index: 0, cards: [])
        try await boardsRepository.createColumn(column)

        let card = Card(
            column: column.id,
            title: "Buy groceries",
            details: "Get milk and bread from the store",
            tags: [],
            checklist: [],
            sortKey: 0
        )
        try await boardsRepository.createCard(card)

        let list = PersonalList(title: "Grocery List", items: [])
        try await listsRepository.createList(list)

        let recipe = Recipe(
            title: "Grocery Store Cake",
            ingredients: [],
            methodMarkdown: "Buy ingredients from grocery store",
            tags: []
        )
        try await recipesRepository.createRecipe(recipe)

        // Search for "grocery"
        let results = try await searchRepository.search(query: "grocery", filters: nil)

        // Should find card, list, and recipe (not board since title is "Shopping Board")
        XCTAssertEqual(results.count, 3, "Should find card, list, and recipe")

        let entityTypes = Set(results.map { $0.entityType })
        XCTAssertTrue(entityTypes.contains(.card))
        XCTAssertTrue(entityTypes.contains(.list))
        XCTAssertTrue(entityTypes.contains(.recipe))
    }

    func testUnifiedSearchWithFilters() async throws {
        // Create test data
        let board = Board(title: "Shopping Board")
        try await boardsRepository.createBoard(board)

        let list = PersonalList(title: "Shopping List", items: [])
        try await listsRepository.createList(list)

        // Search only for lists
        let results = try await searchRepository.search(query: "shopping", filters: [.list])

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.entityType, .list)
        if case .list(let foundList) = results.first {
            XCTAssertEqual(foundList.id, list.id)
        } else {
            XCTFail("Expected list result")
        }
    }

    // MARK: - Entity-Specific Search Tests

    func testSearchBoards() async throws {
        let board1 = Board(title: "Project Management")
        let board2 = Board(title: "Home Tasks")
        let board3 = Board(title: "Project Alpha")

        try await boardsRepository.createBoard(board1)
        try await boardsRepository.createBoard(board2)
        try await boardsRepository.createBoard(board3)

        let results = try await searchRepository.searchBoards(query: "project")
        XCTAssertEqual(results.count, 2)

        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Project Management"))
        XCTAssertTrue(titles.contains("Project Alpha"))
    }

    func testSearchCards() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(id: ColumnID(), board: board.id, title: "ToDo", index: 0, cards: [])
        try await boardsRepository.createColumn(column)

        let card1 = Card(
            column: column.id,
            title: "Write documentation",
            details: "Document the search feature",
            tags: [],
            checklist: [],
            sortKey: 0
        )
        let card2 = Card(
            column: column.id,
            title: "Fix bug",
            details: "Documentation link is broken",
            tags: [],
            checklist: [],
            sortKey: 1
        )
        let card3 = Card(
            column: column.id,
            title: "Review code",
            details: "Check pull request",
            tags: [],
            checklist: [],
            sortKey: 2
        )

        try await boardsRepository.createCard(card1)
        try await boardsRepository.createCard(card2)
        try await boardsRepository.createCard(card3)

        let results = try await searchRepository.searchCards(query: "documentation")
        XCTAssertEqual(results.count, 2)

        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Write documentation"))
        XCTAssertTrue(titles.contains("Fix bug"))
    }

    func testSearchLists() async throws {
        let list1 = PersonalList(title: "Grocery Shopping", items: [])
        let list2 = PersonalList(title: "Packing List", items: [])
        let list3 = PersonalList(title: "Shopping for Vacation", items: [])

        try await listsRepository.createList(list1)
        try await listsRepository.createList(list2)
        try await listsRepository.createList(list3)

        let results = try await searchRepository.searchLists(query: "shopping")
        XCTAssertEqual(results.count, 2)

        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Grocery Shopping"))
        XCTAssertTrue(titles.contains("Shopping for Vacation"))
    }

    func testSearchRecipes() async throws {
        let recipe1 = Recipe(
            title: "Chocolate Cake",
            ingredients: [],
            methodMarkdown: "Mix chocolate and flour",
            tags: []
        )
        let recipe2 = Recipe(
            title: "Vanilla Cake",
            ingredients: [],
            methodMarkdown: "Mix vanilla and flour",
            tags: []
        )
        let recipe3 = Recipe(
            title: "Brownies",
            ingredients: [],
            methodMarkdown: "Chocolate dessert",
            tags: []
        )

        try await recipesRepository.createRecipe(recipe1)
        try await recipesRepository.createRecipe(recipe2)
        try await recipesRepository.createRecipe(recipe3)

        let results = try await searchRepository.searchRecipes(query: "chocolate")
        XCTAssertEqual(results.count, 2)

        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Chocolate Cake"))
        XCTAssertTrue(titles.contains("Brownies"))
    }

    // MARK: - Tag Search Tests

    func testSearchByTag() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(id: ColumnID(), board: board.id, title: "ToDo", index: 0, cards: [])
        try await boardsRepository.createColumn(column)

        let card = Card(
            column: column.id,
            title: "Tagged Card",
            details: "Test",
            tags: ["urgent", "work"],
            checklist: [],
            sortKey: 0
        )
        try await boardsRepository.createCard(card)

        let recipe = Recipe(
            title: "Tagged Recipe",
            ingredients: [],
            methodMarkdown: "Test",
            tags: ["urgent", "dinner"]
        )
        try await recipesRepository.createRecipe(recipe)

        let results = try await searchRepository.searchByTag("urgent")
        XCTAssertEqual(results.count, 2)

        let types = Set(results.map { $0.entityType })
        XCTAssertTrue(types.contains(.card))
        XCTAssertTrue(types.contains(.recipe))
    }

    // MARK: - Date Range Search Tests

    func testFindCardsDue() async throws {
        let board = Board(title: "Test Board")
        try await boardsRepository.createBoard(board)

        let column = Column(id: ColumnID(), board: board.id, title: "ToDo", index: 0, cards: [])
        try await boardsRepository.createColumn(column)

        let now = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let nextWeek = Calendar.current.date(byAdding: .day, value: 7, to: now)!
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: now)!

        let card1 = Card(
            column: column.id,
            title: "Due Tomorrow",
            details: "",
            due: tomorrow,
            tags: [],
            checklist: [],
            sortKey: 0
        )
        let card2 = Card(
            column: column.id,
            title: "Due Next Week",
            details: "",
            due: nextWeek,
            tags: [],
            checklist: [],
            sortKey: 1
        )
        let card3 = Card(
            column: column.id,
            title: "Due Next Month",
            details: "",
            due: nextMonth,
            tags: [],
            checklist: [],
            sortKey: 2
        )

        try await boardsRepository.createCard(card1)
        try await boardsRepository.createCard(card2)
        try await boardsRepository.createCard(card3)

        // Search for cards due in the next 10 days
        let results = try await searchRepository.findCardsDue(from: now, to: nextWeek)
        XCTAssertEqual(results.count, 2)

        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Due Tomorrow"))
        XCTAssertTrue(titles.contains("Due Next Week"))
    }

    // MARK: - Recent Searches Tests

    func testSaveAndLoadRecentSearches() async throws {
        try await searchRepository.saveRecentSearch("groceries")
        try await searchRepository.saveRecentSearch("recipes")
        try await searchRepository.saveRecentSearch("tasks")

        let recent = try await searchRepository.loadRecentSearches(limit: 10)
        XCTAssertEqual(recent.count, 3)

        // Most recent should be first
        XCTAssertEqual(recent[0], "tasks")
        XCTAssertEqual(recent[1], "recipes")
        XCTAssertEqual(recent[2], "groceries")
    }

    func testRecentSearchesLimit() async throws {
        // Save more than the limit
        for i in 1...15 {
            try await searchRepository.saveRecentSearch("query\(i)")
        }

        let recent = try await searchRepository.loadRecentSearches(limit: 5)
        XCTAssertEqual(recent.count, 5)

        // Should get the 5 most recent
        XCTAssertEqual(recent[0], "query15")
        XCTAssertEqual(recent[4], "query11")
    }

    func testRecentSearchesDeduplicate() async throws {
        try await searchRepository.saveRecentSearch("groceries")
        try await searchRepository.saveRecentSearch("tasks")
        try await searchRepository.saveRecentSearch("groceries") // Duplicate

        let recent = try await searchRepository.loadRecentSearches(limit: 10)
        XCTAssertEqual(recent.count, 2)

        // "groceries" should be first since it was searched again
        XCTAssertEqual(recent[0], "groceries")
        XCTAssertEqual(recent[1], "tasks")
    }

    func testClearRecentSearches() async throws {
        try await searchRepository.saveRecentSearch("groceries")
        try await searchRepository.saveRecentSearch("tasks")

        try await searchRepository.clearRecentSearches()

        let recent = try await searchRepository.loadRecentSearches(limit: 10)
        XCTAssertEqual(recent.count, 0)
    }

    func testSearchEmptyQuery() async throws {
        // Searching with empty query should return empty results
        let results = try await searchRepository.search(query: "", filters: nil)
        XCTAssertEqual(results.count, 0)

        // Empty query should not be saved to recent searches
        let recent = try await searchRepository.loadRecentSearches(limit: 10)
        XCTAssertEqual(recent.count, 0)
    }

    func testSearchWhitespaceOnlyQuery() async throws {
        // Searching with whitespace-only query should behave like empty query
        let spacesResults = try await searchRepository.search(query: "   ", filters: nil)
        XCTAssertEqual(spacesResults.count, 0)

        let tabsResults = try await searchRepository.search(query: "\t\n", filters: nil)
        XCTAssertEqual(tabsResults.count, 0)

        // Whitespace-only queries should not be saved to recent searches
        let recent = try await searchRepository.loadRecentSearches(limit: 10)
        XCTAssertEqual(recent.count, 0)
    }
}
