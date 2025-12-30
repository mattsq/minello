// Tests/PersistenceGRDBTests/ListsRepositoryContractTests.swift
// Contract tests for ListsRepository that can run against any implementation

import Domain
import Foundation
import PersistenceGRDB
import PersistenceInterfaces
import XCTest

/// Contract tests for ListsRepository
/// These tests can be run against any implementation of ListsRepository
final class ListsRepositoryContractTests: XCTestCase {
    var repository: ListsRepository!

    override func setUp() async throws {
        try await super.setUp()
        // Use in-memory GRDB for testing
        repository = try GRDBListsRepository.inMemory()
    }

    override func tearDown() async throws {
        repository = nil
        try await super.tearDown()
    }

    // MARK: - List Tests

    func testCreateAndLoadList() async throws {
        let list = PersonalList(
            id: ListID(),
            cardID: CardID(),
            title: "Grocery List",
            items: [
                ChecklistItem(text: "Milk", isDone: false, quantity: 1, unit: "gallon"),
                ChecklistItem(text: "Bread", isDone: true, quantity: 2, unit: "loaves"),
            ],
            createdAt: Date(),
            updatedAt: Date()
        )

        try await repository.createList(list)

        let loaded = try await repository.loadList(list.id)
        XCTAssertEqual(loaded.id, list.id)
        XCTAssertEqual(loaded.title, list.title)
        XCTAssertEqual(loaded.items.count, 2)
        XCTAssertEqual(loaded.items[0].text, "Milk")
        XCTAssertEqual(loaded.items[0].quantity, 1)
        XCTAssertEqual(loaded.items[0].unit, "gallon")
        XCTAssertEqual(loaded.items[1].text, "Bread")
        XCTAssertEqual(loaded.items[1].isDone, true)
    }

    func testLoadAllLists() async throws {
        let list1 = PersonalList(cardID: CardID(), title: "Groceries")
        let list2 = PersonalList(cardID: CardID(), title: "Packing List")

        try await repository.createList(list1)
        try await repository.createList(list2)

        let lists = try await repository.loadLists()
        XCTAssertEqual(lists.count, 2)
        XCTAssertTrue(lists.contains { $0.id == list1.id })
        XCTAssertTrue(lists.contains { $0.id == list2.id })
    }

    func testUpdateList() async throws {
        var list = PersonalList(
            cardID: CardID(),
            title: "Original Title",
            items: [ChecklistItem(text: "Item 1")]
        )
        try await repository.createList(list)

        list.title = "Updated Title"
        list.items.append(ChecklistItem(text: "Item 2"))
        list.updatedAt = Date()
        try await repository.updateList(list)

        let loaded = try await repository.loadList(list.id)
        XCTAssertEqual(loaded.title, "Updated Title")
        XCTAssertEqual(loaded.items.count, 2)
    }

