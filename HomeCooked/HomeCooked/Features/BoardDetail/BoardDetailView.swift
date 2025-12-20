import SwiftUI
import SwiftData

/// Main board view with horizontally scrollable columns and drag-and-drop support
struct BoardDetailView: View {
    let board: Board

    @Environment(\.modelContext) private var modelContext
    @State private var draggingCard: Card?
    @State private var selectedCard: Card?
    @State private var showCardDetail = false
    @State private var errorMessage: String?

    private var reorderService: CardReorderService {
        CardReorderService(modelContext: modelContext)
    }

    private var sortedColumns: [Column] {
        board.columns.sorted { $0.index < $1.index }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(sortedColumns) { column in
                    ColumnView(
                        column: column,
                        draggingCard: $draggingCard,
                        onCardTap: { card in
                            selectedCard = card
                            showCardDetail = true
                        },
                        onCardMove: { card, targetIndex, targetColumn in
                            handleCardMove(
                                card: card,
                                targetIndex: targetIndex,
                                targetColumn: targetColumn
                            )
                        }
                    )
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(board.title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCardDetail) {
            if let card = selectedCard {
                CardDetailPlaceholder(card: card)
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func handleCardMove(card: Card, targetIndex: Int, targetColumn: Column) {
        Task { @MainActor in
            do {
                if let currentColumn = card.column, currentColumn.id == targetColumn.id {
                    // Reorder within same column
                    let sortedCards = currentColumn.cards.sorted { $0.sortKey < $1.sortKey }
                    if let fromIndex = sortedCards.firstIndex(where: { $0.id == card.id }) {
                        try await reorderService.reorderWithinColumn(
                            card: card,
                            fromIndex: fromIndex,
                            toIndex: targetIndex,
                            inColumn: currentColumn
                        )
                    }
                } else if let fromColumn = card.column {
                    // Move to different column
                    try await reorderService.moveToColumn(
                        card: card,
                        fromColumn: fromColumn,
                        toColumn: targetColumn,
                        atIndex: targetIndex
                    )
                }
            } catch {
                errorMessage = "Failed to move card: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Placeholder Views

/// Placeholder for card detail view (to be implemented in future ticket)
private struct CardDetailPlaceholder: View {
    let card: Card
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Card Detail View")
                    .font(.title)

                Text(card.title)
                    .font(.headline)

                Text("This view will be implemented in a future ticket")
                    .font(.body)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview("Board with Columns") {
        NavigationStack {
            let board = Board(
                title: "Family Board",
                columns: [
                    Column(
                        title: "To Do",
                        index: 0,
                        cards: [
                            Card(title: "Buy groceries", sortKey: 0),
                            Card(title: "Call plumber", sortKey: 1),
                            Card(title: "Pay bills", sortKey: 2),
                        ]
                    ),
                    Column(
                        title: "In Progress",
                        index: 1,
                        cards: [
                            Card(title: "Fix leaky faucet", sortKey: 0),
                        ]
                    ),
                    Column(
                        title: "Done",
                        index: 2,
                        cards: [
                            Card(title: "Take out trash", sortKey: 0),
                            Card(title: "Water plants", sortKey: 1),
                        ]
                    ),
                ]
            )

            BoardDetailView(board: board)
                .modelContainer(for: [Board.self, Column.self, Card.self])
        }
    }

    #Preview("Empty Board") {
        NavigationStack {
            let board = Board(
                title: "New Board",
                columns: [
                    Column(title: "To Do", index: 0),
                    Column(title: "In Progress", index: 1),
                    Column(title: "Done", index: 2),
                ]
            )

            BoardDetailView(board: board)
                .modelContainer(for: [Board.self, Column.self, Card.self])
        }
    }
#endif
