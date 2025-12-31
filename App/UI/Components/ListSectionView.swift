// App/UI/Components/ListSectionView.swift
// Embedded personal list view for CardDetailView

import SwiftUI
import Domain

/// Collapsible personal list section for display within a card
struct ListSectionView: View {
    let list: PersonalList?
    let onEdit: () -> Void
    let onDetach: () -> Void
    let onAttach: () -> Void
    let onToggleItem: ((Int) -> Void)?

    @State private var isExpanded: Bool = true

    var body: some View {
        Section {
            if let list = list {
                // List attached - show it
                VStack(alignment: .leading, spacing: 12) {
                    // Header with expand/collapse and progress
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundStyle(.green)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(list.title)
                                    .font(.headline)
                                Text("\(completedCount(list))/\(list.items.count) items")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("List: \(list.title), \(completedCount(list)) of \(list.items.count) items completed, \(isExpanded ? "expanded" : "collapsed")")

                    if isExpanded {
                        // Progress bar
                        if !list.items.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                ProgressView(
                                    value: Double(completedCount(list)),
                                    total: Double(list.items.count)
                                )
                                .accessibilityLabel("\(completedCount(list)) of \(list.items.count) items completed")
                            }
                        }

                        // Items (first 5)
                        if list.items.isEmpty {
                            Text("No items in this list")
                                .foregroundStyle(.secondary)
                                .italic()
                                .font(.caption)
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(list.items.prefix(5).enumerated()), id: \.element.id) { index, item in
                                    HStack(spacing: 8) {
                                        Button {
                                            onToggleItem?(index)
                                        } label: {
                                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                                .foregroundStyle(item.isDone ? .green : .secondary)
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(item.isDone ? "Mark as incomplete" : "Mark as complete")

                                        HStack(spacing: 4) {
                                            if let quantity = item.quantity {
                                                Text(formatQuantity(quantity))
                                                    .fontWeight(.medium)
                                                    .font(.caption)
                                            }
                                            if let unit = item.unit {
                                                Text(unit)
                                                    .fontWeight(.medium)
                                                    .font(.caption)
                                            }
                                            Text(item.text)
                                                .font(.caption)
                                                .strikethrough(item.isDone)
                                                .foregroundStyle(item.isDone ? .secondary : .primary)
                                        }

                                        Spacer()
                                    }
                                }

                                if list.items.count > 5 {
                                    Text("+ \(list.items.count - 5) more items")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .italic()
                                }
                            }
                        }

                        // Actions
                        HStack(spacing: 16) {
                            Button {
                                onEdit()
                            } label: {
                                Label("Edit List", systemImage: "pencil")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)

                            Button(role: .destructive) {
                                onDetach()
                            } label: {
                                Label("Detach", systemImage: "link.badge.minus")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            } else {
                // No list attached - show attach button
                Button {
                    onAttach()
                } label: {
                    HStack {
                        Image(systemName: "checklist")
                            .foregroundStyle(.secondary)
                        Text("Attach List")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Attach list to this card")
            }
        } header: {
            if list == nil {
                Text("List")
            }
        }
    }

    private func completedCount(_ list: PersonalList) -> Int {
        list.items.filter(\.isDone).count
    }

    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

// MARK: - Previews

#Preview("With List") {
    let list = PersonalList(
        cardID: CardID(),
        title: "Shopping List",
        items: [
            ChecklistItem(text: "Milk", isDone: true, quantity: 2, unit: "L"),
            ChecklistItem(text: "Bread", isDone: false, quantity: 1, unit: nil),
            ChecklistItem(text: "Eggs", isDone: false, quantity: 12, unit: nil),
            ChecklistItem(text: "Coffee", isDone: true, quantity: 500, unit: "g")
        ]
    )

    Form {
        ListSectionView(
            list: list,
            onEdit: {},
            onDetach: {},
            onAttach: {},
            onToggleItem: { _ in }
        )
    }
}

#Preview("Without List") {
    Form {
        ListSectionView(
            list: nil,
            onEdit: {},
            onDetach: {},
            onAttach: {},
            onToggleItem: nil
        )
    }
}
