import SwiftUI
import SwiftData

/// Main view for displaying a Kanban board with horizontally scrollable columns
struct BoardDetailView: View {
    let board: Board

    @Environment(\.modelContext) private var modelContext
    @State private var reorderService: CardReorderService?
    @State private var selectedCard: Card?
    @State private var showingCardDetail = false
    @State private var showingAddCard = false
    @State private var selectedColumn: Column?

    private var sortedColumns: [Column] {
        board.columns.sorted { $0.index < $1.index }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(sortedColumns) { column in
                    ColumnView(
                        column: column,
                        reorderService: reorderService ?? CardReorderService(modelContext: modelContext),
                        onCardTap: { card in
                            selectedCard = card
                            showingCardDetail = true
                        },
                        onAddCard: {
                            selectedColumn = column
                            showingAddCard = true
                        }
                    )
                }

                // Add column button
                AddColumnButton {
                    addColumn()
                }
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(board.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        addColumn()
                    } label: {
                        Label("Add Column", systemImage: "plus")
                    }

                    Button {
                        // TODO: Implement board settings
                    } label: {
                        Label("Board Settings", systemImage: "gearshape")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingCardDetail) {
            if let card = selectedCard {
                NavigationStack {
                    CardDetailPlaceholder(card: card)
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            if let column = selectedColumn {
                NavigationStack {
                    AddCardView(column: column, modelContext: modelContext) {
                        showingAddCard = false
                    }
                }
            }
        }
        .onAppear {
            if reorderService == nil {
                reorderService = CardReorderService(modelContext: modelContext)
            }
        }
    }

    private func addColumn() {
        let newColumn = Column(
            title: "New Column",
            index: sortedColumns.count
        )
        newColumn.board = board
        board.columns.append(newColumn)

        modelContext.insert(newColumn)

        do {
            try modelContext.save()
        } catch {
            print("Failed to add column: \(error)")
        }
    }
}

/// Button for adding a new column
private struct AddColumnButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.accentColor)

                Text("Add Column")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(width: 300, height: 400)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        Color.accentColor.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, dash: [5, 5])
                    )
            )
        }
        .accessibilityLabel("Add new column")
    }
}

/// Placeholder for card detail view (to be implemented in ticket #3)
private struct CardDetailPlaceholder: View {
    let card: Card

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(card.title)
                .font(.title)

            if !card.details.isEmpty {
                Text(card.details)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("Card detail view will be implemented with checklist component")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

/// Simple form for adding a new card
private struct AddCardView: View {
    let column: Column
    let modelContext: ModelContext
    let onDismiss: () -> Void

    @State private var title = ""
    @State private var details = ""

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Card Details") {
                TextField("Title", text: $title)

                TextField("Description", text: $details, axis: .vertical)
                    .lineLimit(3 ... 6)
            }
        }
        .navigationTitle("Add Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Add") {
                    addCard()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }

    private func addCard() {
        // Find the highest sortKey in the column
        let maxSortKey = column.cards.map(\.sortKey).max() ?? 0

        let newCard = Card(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            sortKey: maxSortKey + 1000
        )

        newCard.column = column
        column.cards.append(newCard)

        modelContext.insert(newCard)

        do {
            try modelContext.save()
            onDismiss()
            dismiss()
        } catch {
            print("Failed to add card: \(error)")
        }
    }
}

#if DEBUG
    #Preview("Board with multiple columns") {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Board.self, Column.self, Card.self, ChecklistItem.self,
            configurations: config
        )

        let context = container.mainContext

        let board = Board(title: "Home Tasks")

        let todoColumn = Column(title: "To Do", index: 0)
        let inProgressColumn = Column(title: "In Progress", index: 1)
        let doneColumn = Column(title: "Done", index: 2)

        let card1 = Card(title: "Buy groceries", sortKey: 1000)
        let card2 = Card(title: "Fix leaky faucet", tags: ["urgent"], sortKey: 2000)
        let card3 = Card(title: "Plan vacation", sortKey: 1000)
        let card4 = Card(
            title: "Organize garage",
            checklist: [
                ChecklistItem(text: "Sort tools", isDone: true),
                ChecklistItem(text: "Donate old items", isDone: false),
            ],
            sortKey: 1000
        )

        card1.column = todoColumn
        card2.column = todoColumn
        card3.column = inProgressColumn
        card4.column = doneColumn

        todoColumn.cards = [card1, card2]
        inProgressColumn.cards = [card3]
        doneColumn.cards = [card4]

        todoColumn.board = board
        inProgressColumn.board = board
        doneColumn.board = board

        board.columns = [todoColumn, inProgressColumn, doneColumn]

        context.insert(board)

        return NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
    }

    #Preview("Empty board") {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Board.self, Column.self, Card.self,
            configurations: config
        )

        let context = container.mainContext
        let board = Board(title: "New Board")
        context.insert(board)

        return NavigationStack {
            BoardDetailView(board: board)
                .modelContainer(container)
        }
    }
#endif
