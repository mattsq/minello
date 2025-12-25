// App/UI/Boards/BoardsListView.swift
// Main view showing list of all boards

import SwiftUI
import Domain

/// Main view displaying all boards with navigation
struct BoardsListView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @State private var boards: [Board] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAddBoard = false
    @State private var newBoardTitle = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading boards...")
                        .accessibilityLabel("Loading boards")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("Error Loading Boards", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await loadBoards() }
                        }
                        .accessibilityLabel("Retry loading boards")
                    }
                } else if boards.isEmpty {
                    ContentUnavailableView {
                        Label("No Boards", systemImage: "rectangle.stack")
                    } description: {
                        Text("Create your first board to get started")
                    } actions: {
                        Button("Add Board") {
                            showingAddBoard = true
                        }
                        .accessibilityLabel("Add new board")
                    }
                } else {
                    boardsList
                }
            }
            .navigationTitle("Boards")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddBoard = true
                    } label: {
                        Label("Add Board", systemImage: "plus")
                    }
                    .accessibilityLabel("Add new board")
                }
            }
            .alert("New Board", isPresented: $showingAddBoard) {
                TextField("Board Title", text: $newBoardTitle)
                    .accessibilityLabel("Board title")
                Button("Cancel", role: .cancel) {
                    newBoardTitle = ""
                }
                Button("Create") {
                    Task { await createBoard() }
                }
                .disabled(newBoardTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text("Enter a title for your new board")
            }
        }
        .task {
            await loadBoards()
        }
    }

    private var boardsList: some View {
        List {
            ForEach(boards, id: \.id) { board in
                NavigationLink(value: board) {
                    BoardRow(board: board)
                }
                .accessibilityLabel("Board: \(board.title)")
            }
            .onDelete(perform: deleteBoards)
        }
        .navigationDestination(for: Board.self) { board in
            BoardDetailView(board: board)
        }
        .refreshable {
            await loadBoards()
        }
    }

    // MARK: - Actions

    private func loadBoards() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedBoards = try await dependencies.repositoryProvider.boardsRepository.loadBoards()
            boards = loadedBoards.sorted { $0.createdAt > $1.createdAt }
            isLoading = false
        } catch {
            errorMessage = "Failed to load boards: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func createBoard() async {
        let title = newBoardTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        let board = Board(title: title)
        newBoardTitle = ""

        do {
            try await dependencies.repositoryProvider.boardsRepository.createBoard(board)
            await loadBoards()
        } catch {
            errorMessage = "Failed to create board: \(error.localizedDescription)"
        }
    }

    private func deleteBoards(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let board = boards[index]
                do {
                    try await dependencies.repositoryProvider.boardsRepository.deleteBoard(board.id)
                } catch {
                    errorMessage = "Failed to delete board: \(error.localizedDescription)"
                }
            }
            await loadBoards()
        }
    }
}

// MARK: - Board Row

private struct BoardRow: View {
    let board: Board

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(board.title)
                .font(.headline)

            HStack {
                Label("\(board.columns.count)", systemImage: "rectangle.stack")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(board.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview("With Boards") {
    let container = try! AppDependencyContainer.preview()

    // Add sample boards
    Task { @MainActor in
        let repo = container.repositoryProvider.boardsRepository
        try? await repo.createBoard(Board(title: "Home"))
        try? await repo.createBoard(Board(title: "Work"))
        try? await repo.createBoard(Board(title: "Personal Projects"))
    }

    return BoardsListView()
        .withDependencies(container)
}

#Preview("Empty State") {
    let container = try! AppDependencyContainer.preview()
    return BoardsListView()
        .withDependencies(container)
}
