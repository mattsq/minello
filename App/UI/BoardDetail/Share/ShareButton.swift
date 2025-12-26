// App/UI/BoardDetail/Share/ShareButton.swift
// Button component for board sharing with "Shared" pill badge

#if canImport(CloudKit)
import CloudKit
import SwiftUI
import Domain
import PersistenceInterfaces

/// Button for managing board sharing, displays a "Shared" pill when active
struct ShareButton: View {
    @StateObject private var viewModel: ShareViewModel
    @State private var showingShareSheet = false
    @State private var showingStopSharingConfirmation = false

    init(viewModel: ShareViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading sharing status")
            } else if viewModel.isShared {
                sharedPill
            } else {
                shareButton
            }
        }
        .task {
            await viewModel.loadSharingStatus()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let share = viewModel.shareToPresent {
                CloudSharingView(share: share, container: CKContainer.default())
            }
        }
        .alert("Stop Sharing?", isPresented: $showingStopSharingConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Stop Sharing", role: .destructive) {
                Task {
                    await viewModel.stopSharing()
                }
            }
        } message: {
            Text("This board will no longer be shared with other users.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }

    private var shareButton: some View {
        Button {
            Task {
                await viewModel.shareBoard()
                showingShareSheet = true
            }
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
        }
        .accessibilityLabel("Share board")
    }

    private var sharedPill: some View {
        Menu {
            Button {
                Task {
                    await viewModel.shareBoard()
                    showingShareSheet = true
                }
            } label: {
                Label("Manage Sharing", systemImage: "person.2")
            }

            Divider()

            Button(role: .destructive) {
                showingStopSharingConfirmation = true
            } label: {
                Label("Stop Sharing", systemImage: "xmark.circle")
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                Text("Shared")
                    .font(.caption.weight(.medium))
                if viewModel.participantCount > 0 {
                    Text("(\(viewModel.participantCount))")
                        .font(.caption2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
        }
        .accessibilityLabel("Board is shared with \(viewModel.participantCount) participants. Tap to manage sharing.")
    }
}

/// Wrapper for CloudKit sharing UI
struct CloudSharingView: UIViewControllerRepresentable {
    let share: CKShare
    let container: CKContainer

    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        return controller
    }

    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {
        // No updates needed
    }
}

// MARK: - Previews

#Preview("Not Shared") {
    struct PreviewWrapper: View {
        var body: some View {
            let mockClient = CloudKitSyncClient(
                containerIdentifier: "iCloud.com.example.HomeCooked",
                boardsRepo: MockBoardsRepository(),
                listsRepo: MockListsRepository(),
                recipesRepo: MockRecipesRepository()
            )
            let viewModel = ShareViewModel(
                syncClient: mockClient,
                boardID: BoardID()
            )
            return ShareButton(viewModel: viewModel)
        }
    }

    return PreviewWrapper()
}

// Mock repositories for preview
private class MockBoardsRepository: @unchecked Sendable, BoardsRepository {
    func createBoard(_ board: Board) async throws {}
    func loadBoards() async throws -> [Board] { [] }
    func loadBoard(_ id: BoardID) async throws -> Board? { nil }
    func updateBoard(_ board: Board) async throws {}
    func deleteBoard(_ id: BoardID) async throws {}
    func createColumn(_ column: Column) async throws {}
    func loadColumns(for boardID: BoardID) async throws -> [Column] { [] }
    func saveColumns(_ columns: [Column]) async throws {}
    func deleteColumn(_ id: ColumnID) async throws {}
    func createCard(_ card: Card) async throws {}
    func loadCards(for columnID: ColumnID) async throws -> [Card] { [] }
    func saveCards(_ cards: [Card]) async throws {}
    func deleteCard(_ id: CardID) async throws {}
}

private class MockListsRepository: @unchecked Sendable, ListsRepository {
    func createList(_ list: PersonalList) async throws {}
    func loadLists() async throws -> [PersonalList] { [] }
    func loadList(_ id: ListID) async throws -> PersonalList? { nil }
    func updateList(_ list: PersonalList) async throws {}
    func deleteList(_ id: ListID) async throws {}
}

private class MockRecipesRepository: @unchecked Sendable, RecipesRepository {
    func createRecipe(_ recipe: Recipe) async throws {}
    func loadRecipes() async throws -> [Recipe] { [] }
    func loadRecipe(_ id: RecipeID) async throws -> Recipe? { nil }
    func updateRecipe(_ recipe: Recipe) async throws {}
    func deleteRecipe(_ id: RecipeID) async throws {}
}
#endif
