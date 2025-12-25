// Tests/UseCasesTests/Checklist/ChecklistOperationsTests.swift
// Unit tests for ChecklistOperations

import Domain
import XCTest
@testable import UseCases

final class ChecklistOperationsTests: XCTestCase {

    var service: ChecklistOperations!

    override func setUp() async throws {
        try await super.setUp()
        service = ChecklistOperations()
    }

    override func tearDown() async throws {
        service = nil
        try await super.tearDown()
    }

    // MARK: - Toggle Operation Tests

    func testToggleItem() async {
        let item = ChecklistItem(text: "Test Item", isDone: false)

        let toggled = await service.toggleItem(item)

        XCTAssertTrue(toggled.isDone)
        XCTAssertEqual(toggled.text, item.text)
        XCTAssertEqual(toggled.id, item.id)
    }

    func testToggleItem_FromTrueToFalse() async {
        let item = ChecklistItem(text: "Test Item", isDone: true)

        let toggled = await service.toggleItem(item)

        XCTAssertFalse(toggled.isDone)
    }

    func testToggleAllItems_SmallList() async {
        let items = [
            ChecklistItem(text: "Item 1", isDone: false),
            ChecklistItem(text: "Item 2", isDone: false),
            ChecklistItem(text: "Item 3", isDone: true),
        ]

        let result = await service.toggleAllItems(items, to: true, skipConfirmation: false)

        guard case .completed(let updated) = result else {
            XCTFail("Expected completed result")
            return
        }

        XCTAssertEqual(updated.count, 3)
        XCTAssertTrue(updated.allSatisfy { $0.isDone })
    }

    func testToggleAllItems_LargeList_RequiresConfirmation() async {
        let items = (0..<15).map { ChecklistItem(text: "Item \($0)", isDone: false) }

        let result = await service.toggleAllItems(items, to: true, skipConfirmation: false)

        guard case .requiresConfirmation(let count) = result else {
            XCTFail("Expected requiresConfirmation result")
            return
        }

        XCTAssertEqual(count, 15)
    }

    func testToggleAllItems_LargeList_SkipConfirmation() async {
        let items = (0..<15).map { ChecklistItem(text: "Item \($0)", isDone: false) }

        let result = await service.toggleAllItems(items, to: true, skipConfirmation: true)

        guard case .completed(let updated) = result else {
            XCTFail("Expected completed result")
            return
        }

        XCTAssertEqual(updated.count, 15)
        XCTAssertTrue(updated.allSatisfy { $0.isDone })
    }

