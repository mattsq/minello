// PersistenceInterfaces/Sources/PersistenceInterfaces/SearchRepository.swift
// Repository protocol for card-centric search and filtering operations

import Domain
import Foundation

// MARK: - Supporting Types

/// Filter options for card search
public struct CardFilter: Sendable {
    /// Optional text to search in title/details
    public var text: String?
    /// Filter to cards with recipes attached
    public var hasRecipe: Bool?
    /// Filter to cards with lists attached
    public var hasList: Bool?
    /// Filter by tag
    public var tag: String?
    /// Filter by due date range
    public var dueDateRange: (from: Date, to: Date)?
    /// Optional board ID to limit search
    public var boardID: BoardID?

    public init(
        text: String? = nil,
        hasRecipe: Bool? = nil,
        hasList: Bool? = nil,
        tag: String? = nil,
        dueDateRange: (from: Date, to: Date)? = nil,
        boardID: BoardID? = nil
    ) {
        self.text = text
        self.hasRecipe = hasRecipe
        self.hasList = hasList
        self.tag = tag
        self.dueDateRange = dueDateRange
        self.boardID = boardID
    }
}

/// Search result containing card with context information
public struct CardSearchResult: Sendable, Equatable {
    /// The card that matched the search
    public let card: Card
    /// The column containing the card
    public let column: Column
    /// The board containing the card
    public let board: Board
    /// Whether the card has a recipe attached
    public let hasRecipe: Bool
    /// Whether the card has a list attached
    public let hasList: Bool

    public init(
        card: Card,
        column: Column,
        board: Board,
        hasRecipe: Bool,
        hasList: Bool
    ) {
        self.card = card
        self.column = column
        self.board = board
        self.hasRecipe = hasRecipe
        self.hasList = hasList
    }
}

// MARK: - Repository Protocol

/// Repository for searching and filtering cards
public protocol SearchRepository: Sendable {
    // MARK: - Card Search Operations

    /// Searches for cards by text in title or details
    /// - Parameter query: The search text
    /// - Returns: Array of cards matching the query
    /// - Throws: `PersistenceError` if search fails
    func searchCardsByText(_ query: String) async throws -> [Card]

    /// Finds cards that have a recipe attached
    /// - Parameter boardID: Optional board ID to filter by specific board
    /// - Returns: Array of cards with recipes
    /// - Throws: `PersistenceError` if search fails
    func findCardsWithRecipe(boardID: BoardID?) async throws -> [Card]

    /// Finds cards that have a list attached
    /// - Parameter boardID: Optional board ID to filter by specific board
    /// - Returns: Array of cards with lists
    /// - Throws: `PersistenceError` if search fails
    func findCardsWithList(boardID: BoardID?) async throws -> [Card]

    /// Finds cards by tag
    /// - Parameters:
    ///   - tag: The tag to search for
    ///   - boardID: Optional board ID to filter by specific board
    /// - Returns: Array of cards with the specified tag
    /// - Throws: `PersistenceError` if search fails
    func findCardsByTag(_ tag: String, boardID: BoardID?) async throws -> [Card]

    /// Finds cards with due dates in a date range
    /// - Parameters:
    ///   - from: Start date (inclusive)
    ///   - to: End date (inclusive)
    ///   - boardID: Optional board ID to filter by specific board
    /// - Returns: Array of cards with due dates in the range
    /// - Throws: `PersistenceError` if search fails
    func findCardsByDueDate(from: Date, to: Date, boardID: BoardID?) async throws -> [Card]

    // MARK: - Advanced Filtering

    /// Searches for cards with advanced filtering options
    /// Returns results with full context (board → column → card)
    /// - Parameter filter: The filter criteria
    /// - Returns: Array of search results with context
    /// - Throws: `PersistenceError` if search fails
    func searchCards(filter: CardFilter) async throws -> [CardSearchResult]
}
