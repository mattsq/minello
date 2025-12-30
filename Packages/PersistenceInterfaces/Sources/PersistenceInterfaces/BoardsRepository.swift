// PersistenceInterfaces/Sources/PersistenceInterfaces/BoardsRepository.swift
// Repository protocol for board, column, and card operations

import Domain
import Foundation

/// Repository for managing boards, columns, and cards
public protocol BoardsRepository: Sendable {
    // MARK: - Board Operations

    /// Creates a new board
    /// - Parameter board: The board to create
    /// - Throws: `PersistenceError` if creation fails
    func createBoard(_ board: Board) async throws

    /// Loads all boards
    /// - Returns: Array of all boards, sorted by creation date
    /// - Throws: `PersistenceError` if loading fails
    func loadBoards() async throws -> [Board]

    /// Loads a specific board by ID
    /// - Parameter id: The board ID
    /// - Returns: The board if found
    /// - Throws: `PersistenceError.notFound` if board doesn't exist
    func loadBoard(_ id: BoardID) async throws -> Board

    /// Updates an existing board
    /// - Parameter board: The board to update
    /// - Throws: `PersistenceError` if update fails or board not found
    func updateBoard(_ board: Board) async throws

    /// Deletes a board and all its columns and cards
    /// - Parameter id: The board ID
    /// - Throws: `PersistenceError` if deletion fails
    func deleteBoard(_ id: BoardID) async throws

    // MARK: - Column Operations

    /// Creates a new column
    /// - Parameter column: The column to create
    /// - Throws: `PersistenceError` if creation fails
    func createColumn(_ column: Column) async throws

    /// Loads all columns for a board
    /// - Parameter boardID: The board ID
    /// - Returns: Array of columns, sorted by index
    /// - Throws: `PersistenceError` if loading fails
    func loadColumns(for boardID: BoardID) async throws -> [Column]

    /// Loads a specific column by ID
    /// - Parameter id: The column ID
    /// - Returns: The column if found
    /// - Throws: `PersistenceError.notFound` if column doesn't exist
    func loadColumn(_ id: ColumnID) async throws -> Column

    /// Updates an existing column
    /// - Parameter column: The column to update
    /// - Throws: `PersistenceError` if update fails or column not found
    func updateColumn(_ column: Column) async throws

    /// Saves multiple columns (batch update)
    /// - Parameter columns: The columns to save
    /// - Throws: `PersistenceError` if save fails
    func saveColumns(_ columns: [Column]) async throws

    /// Deletes a column and all its cards
    /// - Parameter id: The column ID
    /// - Throws: `PersistenceError` if deletion fails
    func deleteColumn(_ id: ColumnID) async throws

    // MARK: - Card Operations

    /// Creates a new card
    /// - Parameter card: The card to create
    /// - Throws: `PersistenceError` if creation fails
    func createCard(_ card: Card) async throws

    /// Loads all cards for a column
    /// - Parameter columnID: The column ID
    /// - Returns: Array of cards, sorted by sortKey
    /// - Throws: `PersistenceError` if loading fails
    func loadCards(for columnID: ColumnID) async throws -> [Card]

    /// Loads a specific card by ID
    /// - Parameter id: The card ID
    /// - Returns: The card if found
    /// - Throws: `PersistenceError.notFound` if card doesn't exist
    func loadCard(_ id: CardID) async throws -> Card

    /// Updates an existing card
    /// - Parameter card: The card to update
    /// - Throws: `PersistenceError` if update fails or card not found
    func updateCard(_ card: Card) async throws

    /// Saves multiple cards (batch update)
    /// - Parameter cards: The cards to save
    /// - Throws: `PersistenceError` if save fails
    func saveCards(_ cards: [Card]) async throws

    /// Deletes a card
    /// - Parameter id: The card ID
    /// - Throws: `PersistenceError` if deletion fails
    func deleteCard(_ id: CardID) async throws

    // MARK: - Query Operations

    /// Searches for cards by title or details
    /// - Parameter query: The search query
    /// - Returns: Array of matching cards
    /// - Throws: `PersistenceError` if search fails
    func searchCards(query: String) async throws -> [Card]

    /// Finds cards by tag
    /// - Parameter tag: The tag to search for
    /// - Returns: Array of cards with the specified tag
    /// - Throws: `PersistenceError` if search fails
    func findCards(byTag tag: String) async throws -> [Card]

    /// Finds cards with due dates in a date range
    /// - Parameters:
    ///   - from: Start date (inclusive)
    ///   - to: End date (inclusive)
    /// - Returns: Array of cards with due dates in the range
    /// - Throws: `PersistenceError` if search fails
    func findCards(dueBetween from: Date, and to: Date) async throws -> [Card]

    // MARK: - Card-Centric Query Operations

    /// Loads a card with its attached recipe (if any)
    /// - Parameter cardID: The card ID
    /// - Returns: Tuple of the card and its optional recipe
    /// - Throws: `PersistenceError` if loading fails
    func loadCardWithRecipe(_ cardID: CardID) async throws -> (Card, Recipe?)

    /// Loads a card with its attached list (if any)
    /// - Parameter cardID: The card ID
    /// - Returns: Tuple of the card and its optional list
    /// - Throws: `PersistenceError` if loading fails
    func loadCardWithList(_ cardID: CardID) async throws -> (Card, PersonalList?)

    /// Finds all cards that have recipes attached
    /// - Parameter boardID: Optional board ID to filter by board
    /// - Returns: Array of cards with recipes attached
    /// - Throws: `PersistenceError` if search fails
    func findCardsWithRecipes(boardID: BoardID?) async throws -> [Card]

    /// Finds all cards that have lists attached
    /// - Parameter boardID: Optional board ID to filter by board
    /// - Returns: Array of cards with lists attached
    /// - Throws: `PersistenceError` if search fails
    func findCardsWithLists(boardID: BoardID?) async throws -> [Card]
}
