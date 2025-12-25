// SyncNoop/Sources/SyncNoop/NoopSyncClient.swift
// No-op implementation of SyncClient for Linux builds and offline mode

import Domain
import Foundation
import SyncInterfaces

/// A no-op sync client that does nothing
/// Used for Linux builds and when sync is disabled
public actor NoopSyncClient: SyncClient {
    private var _status: SyncStatus = .unavailable

    public init() {}

    public var status: SyncStatus {
        get async { _status }
    }

    public func checkAvailability() async -> Bool {
        false
    }

    public func sync() async -> SyncResult {
        .success(uploadedCount: 0, downloadedCount: 0, conflictsResolved: 0)
    }

    public func uploadBoard(_ board: Board) async throws {
        // No-op
    }

    public func uploadList(_ list: PersonalList) async throws {
        // No-op
    }

    public func uploadRecipe(_ recipe: Recipe) async throws {
        // No-op
    }

    public func deleteBoard(_ boardID: BoardID) async throws {
        // No-op
    }

    public func deleteList(_ listID: ListID) async throws {
        // No-op
    }

    public func deleteRecipe(_ recipeID: RecipeID) async throws {
        // No-op
    }
}
