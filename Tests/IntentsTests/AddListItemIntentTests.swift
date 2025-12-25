// Tests/IntentsTests/AddListItemIntentTests.swift
// Integration tests for AddListItemIntent

#if canImport(AppIntents)
import XCTest
import Domain
import PersistenceInterfaces
import PersistenceGRDB
@testable import UseCases

@available(iOS 16.0, macOS 13.0, *)
final class AddListItemIntentTests: XCTestCase {
    var listsRepo: GRDBListsRepository!
    var dbURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create temporary in-memory database
        let tempDir = FileManager.default.temporaryDirectory
        dbURL = tempDir.appendingPathComponent("test-\(UUID().uuidString).db")

        let provider = try GRDBRepositoryProvider(databaseURL: dbURL)
        listsRepo = provider.listsRepository as? GRDBListsRepository
    }

    override func tearDown() async throws {
        listsRepo = nil
        if let dbURL = dbURL {
            try? FileManager.default.removeItem(at: dbURL)
        }
        try await super.tearDown()
    }

    // MARK: - Fuzzy Lookup Tests

    func testFindListExactMatch() async throws {
        // Create test lists
        let groceries = PersonalList(title: "Groceries")
        let packing = PersonalList(title: "Packing")

        try await listsRepo.createList(groceries)
        try await listsRepo.createList(packing)

        // Test exact match
        let allLists = try await listsRepo.loadLists()
        let result = EntityLookup.findBestList(query: "Groceries", in: allLists)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Groceries")
    }

    func testFindListFuzzyMatch() async throws {
        // Create test list
        let groceries = PersonalList(title: "Groceries")
        try await listsRepo.createList(groceries)

        // Test fuzzy match
        let allLists = try await listsRepo.loadLists()
        let result = EntityLookup.findBestList(query: "groc", in: allLists)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Groceries")
    }

    func testFindListCaseInsensitive() async throws {
        // Create test list
        let groceries = PersonalList(title: "Groceries")
        try await listsRepo.createList(groceries)

        // Test case-insensitive match
        let allLists = try await listsRepo.loadLists()
        let result = EntityLookup.findBestList(query: "groceries", in: allLists)

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.title, "Groceries")
    }

    func testFindListNotFound() async throws {
        // Create test list
        let groceries = PersonalList(title: "Groceries")
        try await listsRepo.createList(groceries)

        // Test no match
        let allLists = try await listsRepo.loadLists()
        let result = EntityLookup.findBestList(query: "xyz", in: allLists)

        XCTAssertNil(result)
    }

    // MARK: - Add Item Tests

    func testAddItemToList() async throws {
        // Create test list
        var groceries = PersonalList(title: "Groceries", items: [])
        try await listsRepo.createList(groceries)

        // Simulate adding an item
        let newItem = ChecklistItem(text: "Milk", isDone: false)
        groceries.items.append(newItem)
        groceries.updatedAt = Date()

        try await listsRepo.updateList(groceries)

        // Verify
        let updated = try await listsRepo.loadList(groceries.id)
        XCTAssertEqual(updated.items.count, 1)
        XCTAssertEqual(updated.items[0].text, "Milk")
        XCTAssertFalse(updated.items[0].isDone)
    }

    func testAddItemWithQuantityAndUnit() async throws {
        // Create test list
        var groceries = PersonalList(title: "Groceries", items: [])
        try await listsRepo.createList(groceries)

        // Add item with quantity and unit
        let newItem = ChecklistItem(
            text: "Milk",
            isDone: false,
            quantity: 2.0,
            unit: "liters"
        )
        groceries.items.append(newItem)
        groceries.updatedAt = Date()

        try await listsRepo.updateList(groceries)

        // Verify
        let updated = try await listsRepo.loadList(groceries.id)
        XCTAssertEqual(updated.items.count, 1)
        XCTAssertEqual(updated.items[0].text, "Milk")
        XCTAssertEqual(updated.items[0].quantity, 2.0)
        XCTAssertEqual(updated.items[0].unit, "liters")
    }

    func testAddMultipleItems() async throws {
        // Create test list
        var groceries = PersonalList(title: "Groceries", items: [])
        try await listsRepo.createList(groceries)

        // Add multiple items
        groceries.items.append(ChecklistItem(text: "Milk"))
        groceries.items.append(ChecklistItem(text: "Bread"))
        groceries.items.append(ChecklistItem(text: "Eggs"))
        groceries.updatedAt = Date()

        try await listsRepo.updateList(groceries)

        // Verify
        let updated = try await listsRepo.loadList(groceries.id)
        XCTAssertEqual(updated.items.count, 3)
        XCTAssertEqual(updated.items[0].text, "Milk")
        XCTAssertEqual(updated.items[1].text, "Bread")
        XCTAssertEqual(updated.items[2].text, "Eggs")
    }
}
#endif
