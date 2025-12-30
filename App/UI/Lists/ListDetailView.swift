// App/UI/Lists/ListDetailView.swift
// Detail view for displaying and managing a personal list

import SwiftUI
import Domain

/// View for displaying list details with checklist items
struct ListDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let list: PersonalList
    let onUpdate: (PersonalList) -> Void
    let onDelete: () -> Void

    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false
    @State private var showingBulkImport = false
    @State private var showingShareSheet = false
    @State private var shareText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Stats header
                statsSection

                // Items section
                itemsSection
            }
            .padding()
        }
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditor = true
                    } label: {
                        Label("Edit List", systemImage: "pencil")
                    }

                    Button {
                        showingBulkImport = true
                    } label: {
                        Label("Bulk Add Items", systemImage: "text.badge.plus")
                    }

                    Button {
                        prepareShareText()
                        showingShareSheet = true
                    } label: {
                        Label("Share List", systemImage: "square.and.arrow.up")
                    }

                    Divider()

                    Button {
                        toggleAllItems(done: true)
                    } label: {
                        Label("Check All", systemImage: "checkmark.circle")
                    }

                    Button {
                        toggleAllItems(done: false)
                    } label: {
                        Label("Uncheck All", systemImage: "circle")
                    }

                    Button {
                        clearCompleted()
                    } label: {
                        Label("Clear Completed", systemImage: "trash")
                    }
                    .disabled(completedCount == 0)

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete List", systemImage: "trash")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
                .accessibilityLabel("List actions")
            }
        }
        .sheet(isPresented: $showingEditor) {
            ListEditorView(mode: .edit(list)) { updatedList in
                onUpdate(updatedList)
                showingEditor = false
            }
        }
        .sheet(isPresented: $showingBulkImport) {
            BulkImportSheet { newItems in
                var updatedList = list
                updatedList.items.append(contentsOf: newItems)
                updatedList.updatedAt = Date()
                onUpdate(updatedList)
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [shareText])
        }
        .alert("Delete List", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(list.title)'? This action cannot be undone.")
        }
    }

    // MARK: - View Components

    private var statsSection: some View {
        HStack(spacing: 20) {
            StatBadge(
                value: "\(list.items.count)",
                label: "Total",
                systemImage: "list.bullet"
            )

            StatBadge(
                value: "\(incompleteCount)",
                label: "To Do",
                systemImage: "circle"
            )

            StatBadge(
                value: "\(completedCount)",
                label: "Done",
                systemImage: "checkmark.circle.fill"
            )

            Spacer()
        }
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Items")
                .font(.title2)
                .fontWeight(.bold)

            if list.items.isEmpty {
                Text("No items in this list")
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(list.items.enumerated()), id: \.element.id) { index, item in
                        ChecklistItemRow(
                            item: item,
                            onToggle: { toggleItem(at: index) },
                            onDelete: { deleteItem(at: index) }
                        )
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(item.text), \(item.isDone ? "checked" : "unchecked")")
                        .accessibilityHint("Double tap to toggle")

                        if index < list.items.count - 1 {
                            Divider()
                                .padding(.leading, 44)
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
        }
    }

    // MARK: - Computed Properties

    private var incompleteCount: Int {
        list.items.filter { !$0.isDone }.count
    }

    private var completedCount: Int {
        list.items.filter { $0.isDone }.count
    }

    // MARK: - Actions

    private func toggleItem(at index: Int) {
        var updatedList = list
        updatedList.items[index].isDone.toggle()
        updatedList.updatedAt = Date()
        onUpdate(updatedList)
    }

    private func deleteItem(at index: Int) {
        var updatedList = list
        updatedList.items.remove(at: index)
        updatedList.updatedAt = Date()
        onUpdate(updatedList)
    }

    private func toggleAllItems(done: Bool) {
        var updatedList = list
        for i in updatedList.items.indices {
            updatedList.items[i].isDone = done
        }
        updatedList.updatedAt = Date()
        onUpdate(updatedList)
    }

    private func clearCompleted() {
        var updatedList = list
        updatedList.items.removeAll { $0.isDone }
        updatedList.updatedAt = Date()
        onUpdate(updatedList)
    }

    private func prepareShareText() {
        var text = "\(list.title)\n\n"
        for item in list.items {
            let checkbox = item.isDone ? "☑" : "☐"
            var line = "\(checkbox) "

            if let quantity = item.quantity {
                line += formatQuantity(quantity) + " "
            }
            if let unit = item.unit {
                line += "\(unit) "
            }
            line += item.text

            if let note = item.note, !note.isEmpty {
                line += " (\(note))"
            }

            text += line + "\n"
        }
        shareText = text
    }

    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let value: String
    let label: String
    let systemImage: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Checklist Item Row

private struct ChecklistItemRow: View {
    let item: ChecklistItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                onToggle()
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(item.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if let quantity = item.quantity {
                        Text(formatQuantity(quantity))
                            .fontWeight(.medium)
                    }
                    if let unit = item.unit {
                        Text(unit)
                            .fontWeight(.medium)
                    }
                    Text(item.text)
                        .strikethrough(item.isDone)
                        .foregroundStyle(item.isDone ? .secondary : .primary)
                }

                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete item")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }

    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

// MARK: - Bulk Import Sheet

private struct BulkImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onImport: ([ChecklistItem]) -> Void

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enter one item per line")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextEditor(text: $text)
                    .focused($isFocused)
                    .font(.body)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .border(Color.secondary.opacity(0.3), width: 1)
                    .accessibilityLabel("Bulk import text")

                Text("Preview: \(lineCount) items")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .navigationTitle("Bulk Add Items")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        importItems()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }

    private var lineCount: Int {
        text.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .count
    }

    private func importItems() {
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let items = lines.map { line in
            ChecklistItem(text: line, isDone: false)
        }

        onImport(items)
        dismiss()
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Previews

#Preview {
    let list = PersonalList(cardID: CardID(), 
        title: "Groceries",
        items: [
            ChecklistItem(text: "Milk", isDone: false, quantity: 2, unit: "L"),
            ChecklistItem(text: "Bread", isDone: true, quantity: 1),
            ChecklistItem(text: "Eggs", isDone: false, quantity: 12),
            ChecklistItem(text: "Coffee", isDone: false, quantity: 500, unit: "g", note: "Dark roast"),
            ChecklistItem(text: "Bananas", isDone: true, quantity: 6),
            ChecklistItem(text: "Cheese", isDone: false, quantity: 200, unit: "g")
        ]
    )

    NavigationStack {
        ListDetailView(
            list: list,
            onUpdate: { _ in },
            onDelete: {}
        )
    }
}
