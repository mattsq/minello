import SwiftUI
import SwiftData

/// A column view displaying a vertical list of draggable cards
struct ColumnView: View {
    let column: Column
    @Binding var draggingCard: Card?
    let onCardTap: (Card) -> Void
    let onCardMove: (Card, Int, Column) -> Void

    @State private var dropTargetIndex: Int?
    @Environment(\.modelContext) private var modelContext

    private var sortedCards: [Card] {
        column.cards.sorted { $0.sortKey < $1.sortKey }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column header
            HStack {
                Text(column.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Text("\(column.cards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))

            // Cards list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(sortedCards.enumerated()), id: \.element.id) { index, card in
                        CardRow(
                            card: card,
                            index: index,
                            totalCards: sortedCards.count,
                            isDragging: draggingCard?.id == card.id,
                            onTap: { onCardTap(card) }
                        )
                        .onDrag {
                            draggingCard = card
                            Haptics.playDragStart()
                            return NSItemProvider(object: card.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: CardDropDelegate(
                                card: card,
                                column: column,
                                cards: sortedCards,
                                draggingCard: $draggingCard,
                                dropTargetIndex: $dropTargetIndex,
                                onCardMove: onCardMove
                            )
                        )
                    }

                    // Drop zone at the end
                    if !sortedCards.isEmpty {
                        Color.clear
                            .frame(height: 44)
                            .onDrop(
                                of: [.text],
                                delegate: ColumnEndDropDelegate(
                                    column: column,
                                    cards: sortedCards,
                                    draggingCard: $draggingCard,
                                    onCardMove: onCardMove
                                )
                            )
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
        }
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
}

// MARK: - Drop Delegates

/// Drop delegate for individual cards (drop between cards)
private struct CardDropDelegate: DropDelegate {
    let card: Card
    let column: Column
    let cards: [Card]
    @Binding var draggingCard: Card?
    @Binding var dropTargetIndex: Int?
    let onCardMove: (Card, Int, Column) -> Void

    func dropEntered(info: DropInfo) {
        guard let draggingCard = draggingCard,
              draggingCard.id != card.id
        else { return }

        if let fromIndex = cards.firstIndex(where: { $0.id == draggingCard.id }),
           let toIndex = cards.firstIndex(where: { $0.id == card.id })
        {
            dropTargetIndex = toIndex

            if fromIndex != toIndex {
                Haptics.playDragOver()
            }
        }
    }

    func dropExited(info: DropInfo) {
        dropTargetIndex = nil
    }

    func performDrop(info: DropInfo) -> Bool {
        defer {
            draggingCard = nil
            dropTargetIndex = nil
        }

        guard let draggingCard = draggingCard else { return false }

        if let toIndex = cards.firstIndex(where: { $0.id == card.id }) {
            onCardMove(draggingCard, toIndex, column)
            Haptics.playDropSuccess()
            return true
        }

        return false
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

/// Drop delegate for the end of a column (drop after all cards)
private struct ColumnEndDropDelegate: DropDelegate {
    let column: Column
    let cards: [Card]
    @Binding var draggingCard: Card?
    let onCardMove: (Card, Int, Column) -> Void

    func performDrop(info: DropInfo) -> Bool {
        defer {
            draggingCard = nil
        }

        guard let draggingCard = draggingCard else { return false }

        let lastIndex = cards.count
        onCardMove(draggingCard, lastIndex, column)
        Haptics.playDropSuccess()
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

#if DEBUG
    #Preview("Column with Cards") {
        @Previewable @State var draggingCard: Card?

        let column = Column(
            title: "To Do",
            index: 0,
            cards: [
                Card(title: "Buy groceries", sortKey: 0),
                Card(title: "Call plumber", sortKey: 1),
                Card(title: "Pay bills", sortKey: 2),
            ]
        )

        ColumnView(
            column: column,
            draggingCard: $draggingCard,
            onCardTap: { _ in },
            onCardMove: { _, _, _ in }
        )
        .modelContainer(for: [Board.self, Column.self, Card.self])
        .frame(height: 600)
        .padding()
    }

    #Preview("Empty Column") {
        @Previewable @State var draggingCard: Card?

        let column = Column(
            title: "Done",
            index: 2,
            cards: []
        )

        ColumnView(
            column: column,
            draggingCard: $draggingCard,
            onCardTap: { _ in },
            onCardMove: { _, _, _ in }
        )
        .modelContainer(for: [Board.self, Column.self, Card.self])
        .frame(height: 600)
        .padding()
    }
#endif
