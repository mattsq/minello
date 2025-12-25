// SyncInterfaces/Sources/SyncInterfaces/SyncClient.swift
// Sync protocol for HomeCooked

import Domain
import Foundation

/// Status of the sync operation
public enum SyncStatus: Equatable, Sendable {
    /// Sync is idle (not running)
    case idle
    /// Sync is in progress
    case syncing
    /// Sync completed successfully
    case success(syncedAt: Date)
    /// Sync failed with an error
    case failed(error: String)
    /// Sync is not available (e.g., user not logged in)
    case unavailable
}

/// Result of a sync operation
public enum SyncResult: Equatable, Sendable {
    /// Sync completed successfully
    case success(uploadedCount: Int, downloadedCount: Int, conflictsResolved: Int)
    /// Sync failed
    case failure(error: String)
}

/// Protocol for sync clients (CloudKit, etc.)
public protocol SyncClient: Sendable {
    /// Current sync status
    var status: SyncStatus { get async }

    /// Check if sync is available (e.g., user is logged in to iCloud)
    func checkAvailability() async -> Bool

    /// Perform a sync operation
    /// - Returns: Result of the sync operation
    func sync() async -> SyncResult

    /// Upload a board and its children to the remote
    /// - Parameter board: The board to upload
    func uploadBoard(_ board: Board) async throws

    /// Upload a list to the remote
    /// - Parameter list: The list to upload
    func uploadList(_ list: PersonalList) async throws

    /// Upload a recipe to the remote
    /// - Parameter recipe: The recipe to upload
    func uploadRecipe(_ recipe: Recipe) async throws

    /// Delete a board from the remote
    /// - Parameter boardID: The ID of the board to delete
    func deleteBoard(_ boardID: BoardID) async throws

    /// Delete a list from the remote
    /// - Parameter listID: The ID of the list to delete
    func deleteList(_ listID: ListID) async throws

    /// Delete a recipe from the remote
    /// - Parameter recipeID: The ID of the recipe to delete
    func deleteRecipe(_ recipeID: RecipeID) async throws
}

/// Observer protocol for sync status changes
public protocol SyncStatusObserver: AnyObject {
    /// Called when sync status changes
    /// - Parameter status: The new sync status
    func syncStatusDidChange(_ status: SyncStatus)
}
