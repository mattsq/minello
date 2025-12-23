import SwiftData
import SwiftUI

/// A view displaying a Kanban column with its cards
struct ColumnView: View {
    let column: Column
    let reorderService: CardReorderService
    var onCardTap: ((Card) -> Void)?
    var onAddCard: (() -> Void)?

    @State private var draggedCard: Card?
    @State private var dropTargetIndex: Int?

    private var sortedCards: [Card] {
        column.cards.sorted { $0.sortKey < $1.sortKey }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())

                Button {
                    onAddCard?()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.accentColor)
                }
                .accessibilityLabel("Add card to \(column.title)")
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Cards list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(sortedCards.enumerated()), id: \.element.id) { index, card in
                        CardRow(
                            card: card,
                            position: index,
                            totalCards: sortedCards.count,
                            onTap: {
                                onCardTap?(card)
                            }
                        )
                        .dragging(draggedCard?.id == card.id)
                        .onDrag {
                            draggedCard = card
                            Haptics.lightImpact()
                            return NSItemProvider(object: card.id.uuidString as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: CardDropDelegate(
                                card: card,
                                index: index,
                                column: column,
                                sortedCards: sortedCards,
                                draggedCard: $draggedCard,
                                dropTargetIndex: $dropTargetIndex,
                                reorderService: reorderService
                            )
                        )
                    }

                    // Drop zone at the end of the list
                    if !sortedCards.isEmpty {
                        DropZone(isActive: dropTargetIndex == sortedCards.count)
                            .onDrop(
                                of: [.text],
                                delegate: EndOfListDropDelegate(
                                    column: column,
                                    sortedCards: sortedCards,
                                    draggedCard: $draggedCard,
                                    dropTargetIndex: $dropTargetIndex,
                                    reorderService: reorderService
                                )
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(maxHeight: .infinity)
            .background(
                Color(.systemGray6)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }
        .frame(width: 300)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Drop zone indicator for the end of a card list
private struct DropZone: View {
    let isActive: Bool

    var body: some View {
        Rectangle()
            .fill(isActive ? Color.accentColor.opacity(0.3) : Color.clear)
            .frame(height: 60)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        isActive ? Color.accentColor : Color.clear,
                        style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                    )
            )
    }
}

/// Handles drop events for cards
private struct CardDropDelegate: DropDelegate {
    let card: Card
    let index: Int
    let column: Column
    let sortedCards: [Card]

    @Binding var draggedCard: Card?
    @Binding var dropTargetIndex: Int?
    let reorderService: CardReorderService

    func dropEntered(info: DropInfo) {
        guard let draggedCard else { return }

        // Don't show drop indicator if dropping on self
        if draggedCard.id == card.id {
            dropTargetIndex = nil
            return
        }

        dropTargetIndex = index
        Haptics.selectionChanged()
    }

    func dropExited(info: DropInfo) {
        dropTargetIndex = nil
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedCard else { return false }

        // Calculate insertion index
        var targetIndex = index

        // If we're in the same column and dragging downward,
        // adjust the index to account for the card being removed
        if draggedCard.column?.id == column.id {
            if let draggedIndex = sortedCards.firstIndex(where: { $0.id == draggedCard.id }),
               draggedIndex < index
            {
                targetIndex = index
            }
        }

        do {
            try reorderService.moveCard(draggedCard, to: column, at: targetIndex)
            Haptics.success()
        } catch {
            print("Failed to reorder card: \(error)")
            Haptics.error()
        }

        self.draggedCard = nil
        dropTargetIndex = nil

        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

/// Handles drops at the end of a column's card list
private struct EndOfListDropDelegate: DropDelegate {
    let column: Column
    let sortedCards: [Card]

    @Binding var draggedCard: Card?
    @Binding var dropTargetIndex: Int?
    let reorderService: CardReorderService

    func dropEntered(info: DropInfo) {
        dropTargetIndex = sortedCards.count
        Haptics.selectionChanged()
    }

    func dropExited(info: DropInfo) {
        dropTargetIndex = nil
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let draggedCard else { return false }

        do {
            try reorderService.moveCard(draggedCard, to: column, at: sortedCards.count)
            Haptics.success()
        } catch {
            print("Failed to reorder card: \(error)")
            Haptics.error()
        }

        self.draggedCard = nil
        dropTargetIndex = nil

        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

#if DEBUG
#Preview("Column with cards") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Board.self, Column.self, Card.self, ChecklistItem.self,
        configurations: config
    )

    let context = container.mainContext

    let column = Column(title: "To Do", index: 0)
    let card1 = Card(
        title: "Design mockups",
        details: "Create UI mockups for the new feature",
        sortKey: 1000
    )
    let card2 = Card(
        title: "Implement backend API",
        tags: ["backend"],
        sortKey: 2000
    )
    let card3 = Card(
        title: "Write tests",
        checklist: [
            ChecklistItem(text: "Unit tests", isDone: true),
            ChecklistItem(text: "Integration tests", isDone: false),
        ],
        sortKey: 3000
    )

    card1.column = column
    card2.column = column
    card3.column = column
    column.cards = [card1, card2, card3]

    context.insert(column)

    let reorderService = CardReorderService(modelContext: context)

    return ColumnView(column: column, reorderService: reorderService)
        .frame(height: 600)
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Empty column") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Board.self, Column.self, Card.self,
        configurations: config
    )

    let context = container.mainContext
    let column = Column(title: "Done", index: 2)
    context.insert(column)

    let reorderService = CardReorderService(modelContext: context)

    return ColumnView(column: column, reorderService: reorderService)
        .frame(height: 600)
        .padding()
        .background(Color(.systemGroupedBackground))
}
#endif
