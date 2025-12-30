// App/UI/Lists/ListEditorView.swift
// Editor view for creating and editing personal lists

import SwiftUI
import Domain

/// Editor view for creating or editing a personal list
struct ListEditorView: View {
    enum Mode {
        case create
        case edit(PersonalList)

        var title: String {
            switch self {
            case .create: return "New List"
            case .edit: return "Edit List"
            }
        }

        var saveButtonTitle: String {
            switch self {
            case .create: return "Create"
            case .edit: return "Save"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (PersonalList) -> Void

    @State private var title: String
    @State private var items: [ChecklistItem]
    @State private var showingAddItem = false

    init(mode: Mode, onSave: @escaping (PersonalList) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _title = State(initialValue: "")
            _items = State(initialValue: [])
        case .edit(let list):
            _title = State(initialValue: list.title)
            _items = State(initialValue: list.items)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section("List Details") {
                    TextField("List Title", text: $title)
                        .accessibilityLabel("List title")
                }

                // Items Section
                Section {
                    if items.isEmpty {
                        Text("No items added")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(items.indices, id: \.self) { index in
                            ItemEditorRow(
                                item: $items[index],
                                onDelete: {
                                    items.remove(at: index)
                                },
                                onMoveUp: index > 0 ? {
                                    items.swapAt(index, index - 1)
                                } : nil,
                                onMoveDown: index < items.count - 1 ? {
                                    items.swapAt(index, index + 1)
                                } : nil
                            )
                        }
                        .onMove { from, to in
                            items.move(fromOffsets: from, toOffset: to)
                        }
                    }

                    Button {
                        showingAddItem = true
                    } label: {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add item")
                } header: {
                    Text("Items")
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.saveButtonTitle) {
                        saveList()
                    }
                    .disabled(!isValid)
                }

                ToolbarItem(placement: .bottomBar) {
                    EditButton()
                        .disabled(items.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemSheet { item in
                    items.append(item)
                }
            }
        }
    }

    // MARK: - Computed Properties

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    private func saveList() {
        let list: PersonalList
        switch mode {
        case .create:
            list = PersonalList(cardID: CardID(), 
                title: title.trimmingCharacters(in: .whitespaces),
                items: items
            )
        case .edit(let existing):
            list = PersonalList(
                id: existing.id,
                cardID: CardID(),
                title: title.trimmingCharacters(in: .whitespaces),
                items: items,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
        }

        onSave(list)
        dismiss()
    }
}

// MARK: - Item Editor Row

private struct ItemEditorRow: View {
    @Binding var item: ChecklistItem
    let onDelete: () -> Void
    let onMoveUp: (() -> Void)?
    let onMoveDown: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .font(.body)

                HStack(spacing: 8) {
                    if let quantity = item.quantity {
                        Text(formatQuantity(quantity))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let unit = item.unit {
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let note = item.note, !note.isEmpty {
                        Text("(\(note))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Menu {
                if let onMoveUp = onMoveUp {
                    Button {
                        onMoveUp()
                    } label: {
                        Label("Move Up", systemImage: "arrow.up")
                    }
                }

                if let onMoveDown = onMoveDown {
                    Button {
                        onMoveDown()
                    } label: {
                        Label("Move Down", systemImage: "arrow.down")
                    }
                }

                Divider()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Item actions")
        }
    }

    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

// MARK: - Add Item Sheet

private struct AddItemSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAdd: (ChecklistItem) -> Void

    @State private var text: String = ""
    @State private var quantity: String = ""
    @State private var unit: String = ""
    @State private var note: String = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case text, quantity, unit, note
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $text)
                        .focused($focusedField, equals: .text)
                        .accessibilityLabel("Item name")

                    HStack {
                        TextField("Quantity", text: $quantity)
                            .focused($focusedField, equals: .quantity)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("Quantity")

                        TextField("Unit", text: $unit)
                            .focused($focusedField, equals: .unit)
                            .accessibilityLabel("Unit")
                    }

                    TextField("Note (optional)", text: $note)
                        .focused($focusedField, equals: .note)
                        .accessibilityLabel("Note")
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                focusedField = .text
            }
        }
    }

    private func addItem() {
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }

        let parsedQuantity = Double(quantity.trimmingCharacters(in: .whitespaces))
        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)

        let item = ChecklistItem(
            text: trimmedText,
            isDone: false,
            quantity: parsedQuantity,
            unit: trimmedUnit.isEmpty ? nil : trimmedUnit,
            note: trimmedNote.isEmpty ? nil : trimmedNote
        )

        onAdd(item)
        dismiss()
    }
}

// MARK: - Previews

#Preview("Create List") {
    ListEditorView(mode: .create) { list in
        print("Created list: \(list.title)")
    }
}

#Preview("Edit List") {
    let list = PersonalList(cardID: CardID(), 
        title: "Groceries",
        items: [
            ChecklistItem(text: "Milk", quantity: 2, unit: "L"),
            ChecklistItem(text: "Bread", quantity: 1),
            ChecklistItem(text: "Eggs", quantity: 12, note: "Free range")
        ]
    )

    ListEditorView(mode: .edit(list)) { updatedList in
        print("Updated list: \(updatedList.title)")
    }
}
