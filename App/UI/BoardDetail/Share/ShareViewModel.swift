// App/UI/BoardDetail/Share/ShareViewModel.swift
// View model for board sharing functionality

#if canImport(CloudKit) && !DEBUG
import CloudKit
import Domain
import Foundation
import SyncCloudKit

/// View model for managing board sharing
@MainActor
class ShareViewModel: ObservableObject {
    @Published var isShared: Bool = false
    @Published var participantCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var shareToPresent: CKShare?

    private let syncClient: CloudKitSyncClient
    private let boardID: BoardID

    init(syncClient: CloudKitSyncClient, boardID: BoardID) {
        self.syncClient = syncClient
        self.boardID = boardID
    }

    /// Load the sharing status for the board
    func loadSharingStatus() async {
        isLoading = true
        errorMessage = nil

        do {
            let share = try await syncClient.getShareForBoard(boardID)
            isShared = share != nil

            if isShared {
                participantCount = try await syncClient.getParticipantCount(for: boardID)
            } else {
                participantCount = 0
            }

            isLoading = false
        } catch {
            errorMessage = "Failed to load sharing status: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Start sharing the board
    func shareBoard() async {
        isLoading = true
        errorMessage = nil

        do {
            let share = try await syncClient.shareBoard(boardID)
            shareToPresent = share
            isShared = true
            await loadSharingStatus() // Reload to get participant count
        } catch {
            errorMessage = "Failed to share board: \(error.localizedDescription)"
            isLoading = false
        }
    }

    /// Stop sharing the board
    func stopSharing() async {
        isLoading = true
        errorMessage = nil

        do {
            try await syncClient.stopSharingBoard(boardID)
            isShared = false
            participantCount = 0
            isLoading = false
        } catch {
            errorMessage = "Failed to stop sharing: \(error.localizedDescription)"
            isLoading = false
        }
    }
}
#endif
