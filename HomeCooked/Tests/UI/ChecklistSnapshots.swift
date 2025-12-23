import SnapshotTesting
import SwiftData
import SwiftUI
import XCTest

@testable import HomeCooked

final class ChecklistSnapshots: XCTestCase {
    var modelContainer: ModelContainer!

    override func setUp() async throws {
        try await super.setUp()
        modelContainer = try ModelContainerFactory.createInMemory()

        // Set to true to record new snapshots
        // isRecording = true
    }

    override func tearDown() async throws {
        modelContainer = nil
        try await super.tearDown()
    }

    // MARK: - ChecklistView Snapshots

    func testEmptyChecklist() {
        let items: [ChecklistItem] = []

        let view = ChecklistView(
            items: items,
            onAdd: { _ in },
            onDelete: { _ in },
            onMove: { _, _ in },
            onUpdate: { _ in }
        )
        .frame(width: 375, height: 400)

        assertSnapshot(of: view, as: .image, named: "empty-checklist")
    }

    func testChecklistWithItems() {
        let items = [
            ChecklistItem(text: "Buy milk", quantity: 2.0, unit: "liters"),
            ChecklistItem(text: "Call dentist", isDone: true),
            ChecklistItem(
                text: "Book flight",
                quantity: 2.0,
                note: "Round trip to NYC"
            ),
            ChecklistItem(text: "Finish report"),
        ]

        let view = ChecklistView(
            items: items,
            onAdd: { _ in },
            onDelete: { _ in },
            onMove: { _, _ in },
            onUpdate: { _ in }
        )
        .frame(width: 375, height: 600)
        .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "checklist-with-items")
    }

    func testChecklistWithBulkActions() {
        let items = (1...12).map { index in
            ChecklistItem(
                text: "Item \(index)",
                isDone: index % 3 == 0
            )
        }

        let view = ChecklistView(
            items: items,
            onAdd: { _ in },
            onDelete: { _ in },
            onMove: { _, _ in },
            onUpdate: { _ in }
        )
        .frame(width: 375, height: 800)
        .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "checklist-bulk-actions")
    }

    func testChecklistItemRow() {
        let item = ChecklistItem(
            text: "Buy groceries",
            quantity: 5.0,
            unit: "items",
            note: "Don't forget the milk"
        )

        let view = ChecklistItemRow(
            item: item,
            onToggle: {},
            onTap: {}
        )
        .frame(width: 375, height: 100)
        .padding()

        assertSnapshot(of: view, as: .image, named: "checklist-item-unchecked")
    }

    func testChecklistItemRowChecked() {
        let item = ChecklistItem(
            text: "Buy groceries",
            isDone: true,
            quantity: 5.0,
            unit: "items",
            note: "Don't forget the milk"
        )

        let view = ChecklistItemRow(
            item: item,
            onToggle: {},
            onTap: {}
        )
        .frame(width: 375, height: 100)
        .padding()

        assertSnapshot(of: view, as: .image, named: "checklist-item-checked")
    }

    func testChecklistItemMinimal() {
        let item = ChecklistItem(text: "Simple task")

        let view = ChecklistItemRow(
            item: item,
            onToggle: {},
            onTap: {}
        )
        .frame(width: 375, height: 80)
        .padding()

        assertSnapshot(of: view, as: .image, named: "checklist-item-minimal")
    }

    // MARK: - ChecklistItemEditor Snapshots

    func testChecklistItemEditor() {
        let item = ChecklistItem(
            text: "Buy milk",
            quantity: 2.0,
            unit: "liters",
            note: "Full cream"
        )

        let view = ChecklistItemEditor(
            item: item,
            onSave: { _ in },
            onCancel: {}
        )
        .frame(width: 375, height: 667)

        assertSnapshot(of: view, as: .image, named: "checklist-editor")
    }

    func testChecklistItemEditorEmpty() {
        let item = ChecklistItem(text: "")

        let view = ChecklistItemEditor(
            item: item,
            onSave: { _ in },
            onCancel: {}
        )
        .frame(width: 375, height: 667)

        assertSnapshot(of: view, as: .image, named: "checklist-editor-empty")
    }

    // MARK: - CardDetailView Snapshots

    func testCardDetailView() {
        let card = Card(title: "Grocery Shopping")
        let item1 = ChecklistItem(text: "Milk", quantity: 2.0, unit: "L")
        let item2 = ChecklistItem(text: "Bread", isDone: true)
        let item3 = ChecklistItem(text: "Eggs", quantity: 12.0)

        card.checklist = [item1, item2, item3]
        card.details = "Weekly grocery run"
        card.tags = ["Shopping", "Urgent"]

        let view = CardDetailView(card: card)
            .frame(width: 375, height: 800)
            .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "card-detail-view")
    }

    // MARK: - ListsView Snapshots

    func testListsView() {
        let context = ModelContext(modelContainer)

        let groceries = PersonalList(title: "Groceries")
        let packing = PersonalList(title: "Packing List")

        context.insert(groceries)
        context.insert(packing)

        try? context.save()

        let view = ListsView()
            .frame(width: 375, height: 667)
            .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "lists-view")
    }

    func testPersonalListDetailView() {
        let list = PersonalList(title: "Grocery List")
        let items = [
            ChecklistItem(text: "Milk", quantity: 2.0, unit: "L"),
            ChecklistItem(text: "Bread", isDone: true),
            ChecklistItem(text: "Eggs", quantity: 12.0),
            ChecklistItem(text: "Butter", quantity: 250.0, unit: "g"),
        ]

        list.items = items

        let view = PersonalListDetailView(list: list)
            .frame(width: 375, height: 667)
            .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "personal-list-detail")
    }

    // MARK: - Dark Mode Snapshots

    func testChecklistDarkMode() {
        let items = [
            ChecklistItem(text: "Buy milk", quantity: 2.0, unit: "liters"),
            ChecklistItem(text: "Call dentist", isDone: true),
            ChecklistItem(text: "Finish report"),
        ]

        let view = ChecklistView(
            items: items,
            onAdd: { _ in },
            onDelete: { _ in },
            onMove: { _, _ in },
            onUpdate: { _ in }
        )
        .frame(width: 375, height: 600)
        .preferredColorScheme(.dark)
        .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "checklist-dark-mode")
    }

    func testCardDetailViewDarkMode() {
        let card = Card(title: "Weekly Tasks")
        let item1 = ChecklistItem(text: "Review PRs", isDone: true)
        let item2 = ChecklistItem(text: "Write tests")

        card.checklist = [item1, item2]

        let view = CardDetailView(card: card)
            .frame(width: 375, height: 800)
            .preferredColorScheme(.dark)
            .modelContainer(modelContainer)

        assertSnapshot(of: view, as: .image, named: "card-detail-dark-mode")
    }
}