    func testDeleteList() async throws {
        let list = PersonalList(cardID: CardID(), title: "To Delete")
        try await repository.createList(list)

        try await repository.deleteList(list.id)

        do {
            _ = try await repository.loadList(list.id)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testLoadNonexistentList() async throws {
        let nonexistentID = ListID()

        do {
            _ = try await repository.loadList(nonexistentID)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testListWithEmptyItems() async throws {
        let list = PersonalList(cardID: CardID(), title: "Empty List", items: [])
        try await repository.createList(list)

        let loaded = try await repository.loadList(list.id)
        XCTAssertEqual(loaded.title, "Empty List")
        XCTAssertEqual(loaded.items.count, 0)
    }

    func testListWithComplexItems() async throws {
        let list = PersonalList(
            cardID: CardID(),
            title: "Complex List",
            items: [
                ChecklistItem(
                    text: "Tomatoes",
                    isDone: false,
                    quantity: 4.5,
                    unit: "lbs",
                    note: "Get organic if available"
                ),
                ChecklistItem(
                    text: "Olive Oil",
                    isDone: true,
                    quantity: 1,
                    unit: "bottle",
                    note: nil
                ),
                ChecklistItem(
                    text: "Garlic",
                    isDone: false,
                    quantity: nil,
                    unit: nil,
                    note: "Fresh, not jarred"
                ),
            ]
        )

        try await repository.createList(list)

        let loaded = try await repository.loadList(list.id)
        XCTAssertEqual(loaded.items.count, 3)

        // Check first item
        XCTAssertEqual(loaded.items[0].text, "Tomatoes")
        XCTAssertEqual(loaded.items[0].quantity, 4.5)
        XCTAssertEqual(loaded.items[0].unit, "lbs")
        XCTAssertEqual(loaded.items[0].note, "Get organic if available")
        XCTAssertFalse(loaded.items[0].isDone)

        // Check second item
        XCTAssertEqual(loaded.items[1].text, "Olive Oil")
        XCTAssertTrue(loaded.items[1].isDone)

        // Check third item
        XCTAssertEqual(loaded.items[2].text, "Garlic")
        XCTAssertNil(loaded.items[2].quantity)
        XCTAssertNil(loaded.items[2].unit)
        XCTAssertEqual(loaded.items[2].note, "Fresh, not jarred")
    }

    func testListsAreSortedByCreationDate() async throws {
        // Create lists with slight delays to ensure different creation times
        let list1 = PersonalList(cardID: CardID(), title: "First List")
        try await repository.createList(list1)

        // Small delay to ensure different timestamps
        try await Task.sleep(nanoseconds: 10_000_000) // 10ms

        let list2 = PersonalList(cardID: CardID(), title: "Second List")
        try await repository.createList(list2)

        let lists = try await repository.loadLists()
        XCTAssertEqual(lists.count, 2)
        // First created should be first in the list
        XCTAssertEqual(lists[0].title, "First List")
        XCTAssertEqual(lists[1].title, "Second List")
    }

    // MARK: - Query Tests

    func testSearchLists() async throws {
        let list1 = PersonalList(cardID: CardID(), title: "Grocery Shopping")
        let list2 = PersonalList(cardID: CardID(), title: "Packing for Trip")
        let list3 = PersonalList(cardID: CardID(), title: "Shopping for Clothes")

        try await repository.createList(list1)
        try await repository.createList(list2)
        try await repository.createList(list3)

        let results = try await repository.searchLists(query: "shopping")
        XCTAssertEqual(results.count, 2)
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Grocery Shopping"))
        XCTAssertTrue(titles.contains("Shopping for Clothes"))
    }

    func testSearchListsNoMatches() async throws {
        let list = PersonalList(cardID: CardID(), title: "Grocery List")
        try await repository.createList(list)

        let results = try await repository.searchLists(query: "vacation")
        XCTAssertEqual(results.count, 0)
    }

    func testFindListsWithIncompleteItems() async throws {
        let completeList = PersonalList(
            cardID: CardID(),
            title: "Complete List",
            items: [
                ChecklistItem(text: "Item 1", isDone: true),
                ChecklistItem(text: "Item 2", isDone: true),
            ]
        )

        let incompleteList1 = PersonalList(
            cardID: CardID(),
            title: "Incomplete List 1",
            items: [
                ChecklistItem(text: "Item 1", isDone: true),
                ChecklistItem(text: "Item 2", isDone: false),
            ]
        )

        let incompleteList2 = PersonalList(
            cardID: CardID(),
            title: "Incomplete List 2",
            items: [
                ChecklistItem(text: "Item 1", isDone: false),
            ]
        )

        let emptyList = PersonalList(cardID: CardID(), title: "Empty List", items: [])

        try await repository.createList(completeList)
        try await repository.createList(incompleteList1)
        try await repository.createList(incompleteList2)
        try await repository.createList(emptyList)

        let results = try await repository.findListsWithIncompleteItems()
        XCTAssertEqual(results.count, 2)
        let titles = Set(results.map { $0.title })
        XCTAssertTrue(titles.contains("Incomplete List 1"))
        XCTAssertTrue(titles.contains("Incomplete List 2"))
        XCTAssertFalse(titles.contains("Complete List"))
        XCTAssertFalse(titles.contains("Empty List"))
    }

    func testUpdateListPreservesID() async throws {
        let originalID = ListID()
        var list = PersonalList(
            id: originalID,
            cardID: CardID(),
            title: "Original",
            items: [ChecklistItem(text: "Item 1")]
        )
        try await repository.createList(list)

        list.title = "Updated"
        try await repository.updateList(list)

        let loaded = try await repository.loadList(originalID)
        XCTAssertEqual(loaded.id, originalID)
        XCTAssertEqual(loaded.title, "Updated")
    }

    func testUpdateNonexistentListThrows() async throws {
        let list = PersonalList(cardID: CardID(), title: "Nonexistent")

        do {
            try await repository.updateList(list)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }

    func testDeleteNonexistentListThrows() async throws {
        let nonexistentID = ListID()

        do {
            try await repository.deleteList(nonexistentID)
            XCTFail("Expected notFound error")
        } catch let error as PersistenceError {
            if case .notFound = error {
                // Expected
            } else {
                XCTFail("Expected notFound error, got \(error)")
            }
        }
    }
}
