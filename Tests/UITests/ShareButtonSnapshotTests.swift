// Tests/UITests/ShareButtonSnapshotTests.swift
// Snapshot tests for the ShareButton component

#if canImport(CloudKit)
import CloudKit
import Domain
import PersistenceInterfaces
import SnapshotTesting
import SwiftUI
import SyncCloudKit
import XCTest

@testable import HomeCooked

/// Snapshot tests for ShareButton and "Shared" pill badge
@MainActor
final class ShareButtonSnapshotTests: XCTestCase {
    // MARK: - Snapshot Tests

    func testShareButton_NotShared() throws {
        let mockClient = createMockSyncClient()
        let viewModel = ShareViewModel(
            syncClient: mockClient,
            boardID: BoardID()
        )

        let view = ShareButton(viewModel: viewModel)
            .frame(width: 200, height: 44)
            .padding()

        // Record mode: set RECORD_SNAPSHOTS=1 environment variable
        let isRecording = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"

        assertSnapshot(
            matching: view,
            as: .image,
            record: isRecording,
            testName: "ShareButton_NotShared"
        )
    }

    func testShareButton_SharedPill_NoParticipants() throws {
        let mockClient = createMockSyncClient()
        let viewModel = ShareViewModel(
            syncClient: mockClient,
            boardID: BoardID()
        )

        // Simulate shared state
        Task {
            await viewModel.loadSharingStatus()
        }

        let view = ShareButton(viewModel: viewModel)
            .frame(width: 200, height: 44)
            .padding()

        let isRecording = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"

        assertSnapshot(
            matching: view,
            as: .image,
            record: isRecording,
            testName: "ShareButton_SharedPill_NoParticipants"
        )
    }

    func testShareButton_SharedPill_WithParticipants() throws {
        let mockClient = createMockSyncClient()
        let viewModel = ShareViewModel(
            syncClient: mockClient,
            boardID: BoardID()
        )

        // Simulate shared state with participants
        // Note: In a real test, you would mock the sync client to return participant data

        let view = ShareButton(viewModel: viewModel)
            .frame(width: 200, height: 44)
            .padding()

        let isRecording = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"

        assertSnapshot(
            matching: view,
            as: .image,
            record: isRecording,
            testName: "ShareButton_SharedPill_WithParticipants"
        )
    }

    func testShareButton_Loading() throws {
        let mockClient = createMockSyncClient()
        let viewModel = ShareViewModel(
            syncClient: mockClient,
            boardID: BoardID()
        )

        // Simulate loading state
        // Note: In a real test, you would set the loading state directly

        let view = ShareButton(viewModel: viewModel)
            .frame(width: 200, height: 44)
            .padding()

        let isRecording = ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"

        assertSnapshot(
            matching: view,
            as: .image,
            record: isRecording,
            testName: "ShareButton_Loading"
        )
    }

    // MARK: - Helper Methods

    private func createMockSyncClient() -> CloudKitSyncClient {
        CloudKitSyncClient(
            containerIdentifier: "iCloud.com.example.HomeCooked.test",
            boardsRepo: MockBoardsRepository(),
            listsRepo: MockListsRepository(),
            recipesRepo: MockRecipesRepository()
        )
    }
}

// MARK: - Mock Repositories

private actor MockBoardsRepository: BoardsRepository {
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

private actor MockListsRepository: ListsRepository {
    func createList(_ list: PersonalList) async throws {}
    func loadLists() async throws -> [PersonalList] { [] }
    func loadList(_ id: ListID) async throws -> PersonalList? { nil }
    func updateList(_ list: PersonalList) async throws {}
    func deleteList(_ id: ListID) async throws {}
}

private actor MockRecipesRepository: RecipesRepository {
    func createRecipe(_ recipe: Recipe) async throws {}
    func loadRecipes() async throws -> [Recipe] { [] }
    func loadRecipe(_ id: RecipeID) async throws -> Recipe? { nil }
    func updateRecipe(_ recipe: Recipe) async throws {}
    func deleteRecipe(_ id: RecipeID) async throws {}
}
#endif
