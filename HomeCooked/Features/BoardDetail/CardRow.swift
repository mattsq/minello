import SwiftUI

/// A row displaying a card in a Kanban column with drag-and-drop support
struct CardRow: View {
    let card: Card
    let position: Int
    let totalCards: Int
    var onTap: (() -> Void)?

    @State private var isDragging = false

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
                .font(.body)
                .accessibilityLabel("Drag handle")
                .accessibilityHint("Double tap and hold to start dragging")

            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if !card.details.isEmpty {
                    Text(card.details)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    // Checklist indicator
                    if !card.checklist.isEmpty {
                        let completed = card.checklist.filter(\.isDone).count
                        let total = card.checklist.count

                        Label(
                            "\(completed)/\(total)",
                            systemImage: "checkmark.square"
                        )
                        .font(.caption2)
                        .foregroundStyle(completed == total ? .green : .secondary)
                    }

                    // Due date indicator
                    if let due = card.due {
                        let isOverdue = due < Date()
                        Label(
                            due.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
                        .font(.caption2)
                        .foregroundStyle(isOverdue ? .red : .secondary)
                    }

                    // Tags
                    ForEach(card.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundStyle(.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(
            color: Color.black.opacity(isDragging ? 0.2 : 0.05),
            radius: isDragging ? 8 : 2,
            y: isDragging ? 4 : 1
        )
        .scaleEffect(isDragging ? 1.02 : 1.0)
        .opacity(isDragging ? 0.8 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Card at position \(position + 1) of \(totalCards). Tap to view details.")
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityDescription: String {
        var description = card.title

        if !card.details.isEmpty {
            description += ". " + card.details
        }

        if !card.checklist.isEmpty {
            let completed = card.checklist.filter(\.isDone).count
            let total = card.checklist.count
            description += ". Checklist: \(completed) of \(total) complete"
        }

        if let due = card.due {
            let isOverdue = due < Date()
            description += ". Due \(due.formatted(date: .abbreviated, time: .omitted))"
            if isOverdue {
                description += " (overdue)"
            }
        }

        if !card.tags.isEmpty {
            description += ". Tags: " + card.tags.joined(separator: ", ")
        }

        return description
    }

    func dragging(_ isDragging: Bool) -> some View {
        var view = self
        view._isDragging = State(initialValue: isDragging)
        return view
    }
}

#if DEBUG
    #Preview("Card with details") {
        let card = Card(
            title: "Implement drag and drop",
            details: "Add support for reordering cards across columns",
            due: Date().addingTimeInterval(86400),
            tags: ["feature", "ui"],
            checklist: [
                ChecklistItem(text: "Design UI", isDone: true),
                ChecklistItem(text: "Implement logic", isDone: false),
                ChecklistItem(text: "Add tests", isDone: false),
            ]
        )

        return CardRow(card: card, position: 0, totalCards: 3)
            .padding()
            .background(Color(.systemGroupedBackground))
    }

    #Preview("Simple card") {
        let card = Card(
            title: "Buy milk"
        )

        return CardRow(card: card, position: 1, totalCards: 3)
            .padding()
            .background(Color(.systemGroupedBackground))
    }

    #Preview("Dragging state") {
        let card = Card(
            title: "Card being dragged",
            tags: ["important"]
        )

        return CardRow(card: card, position: 0, totalCards: 1)
            .dragging(true)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
#endif
