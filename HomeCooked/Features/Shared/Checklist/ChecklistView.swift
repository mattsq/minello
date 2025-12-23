import SwiftData
import SwiftUI

struct ChecklistView: View {
    @Bindable var items: [ChecklistItem]
    var onAdd: (ChecklistItem) -> Void
    var onDelete: (ChecklistItem) -> Void
    var onMove: (IndexSet, Int) -> Void
    var onUpdate: (ChecklistItem) -> Void

    @State private var isAdding = false
    @State private var newItemText = ""
    @State private var editingItem: ChecklistItem?
    @State private var showBulkActions = false

    var body: some View {
        VStack(spacing: 0) {
            if !items.isEmpty {
                bulkActionsToolbar
            }

            List {
                ForEach(items, id: \.id) { item in
                    ChecklistItemRow(
                        item: item,
                        onToggle: {
                            item.isDone.toggle()
                            onUpdate(item)
                        },
                        onTap: {
                            editingItem = item
                        }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDelete(item)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onMove { indices, newOffset in
                    onMove(indices, newOffset)
                }

                if isAdding {
                    addItemRow
                } else {
                    Button(action: { isAdding = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Add Item")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .sheet(item: $editingItem) { item in
            ChecklistItemEditor(
                item: item,
                onSave: { updatedItem in
                    onUpdate(updatedItem)
                    editingItem = nil
                },
                onCancel: {
                    editingItem = nil
                }
            )
        }
    }

    private var bulkActionsToolbar: some View {
        HStack {
            Button(action: checkAll) {
                Label("Check All", systemImage: "checkmark.circle.fill")
            }
            .buttonStyle(.bordered)

            Spacer()

            Button(action: {
                if items.filter(\.isDone).count > 10 {
                    showBulkActions = true
                } else {
                    uncheckAll()
                }
            }) {
                Label("Uncheck All", systemImage: "circle")
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
        .confirmationDialog(
            "Uncheck \(items.filter(\.isDone).count) items?",
            isPresented: $showBulkActions,
            titleVisibility: .visible
        ) {
            Button("Uncheck All", role: .destructive) {
                uncheckAll()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var addItemRow: some View {
        HStack {
            TextField("New item", text: $newItemText, onCommit: addItem)
                .textFieldStyle(.plain)
                .submitLabel(.done)

            Button(action: addItem) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
            .disabled(newItemText.trimmingCharacters(in: .whitespaces).isEmpty)

            Button(action: { isAdding = false
                newItemText = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
    }

    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let newItem = ChecklistItem(text: trimmed)
        onAdd(newItem)
        newItemText = ""
        isAdding = false
    }

    private func checkAll() {
        for item in items where !item.isDone {
            item.isDone = true
            onUpdate(item)
        }
    }

    private func uncheckAll() {
        for item in items where item.isDone {
            item.isDone = false
            onUpdate(item)
        }
    }
}

struct ChecklistItemRow: View {
    @Bindable var item: ChecklistItem
    var onToggle: () -> Void
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(item.isDone ? .green : .gray)
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isDone ? "Checked" : "Unchecked")

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.text)
                        .strikethrough(item.isDone)
                        .foregroundStyle(item.isDone ? .secondary : .primary)

                    if let quantity = item.quantity, let unit = item.unit {
                        Text("\(quantity, specifier: "%.1f") \(unit)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let quantity = item.quantity {
                        Text("\(quantity, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let note = item.note, !note.isEmpty {
                        Text(note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .imageScale(.small)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
