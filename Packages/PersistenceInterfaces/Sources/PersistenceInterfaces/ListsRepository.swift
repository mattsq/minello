// PersistenceInterfaces/Sources/PersistenceInterfaces/ListsRepository.swift
// Repository protocol for personal list operations

import Domain
import Foundation

/// Repository for managing personal lists (grocery, packing, etc.)
public protocol ListsRepository: Sendable {
    // MARK: - List Operations

    /// Creates a new personal list
    /// - Parameter list: The list to create
    /// - Throws: `PersistenceError` if creation fails
    func createList(_ list: PersonalList) async throws

    /// Loads all personal lists
    /// - Returns: Array of all lists, sorted by creation date
    /// - Throws: `PersistenceError` if loading fails
    func loadLists() async throws -> [PersonalList]

    /// Loads a specific list by ID
    /// - Parameter id: The list ID
    /// - Returns: The list if found
    /// - Throws: `PersistenceError.notFound` if list doesn't exist
    func loadList(_ id: ListID) async throws -> PersonalList

    /// Updates an existing list
    /// - Parameter list: The list to update
    /// - Throws: `PersistenceError` if update fails or list not found
    func updateList(_ list: PersonalList) async throws

    /// Deletes a list
    /// - Parameter id: The list ID
    /// - Throws: `PersistenceError` if deletion fails
    func deleteList(_ id: ListID) async throws

    // MARK: - Query Operations

    /// Searches for lists by title
    /// - Parameter query: The search query
    /// - Returns: Array of matching lists
    /// - Throws: `PersistenceError` if search fails
    func searchLists(query: String) async throws -> [PersonalList]

    /// Finds lists with incomplete items
    /// - Returns: Array of lists that have at least one incomplete item
    /// - Throws: `PersistenceError` if search fails
    func findListsWithIncompleteItems() async throws -> [PersonalList]
}
