import SwiftData
import XCTest

@testable import HomeCooked

final class ListsIntegrationTests: XCTestCase {
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

    // MARK: - PersonalList Persistence Tests

    func testPersonalListPersistsAcrossContexts() throws {
        // Create a list in one context
        let list = PersonalList(title: "Groceries")
        let item1 = ChecklistItem(text: "Milk", quantity: 2.0, unit: "L")
        let item2 = ChecklistItem(text: "Bread")

        item1.personalList = list
        item2.personalList = list
        list.items = [item1, item2]

        modelContext.insert(list)
        modelContext.insert(item1)
        modelContext.insert(item2)

        try modelContext.save()

        let listId = list.id

        // Fetch in a new context
        let newContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try newContext.fetch(descriptor)

        XCTAssertEqual(fetchedLists.count, 1)

        let fetchedList = try XCTUnwrap(fetchedLists.first)
        XCTAssertEqual(fetchedList.title, "Groceries")
        XCTAssertEqual(fetchedList.items.count, 2)
    }

    func testPersonalListItemsOrderPreserved() throws {
        let list = PersonalList(title: "Packing")

        let items = [
            ChecklistItem(text: "Passport"),
            ChecklistItem(text: "Tickets"),
            ChecklistItem(text: "Wallet"),
            ChecklistItem(text: "Phone charger"),
            ChecklistItem(text: "Headphones"),
        ]

        for item in items {
            item.personalList = list
            modelContext.insert(item)
        }

        list.items = items
        modelContext.insert(list)
        try modelContext.save()

        let listId = list.id

        // Fetch and verify order
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try modelContext.fetch(descriptor)
        let fetchedList = try XCTUnwrap(fetchedLists.first)

        XCTAssertEqual(fetchedList.items.count, 5)
        XCTAssertEqual(fetchedList.items[0].text, "Passport")
        XCTAssertEqual(fetchedList.items[1].text, "Tickets")
        XCTAssertEqual(fetchedList.items[2].text, "Wallet")
        XCTAssertEqual(fetchedList.items[3].text, "Phone charger")
        XCTAssertEqual(fetchedList.items[4].text, "Headphones")
    }

    func testPersonalListUpdate() throws {
        let list = PersonalList(title: "Original Title")
        modelContext.insert(list)
        try modelContext.save()

        let listId = list.id

        // Update title
        list.title = "Updated Title"
        try modelContext.save()

        // Fetch and verify
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try modelContext.fetch(descriptor)
        let fetchedList = try XCTUnwrap(fetchedLists.first)

        XCTAssertEqual(fetchedList.title, "Updated Title")
    }

    func testAddItemToExistingList() throws {
        let list = PersonalList(title: "Shopping")
        modelContext.insert(list)
        try modelContext.save()

        let item = ChecklistItem(text: "New item")
        item.personalList = list
        list.items.append(item)

        modelContext.insert(item)
        try modelContext.save()

        let listId = list.id

        // Fetch and verify
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try modelContext.fetch(descriptor)
        let fetchedList = try XCTUnwrap(fetchedLists.first)

        XCTAssertEqual(fetchedList.items.count, 1)
        XCTAssertEqual(fetchedList.items[0].text, "New item")
    }

    func testRemoveItemFromList() throws {
        let list = PersonalList(title: "Tasks")
        let item1 = ChecklistItem(text: "Keep this")
        let item2 = ChecklistItem(text: "Delete this")

        item1.personalList = list
        item2.personalList = list
        list.items = [item1, item2]

        modelContext.insert(list)
        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()

        // Remove item2
        if let index = list.items.firstIndex(where: { $0.id == item2.id }) {
            list.items.remove(at: index)
            modelContext.delete(item2)
        }

        try modelContext.save()

        let listId = list.id

        // Fetch and verify
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try modelContext.fetch(descriptor)
        let fetchedList = try XCTUnwrap(fetchedLists.first)

        XCTAssertEqual(fetchedList.items.count, 1)
        XCTAssertEqual(fetchedList.items[0].text, "Keep this")
    }

    func testCascadeDeletePersonalList() throws {
        let list = PersonalList(title: "To Delete")
        let item1 = ChecklistItem(text: "Item 1")
        let item2 = ChecklistItem(text: "Item 2")

        item1.personalList = list
        item2.personalList = list
        list.items = [item1, item2]

        modelContext.insert(list)
        modelContext.insert(item1)
        modelContext.insert(item2)
        try modelContext.save()

        // Delete the list
        modelContext.delete(list)
        try modelContext.save()

        // Verify items are also deleted
        let itemsDescriptor = FetchDescriptor<ChecklistItem>()
        let remainingItems = try modelContext.fetch(itemsDescriptor)

        XCTAssertTrue(
            remainingItems.isEmpty,
            "ChecklistItems should be deleted when PersonalList is deleted"
        )
    }

    // MARK: - Card Checklist Integration Tests

