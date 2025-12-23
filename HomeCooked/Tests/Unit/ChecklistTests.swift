import SwiftData
import XCTest

@testable import HomeCooked

final class ChecklistTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        modelContainer = try ModelContainerFactory.createInMemory()
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        try await super.tearDown()
    }

    // MARK: - ChecklistItem Creation Tests

    func testChecklistItemCreation() {
        let item = ChecklistItem(
            text: "Buy milk",
            quantity: 2.0,
            unit: "liters",
            note: "Full cream"
        )

        XCTAssertEqual(item.text, "Buy milk")
        XCTAssertEqual(item.quantity, 2.0)
        XCTAssertEqual(item.unit, "liters")
        XCTAssertEqual(item.note, "Full cream")
        XCTAssertFalse(item.isDone)
    }

    func testChecklistItemDefaults() {
        let item = ChecklistItem(text: "Test item")

        XCTAssertEqual(item.text, "Test item")
        XCTAssertNil(item.quantity)
        XCTAssertNil(item.unit)
        XCTAssertNil(item.note)
        XCTAssertFalse(item.isDone)
    }

    // MARK: - Card Checklist Tests

    func testCardWithChecklist() {
        let card = Card(title: "Grocery Shopping")
        let item1 = ChecklistItem(text: "Milk", quantity: 2.0, unit: "L")
        let item2 = ChecklistItem(text: "Bread")

        item1.card = card
        item2.card = card
        card.checklist = [item1, item2]

        modelContext.insert(card)
        modelContext.insert(item1)
        modelContext.insert(item2)

        try? modelContext.save()

        XCTAssertEqual(card.checklist.count, 2)
        XCTAssertEqual(card.checklist[0].text, "Milk")
        XCTAssertEqual(card.checklist[1].text, "Bread")
        XCTAssertNotNil(item1.card)
        XCTAssertEqual(item1.card?.id, card.id)
    }

    func testCardChecklistToggle() {
        let card = Card(title: "Tasks")
        let item = ChecklistItem(text: "Complete report")
        item.card = card
        card.checklist = [item]

        XCTAssertFalse(item.isDone)

        item.isDone = true
        XCTAssertTrue(item.isDone)

        item.isDone = false
        XCTAssertFalse(item.isDone)
    }

    // MARK: - PersonalList Tests

    func testPersonalListCreation() {
        let list = PersonalList(title: "Groceries")
        let item1 = ChecklistItem(text: "Apples", quantity: 6.0)
        let item2 = ChecklistItem(text: "Bananas", quantity: 3.0)

        item1.personalList = list
        item2.personalList = list
        list.items = [item1, item2]

        modelContext.insert(list)
        modelContext.insert(item1)
        modelContext.insert(item2)

        try? modelContext.save()

        XCTAssertEqual(list.title, "Groceries")
        XCTAssertEqual(list.items.count, 2)
        XCTAssertNotNil(item1.personalList)
        XCTAssertEqual(item1.personalList?.id, list.id)
    }

    func testPersonalListItemReorder() {
        let list = PersonalList(title: "Packing")
        let item1 = ChecklistItem(text: "Passport")
        let item2 = ChecklistItem(text: "Tickets")
        let item3 = ChecklistItem(text: "Wallet")

        list.items = [item1, item2, item3]

        XCTAssertEqual(list.items[0].text, "Passport")
        XCTAssertEqual(list.items[1].text, "Tickets")
        XCTAssertEqual(list.items[2].text, "Wallet")

        list.items.move(fromOffsets: IndexSet(integer: 0), toOffset: 3)

        XCTAssertEqual(list.items[0].text, "Tickets")
        XCTAssertEqual(list.items[1].text, "Wallet")
        XCTAssertEqual(list.items[2].text, "Passport")
    }

    // MARK: - Bulk Actions Tests

    func testBulkCheckAll() {
        let list = PersonalList(title: "Tasks")
        let items = (1...5).map { ChecklistItem(text: "Task \($0)") }
        list.items = items

        // Initially all unchecked
        XCTAssertTrue(list.items.allSatisfy { !$0.isDone })

        // Check all
        for item in list.items {
            item.isDone = true
        }

        XCTAssertTrue(list.items.allSatisfy(\.isDone))
    }

    func testBulkUncheckAll() {
        let list = PersonalList(title: "Tasks")
        let items = (1...5).map { ChecklistItem(text: "Task \($0)", isDone: true) }
        list.items = items

        // Initially all checked
        XCTAssertTrue(list.items.allSatisfy(\.isDone))

        // Uncheck all
        for item in list.items {
            item.isDone = false
        }

        XCTAssertTrue(list.items.allSatisfy { !$0.isDone })
    }

    func testBulkActionsWithMixedState() {
        let list = PersonalList(title: "Mixed")
        let item1 = ChecklistItem(text: "Done", isDone: true)
        let item2 = ChecklistItem(text: "Not done", isDone: false)
        let item3 = ChecklistItem(text: "Also done", isDone: true)

        list.items = [item1, item2, item3]

        let doneCount = list.items.filter(\.isDone).count
        XCTAssertEqual(doneCount, 2)

        // Uncheck all
        for item in list.items where item.isDone {
            item.isDone = false
        }

        XCTAssertTrue(list.items.allSatisfy { !$0.isDone })
    }

    // MARK: - Quantity and Unit Tests

    func testQuantityFormatting() {
        let item = ChecklistItem(text: "Flour", quantity: 2.5, unit: "kg")

        XCTAssertEqual(item.quantity, 2.5)
        XCTAssertEqual(item.unit, "kg")
    }

    func testQuantityWithoutUnit() {
        let item = ChecklistItem(text: "Eggs", quantity: 12.0)

        XCTAssertEqual(item.quantity, 12.0)
        XCTAssertNil(item.unit)
    }

    func testUpdateQuantityAndUnit() {
        let item = ChecklistItem(text: "Sugar")

        XCTAssertNil(item.quantity)
        XCTAssertNil(item.unit)

        item.quantity = 1.0
        item.unit = "kg"

        XCTAssertEqual(item.quantity, 1.0)
        XCTAssertEqual(item.unit, "kg")

        item.quantity = nil
        item.unit = nil

        XCTAssertNil(item.quantity)
        XCTAssertNil(item.unit)
    }

    // MARK: - Delete Tests

    func testDeleteChecklistItemFromCard() throws {
        let card = Card(title: "Shopping")
        let item = ChecklistItem(text: "Milk")

        item.card = card
        card.checklist = [item]

        modelContext.insert(card)
        modelContext.insert(item)
        try modelContext.save()

        XCTAssertEqual(card.checklist.count, 1)

        modelContext.delete(item)
        try modelContext.save()

        XCTAssertEqual(card.checklist.count, 0)
    }

    func testDeletePersonalList() throws {
        let list = PersonalList(title: "Old List")
        let item = ChecklistItem(text: "Item")

        item.personalList = list
        list.items = [item]

        modelContext.insert(list)
        modelContext.insert(item)
        try modelContext.save()

        modelContext.delete(list)
        try modelContext.save()

        // Item should be deleted due to cascade rule
        let descriptor = FetchDescriptor<ChecklistItem>()
        let items = try modelContext.fetch(descriptor)

        XCTAssertTrue(items.isEmpty, "ChecklistItem should be deleted with PersonalList")
    }
}
