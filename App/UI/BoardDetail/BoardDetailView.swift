// App/UI/BoardDetail/BoardDetailView.swift
// Board detail view showing horizontal columns

import SwiftUI
import Domain

/// Detail view for a board showing columns horizontally
struct BoardDetailView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    let board: Board

    @State private var columns: [Column] = []
    @State private var cardsByColumn: [ColumnID: [Card]] = [:]
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAddColumn = false
    @State private var newColumnTitle = ""

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading board...")
                    .accessibilityLabel("Loading board")
            } else if let error = errorMessage {
                ContentUnavailableView {
                    Label("Error Loading Board", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") {
                        Task { await loadBoardData() }
                    }
                    .accessibilityLabel("Retry loading board")
                }
            } else if columns.isEmpty {
                ContentUnavailableView {
                    Label("No Columns", systemImage: "rectangle.stack")
                } description: {
                    Text("Add your first column to start organizing tasks")
                } actions: {
                    Button("Add Column") {
                        showingAddColumn = true
                    }
                    .accessibilityLabel("Add new column")
                }
            } else {
                columnsScrollView
            }
        }
        .navigationTitle(board.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddColumn = true
                } label: {
                    Label("Add Column", systemImage: "plus")
                }
                .accessibilityLabel("Add new column")
            }
        }
        .alert("New Column", isPresented: $showingAddColumn) {
            TextField("Column Title", text: $newColumnTitle)
                .accessibilityLabel("Column title")
            Button("Cancel", role: .cancel) {
                newColumnTitle = ""
            }
            Button("Create") {
                Task { await createColumn() }
            }
            .disabled(newColumnTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("Enter a title for your new column")
        }
        .task {
            await loadBoardData()
        }
    }

    private var columnsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(columns, id: \.id) { column in
                    ColumnView(
                        column: column,
                        cards: cardsByColumn[column.id] ?? [],
                        onRefresh: {
                            await loadBoardData()
                        }
                    )
                    .frame(width: 300)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Column: \(column.title)")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .refreshable {
            await loadBoardData()
        }
    }

    // MARK: - Actions

    private func loadBoardData() async {
        isLoading = true
        errorMessage = nil

        do {
            let repo = dependencies.repositoryProvider.boardsRepository

            // Load columns for this board
            let loadedColumns = try await repo.loadColumns(for: board.id)
            columns = loadedColumns.sorted { $0.index < $1.index }

            // Load cards for each column
            var newCardsByColumn: [ColumnID: [Card]] = [:]
            for column in columns {
                let cards = try await repo.loadCards(for: column.id)
                newCardsByColumn[column.id] = cards.sorted { $0.sortKey < $1.sortKey }
            }
            cardsByColumn = newCardsByColumn

            isLoading = false
        } catch {
            errorMessage = "Failed to load board data: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func createColumn() async {
        let title = newColumnTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        let nextIndex = columns.map(\.index).max().map { $0 + 1 } ?? 0
        let column = Column(
            board: board.id,
            title: title,
            index: nextIndex
        )
        newColumnTitle = ""

        do {
            try await dependencies.repositoryProvider.boardsRepository.createColumn(column)
            await loadBoardData()
        } catch {
            errorMessage = "Failed to create column: \(error.localizedDescription)"
        }
    }
}

// MARK: - Previews

#Preview("With Columns") {
    let container = try! AppDependencyContainer.preview()

    Task { @MainActor in
        let repo = container.repositoryProvider.boardsRepository
        let board = Board(title: "Home Projects")
        try? await repo.createBoard(board)

        let col1 = Column(board: board.id, title: "To Do", index: 0)
        let col2 = Column(board: board.id, title: "In Progress", index: 1)
        let col3 = Column(board: board.id, title: "Done", index: 2)

        try? await repo.createColumn(col1)
        try? await repo.createColumn(col2)
        try? await repo.createColumn(col3)

        let card1 = Card(column: col1.id, title: "Fix leaky faucet", sortKey: 0)
        let card2 = Card(column: col1.id, title: "Paint bedroom", sortKey: 1)
        let card3 = Card(column: col2.id, title: "Install shelves", sortKey: 0)

        try? await repo.createCard(card1)
        try? await repo.createCard(card2)
        try? await repo.createCard(card3)
    }

    return NavigationStack {
        BoardDetailView(board: Board(id: BoardID(), title: "Home Projects"))
            .withDependencies(container)
    }
}

#Preview("Empty Board") {
    let container = try! AppDependencyContainer.preview()

    Task { @MainActor in
        let repo = container.repositoryProvider.boardsRepository
        let board = Board(title: "Empty Board")
        try? await repo.createBoard(board)
    }

    return NavigationStack {
        BoardDetailView(board: Board(id: BoardID(), title: "Empty Board"))
            .withDependencies(container)
    }
}