    func testCardChecklistPersistence() throws {
        let card = Card(title: "Project Tasks")
        let item1 = ChecklistItem(text: "Design mockups", isDone: true)
        let item2 = ChecklistItem(text: "Implement feature")
        let item3 = ChecklistItem(text: "Write tests")

        item1.card = card
        item2.card = card
        item3.card = card
        card.checklist = [item1, item2, item3]

        modelContext.insert(card)
        for item in [item1, item2, item3] {
            modelContext.insert(item)
        }

        try modelContext.save()

        let cardId = card.id

        // Fetch in new context
        let newContext = ModelContext(modelContainer)
        let descriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.id == cardId }
        )

        let fetchedCards = try newContext.fetch(descriptor)
        let fetchedCard = try XCTUnwrap(fetchedCards.first)

        XCTAssertEqual(fetchedCard.checklist.count, 3)
        XCTAssertEqual(fetchedCard.checklist[0].text, "Design mockups")
        XCTAssertTrue(fetchedCard.checklist[0].isDone)
        XCTAssertFalse(fetchedCard.checklist[1].isDone)
    }

    func testUpdateChecklistItemInCard() throws {
        let card = Card(title: "Shopping")
        let item = ChecklistItem(text: "Buy milk")

        item.card = card
        card.checklist = [item]

        modelContext.insert(card)
        modelContext.insert(item)
        try modelContext.save()

        // Update item
        item.isDone = true
        item.quantity = 2.0
        item.unit = "L"
        item.note = "Full cream"

        try modelContext.save()

        let cardId = card.id

        // Fetch and verify
        let descriptor = FetchDescriptor<Card>(
            predicate: #Predicate { $0.id == cardId }
        )

        let fetchedCards = try modelContext.fetch(descriptor)
        let fetchedCard = try XCTUnwrap(fetchedCards.first)
        let fetchedItem = try XCTUnwrap(fetchedCard.checklist.first)

        XCTAssertTrue(fetchedItem.isDone)
        XCTAssertEqual(fetchedItem.quantity, 2.0)
        XCTAssertEqual(fetchedItem.unit, "L")
        XCTAssertEqual(fetchedItem.note, "Full cream")
    }

    // MARK: - Complex Scenarios

    func testMultipleListsWithSharedItemNames() throws {
        let groceries = PersonalList(title: "Groceries")
        let packing = PersonalList(title: "Packing")

        let groceryMilk = ChecklistItem(text: "Milk", quantity: 2.0, unit: "L")
        let packingMilk = ChecklistItem(text: "Milk", note: "Travel size")

        groceryMilk.personalList = groceries
        packingMilk.personalList = packing

        groceries.items = [groceryMilk]
        packing.items = [packingMilk]

        modelContext.insert(groceries)
        modelContext.insert(packing)
        modelContext.insert(groceryMilk)
        modelContext.insert(packingMilk)

        try modelContext.save()

        // Verify both lists exist independently
        let listsDescriptor = FetchDescriptor<PersonalList>()
        let allLists = try modelContext.fetch(listsDescriptor)

        XCTAssertEqual(allLists.count, 2)

        let fetchedGroceries = try XCTUnwrap(
            allLists.first(where: { $0.title == "Groceries" })
        )
        let fetchedPacking = try XCTUnwrap(
            allLists.first(where: { $0.title == "Packing" })
        )

        XCTAssertEqual(fetchedGroceries.items.count, 1)
        XCTAssertEqual(fetchedPacking.items.count, 1)

        XCTAssertEqual(fetchedGroceries.items[0].quantity, 2.0)
        XCTAssertEqual(fetchedPacking.items[0].note, "Travel size")
    }

    func testBulkItemOperations() throws {
        let list = PersonalList(title: "Big List")

        // Create 50 items
        let items = (1...50).map { index in
            let item = ChecklistItem(
                text: "Item \(index)",
                isDone: index % 2 == 0
            )
            item.personalList = list
            return item
        }

        list.items = items
        modelContext.insert(list)

        for item in items {
            modelContext.insert(item)
        }

        try modelContext.save()

        let listId = list.id

        // Fetch and verify
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try modelContext.fetch(descriptor)
        let fetchedList = try XCTUnwrap(fetchedLists.first)

        XCTAssertEqual(fetchedList.items.count, 50)

        let doneCount = fetchedList.items.filter(\.isDone).count
        XCTAssertEqual(doneCount, 25)
    }

    func testReorderLargeList() throws {
        let list = PersonalList(title: "Ordered List")
        let items = (1...20).map { ChecklistItem(text: "Item \($0)") }

        for item in items {
            item.personalList = list
            modelContext.insert(item)
        }

        list.items = items
        modelContext.insert(list)
        try modelContext.save()

        // Move first item to last
        list.items.move(fromOffsets: IndexSet(integer: 0), toOffset: 20)
        try modelContext.save()

        let listId = list.id

        // Fetch and verify
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == listId }
        )

        let fetchedLists = try modelContext.fetch(descriptor)
        let fetchedList = try XCTUnwrap(fetchedLists.first)

        XCTAssertEqual(fetchedList.items.count, 20)
        XCTAssertEqual(fetchedList.items[0].text, "Item 2")
        XCTAssertEqual(fetchedList.items[19].text, "Item 1")
    }
}
