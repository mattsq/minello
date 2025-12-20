import SwiftUI

/// Individual card row view with drag handle and accessibility support
struct CardRow: View {
    let card: Card
    let index: Int
    let totalCards: Int
    let isDragging: Bool
    let onTap: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 12) {
            // Drag handle
            Image(systemName: "line.3.horizontal")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 20)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(card.title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                // Metadata
                HStack(spacing: 8) {
                    if !card.checklist.isEmpty {
                        Label {
                            Text("\(card.checklist.filter(\.isDone).count)/\(card.checklist.count)")
                        } icon: {
                            Image(systemName: "checkmark.circle")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    if let due = card.due {
                        Label {
                            Text(due, style: .date)
                        } icon: {
                            Image(systemName: "calendar")
                        }
                        .font(.caption)
                        .foregroundStyle(isDueSoon(due) ? .orange : .secondary)
                    }

                    if !card.tags.isEmpty {
                        Label {
                            Text("\(card.tags.count)")
                        } icon: {
                            Image(systemName: "tag")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(isDragging ? 0.2 : 0.1),
                    radius: isDragging ? 8 : 2,
                    y: isDragging ? 4 : 1
                )
        )
        .opacity(isDragging ? 0.8 : 1.0)
        .scaleEffect(isDragging && !reduceMotion ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isDragging)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityCardLabel)
        .accessibilityHint("Double tap to view card details. Card \(index + 1) of \(totalCards).")
        .accessibilityAddTraits(.isButton)
    }

    private var accessibilityCardLabel: String {
        var label = "Card: \(card.title)"

        if !card.checklist.isEmpty {
            let completed = card.checklist.filter(\.isDone).count
            label += ". \(completed) of \(card.checklist.count) checklist items completed"
        }

        if let due = card.due {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            label += ". Due \(formatter.string(from: due))"
        }

        if !card.tags.isEmpty {
            label += ". Tags: \(card.tags.joined(separator: ", "))"
        }

        return label
    }

    private func isDueSoon(_ date: Date) -> Bool {
        let threeDaysFromNow = Calendar.current.date(
            byAdding: .day,
            value: 3,
            to: Date()
        ) ?? Date()
        return date <= threeDaysFromNow
    }
}

#if DEBUG
    #Preview("Card with Checklist") {
        CardRow(
            card: Card(
                title: "Buy groceries",
                details: "Weekly shopping",
                checklist: [
                    ChecklistItem(text: "Milk", isDone: true),
                    ChecklistItem(text: "Eggs", isDone: false),
                    ChecklistItem(text: "Bread", isDone: false),
                ]
            ),
            index: 0,
            totalCards: 3,
            isDragging: false,
            onTap: {}
        )
        .padding()
    }

    #Preview("Card with Due Date") {
        CardRow(
            card: Card(
                title: "Call plumber",
                due: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
                tags: ["Home", "Urgent"]
            ),
            index: 1,
            totalCards: 3,
            isDragging: false,
            onTap: {}
        )
        .padding()
    }

    #Preview("Card Dragging") {
        CardRow(
            card: Card(
                title: "Pay bills",
                details: "Electricity and water"
            ),
            index: 2,
            totalCards: 3,
            isDragging: true,
            onTap: {}
        )
        .padding()
    }
#endif
