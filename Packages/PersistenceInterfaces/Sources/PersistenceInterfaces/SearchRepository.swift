// PersistenceInterfaces/Sources/PersistenceInterfaces/SearchRepository.swift
// Repository protocol for unified search across all entity types

import Domain
import Foundation

/// Repository for unified search across boards, cards, lists, and recipes
public protocol SearchRepository: Sendable {
    // MARK: - Unified Search

    /// Searches across all entity types
    /// - Parameters:
    ///   - query: The search query
    ///   - filters: Optional entity types to filter results (if nil, searches all types)
    /// - Returns: Array of search results grouped by relevance
    /// - Throws: `PersistenceError` if search fails
    func search(query: String, filters: Set<EntityType>?) async throws -> [SearchResult]

    // MARK: - Entity-Specific Search

    /// Searches for boards by title
    /// - Parameter query: The search query
    /// - Returns: Array of matching boards
    /// - Throws: `PersistenceError` if search fails
    func searchBoards(query: String) async throws -> [Board]

    /// Searches for cards by title or details
    /// - Parameter query: The search query
    /// - Returns: Array of matching cards
    /// - Throws: `PersistenceError` if search fails
    func searchCards(query: String) async throws -> [Card]

    /// Searches for lists by title
    /// - Parameter query: The search query
    /// - Returns: Array of matching lists
    /// - Throws: `PersistenceError` if search fails
    func searchLists(query: String) async throws -> [PersonalList]

    /// Searches for recipes by title or method
    /// - Parameter query: The search query
    /// - Returns: Array of matching recipes
    /// - Throws: `PersistenceError` if search fails
    func searchRecipes(query: String) async throws -> [Recipe]

    // MARK: - Tag Search

    /// Searches for cards and recipes by tag
    /// - Parameter tag: The tag to search for
    /// - Returns: Array of search results (cards and recipes)
    /// - Throws: `PersistenceError` if search fails
    func searchByTag(_ tag: String) async throws -> [SearchResult]

    // MARK: - Date Range Search

    /// Finds cards with due dates in a date range
    /// - Parameters:
    ///   - from: Start date (inclusive)
    ///   - to: End date (inclusive)
    /// - Returns: Array of cards with due dates in the range
    /// - Throws: `PersistenceError` if search fails
    func findCardsDue(from: Date, to: Date) async throws -> [Card]

    // MARK: - Recent Searches

    /// Saves a search query to recent searches
    /// - Parameter query: The search query to save
    /// - Throws: `PersistenceError` if save fails
    func saveRecentSearch(_ query: String) async throws

    /// Loads recent search queries
    /// - Parameter limit: Maximum number of recent searches to return (default 10)
    /// - Returns: Array of recent search queries, most recent first
    /// - Throws: `PersistenceError` if loading fails
    func loadRecentSearches(limit: Int) async throws -> [String]

    /// Clears all recent searches
    /// - Throws: `PersistenceError` if clearing fails
    func clearRecentSearches() async throws
}