    func testClearCompletedItems_SmallList() async {
        let items = [
            ChecklistItem(text: "Item 1", isDone: true),
            ChecklistItem(text: "Item 2", isDone: false),
            ChecklistItem(text: "Item 3", isDone: true),
        ]

        let result = await service.clearCompletedItems(items, skipConfirmation: false)

        guard case .completed(let remaining) = result else {
            XCTFail("Expected completed result")
            return
        }

        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining[0].text, "Item 2")
    }

    func testClearCompletedItems_LargeList_RequiresConfirmation() async {
        let items = (0..<15).map { ChecklistItem(text: "Item \($0)", isDone: true) }

        let result = await service.clearCompletedItems(items, skipConfirmation: false)

        guard case .requiresConfirmation(let count) = result else {
            XCTFail("Expected requiresConfirmation result")
            return
        }

        XCTAssertEqual(count, 15)
    }

    // MARK: - Reorder Operation Tests

    func testReorderItem() async throws {
        let items = [
            ChecklistItem(id: UUID(), text: "Item 1"),
            ChecklistItem(id: UUID(), text: "Item 2"),
            ChecklistItem(id: UUID(), text: "Item 3"),
        ]

        let reordered = try await service.reorderItem(items, itemID: items[2].id, toIndex: 0)

        XCTAssertEqual(reordered.count, 3)
        XCTAssertEqual(reordered[0].text, "Item 3")
        XCTAssertEqual(reordered[1].text, "Item 1")
        XCTAssertEqual(reordered[2].text, "Item 2")
    }

    func testReorderItem_ItemNotFound() async {
        let items = [
            ChecklistItem(text: "Item 1"),
            ChecklistItem(text: "Item 2"),
        ]
        let nonexistentID = UUID()

        do {
            _ = try await service.reorderItem(items, itemID: nonexistentID, toIndex: 0)
            XCTFail("Expected error")
        } catch let error as ChecklistError {
            XCTAssertEqual(error, .itemNotFound(nonexistentID))
        }
    }

    func testReorderItem_InvalidIndex() async {
        let items = [
            ChecklistItem(text: "Item 1"),
            ChecklistItem(text: "Item 2"),
        ]

        do {
            _ = try await service.reorderItem(items, itemID: items[0].id, toIndex: 10)
            XCTFail("Expected error")
        } catch let error as ChecklistError {
            XCTAssertEqual(error, .invalidIndex(10))
        }
    }

    func testMoveItemToTop() async throws {
        let items = [
            ChecklistItem(id: UUID(), text: "Item 1"),
            ChecklistItem(id: UUID(), text: "Item 2"),
            ChecklistItem(id: UUID(), text: "Item 3"),
        ]

        let reordered = try await service.moveItemToTop(items, itemID: items[2].id)

        XCTAssertEqual(reordered[0].text, "Item 3")
        XCTAssertEqual(reordered[1].text, "Item 1")
        XCTAssertEqual(reordered[2].text, "Item 2")
    }

    func testMoveItemToBottom() async throws {
        let items = [
            ChecklistItem(id: UUID(), text: "Item 1"),
            ChecklistItem(id: UUID(), text: "Item 2"),
            ChecklistItem(id: UUID(), text: "Item 3"),
        ]

        let reordered = try await service.moveItemToBottom(items, itemID: items[0].id)

        XCTAssertEqual(reordered[0].text, "Item 2")
        XCTAssertEqual(reordered[1].text, "Item 3")
        XCTAssertEqual(reordered[2].text, "Item 1")
    }

    // MARK: - Quantity and Unit Tests

    func testUpdateQuantity() async {
        let item = ChecklistItem(text: "Milk", quantity: nil)

        let updated = await service.updateQuantity(item, quantity: 2.5)

        XCTAssertEqual(updated.quantity, 2.5)
        XCTAssertEqual(updated.text, "Milk")
    }

    func testUpdateQuantity_RemoveQuantity() async {
        let item = ChecklistItem(text: "Milk", quantity: 2.5)

        let updated = await service.updateQuantity(item, quantity: nil)

        XCTAssertNil(updated.quantity)
    }

    func testUpdateUnit() async {
        let item = ChecklistItem(text: "Milk", unit: nil)

        let updated = await service.updateUnit(item, unit: "gallons")

        XCTAssertEqual(updated.unit, "gallons")
    }

    func testUpdateQuantityAndUnit() async {
        let item = ChecklistItem(text: "Milk")

        let updated = await service.updateQuantityAndUnit(item, quantity: 2.0, unit: "gallons")

        XCTAssertEqual(updated.quantity, 2.0)
        XCTAssertEqual(updated.unit, "gallons")
    }

    func testIncrementQuantity() async {
        let item = ChecklistItem(text: "Apples", quantity: 3.0)

        let updated = await service.incrementQuantity(item)

        XCTAssertEqual(updated.quantity, 4.0)
    }

    func testIncrementQuantity_FromNil() async {
        let item = ChecklistItem(text: "Apples", quantity: nil)

        let updated = await service.incrementQuantity(item, by: 2.0)

        XCTAssertEqual(updated.quantity, 2.0)
    }

    func testDecrementQuantity() async {
        let item = ChecklistItem(text: "Apples", quantity: 5.0)

        let updated = await service.decrementQuantity(item)

        XCTAssertEqual(updated.quantity, 4.0)
    }

    func testDecrementQuantity_DoesNotGoBelowZero() async {
        let item = ChecklistItem(text: "Apples", quantity: 0.5)

        let updated = await service.decrementQuantity(item)

        XCTAssertEqual(updated.quantity, 0.0)
    }

    func testDecrementQuantity_FromNil() async {
        let item = ChecklistItem(text: "Apples", quantity: nil)

        let updated = await service.decrementQuantity(item, by: 2.0)

        XCTAssertEqual(updated.quantity, 0.0)
    }

    // MARK: - Note Tests

    func testUpdateNote() async {
        let item = ChecklistItem(text: "Milk", note: nil)

        let updated = await service.updateNote(item, note: "Get organic")

        XCTAssertEqual(updated.note, "Get organic")
    }

    func testUpdateNote_Remove() async {
        let item = ChecklistItem(text: "Milk", note: "Get organic")

        let updated = await service.updateNote(item, note: nil)

        XCTAssertNil(updated.note)
    }

    // MARK: - Statistics Tests

    func testCalculateStatistics_EmptyList() async {
        let items: [ChecklistItem] = []

        let stats = await service.calculateStatistics(items)

        XCTAssertEqual(stats.totalItems, 0)
        XCTAssertEqual(stats.completedItems, 0)
        XCTAssertEqual(stats.incompleteItems, 0)
        XCTAssertEqual(stats.percentComplete, 0.0)
    }

    func testCalculateStatistics_AllComplete() async {
        let items = [
            ChecklistItem(text: "Item 1", isDone: true),
            ChecklistItem(text: "Item 2", isDone: true),
            ChecklistItem(text: "Item 3", isDone: true),
        ]

        let stats = await service.calculateStatistics(items)

        XCTAssertEqual(stats.totalItems, 3)
        XCTAssertEqual(stats.completedItems, 3)
        XCTAssertEqual(stats.incompleteItems, 0)
        XCTAssertEqual(stats.percentComplete, 100.0, accuracy: 0.01)
    }

    func testCalculateStatistics_PartialComplete() async {
        let items = [
            ChecklistItem(text: "Item 1", isDone: true),
            ChecklistItem(text: "Item 2", isDone: false),
            ChecklistItem(text: "Item 3", isDone: true),
            ChecklistItem(text: "Item 4", isDone: false),
        ]

        let stats = await service.calculateStatistics(items)

        XCTAssertEqual(stats.totalItems, 4)
        XCTAssertEqual(stats.completedItems, 2)
        XCTAssertEqual(stats.incompleteItems, 2)
        XCTAssertEqual(stats.percentComplete, 50.0, accuracy: 0.01)
    }

    func testCalculateStatistics_NoneComplete() async {
        let items = [
            ChecklistItem(text: "Item 1", isDone: false),
            ChecklistItem(text: "Item 2", isDone: false),
        ]

        let stats = await service.calculateStatistics(items)

        XCTAssertEqual(stats.totalItems, 2)
        XCTAssertEqual(stats.completedItems, 0)
        XCTAssertEqual(stats.incompleteItems, 2)
        XCTAssertEqual(stats.percentComplete, 0.0, accuracy: 0.01)
    }

    // MARK: - Bulk Action Policy Tests

    func testBulkActionPolicy_BelowThreshold() {
        XCTAssertFalse(BulkActionPolicy.requiresConfirmation(itemCount: 5))
        XCTAssertFalse(BulkActionPolicy.requiresConfirmation(itemCount: 10))
    }

    func testBulkActionPolicy_AboveThreshold() {
        XCTAssertTrue(BulkActionPolicy.requiresConfirmation(itemCount: 11))
        XCTAssertTrue(BulkActionPolicy.requiresConfirmation(itemCount: 100))
    }

    func testBulkActionPolicy_EdgeCase() {
        XCTAssertFalse(BulkActionPolicy.requiresConfirmation(itemCount: BulkActionPolicy.confirmationThreshold))
        XCTAssertTrue(BulkActionPolicy.requiresConfirmation(itemCount: BulkActionPolicy.confirmationThreshold + 1))
    }
}
