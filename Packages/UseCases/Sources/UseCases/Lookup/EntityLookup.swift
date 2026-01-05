// UseCases/Sources/UseCases/Lookup/EntityLookup.swift
// Entity lookup service for finding boards, columns, and lists by name

import Domain
import Foundation

/// Result of a board lookup operation
public struct BoardLookupResult: Equatable, Sendable {
    public let board: Board
    public let score: Double

    public init(board: Board, score: Double) {
        self.board = board
        self.score = score
    }
}

/// Result of a column lookup operation
public struct ColumnLookupResult: Equatable, Sendable {
    public let column: Column
    public let board: Board
    public let score: Double

    public init(column: Column, board: Board, score: Double) {
        self.column = column
        self.board = board
        self.score = score
    }
}

/// Result of a list lookup operation
public struct ListLookupResult: Equatable, Sendable {
    public let list: PersonalList
    public let score: Double

    public init(list: PersonalList, score: Double) {
        self.list = list
        self.score = score
    }
}

/// Result of a card lookup operation
public struct CardLookupResult: Equatable, Sendable {
    public let card: Card
    public let column: Column
    public let board: Board
    public let score: Double

    public init(card: Card, column: Column, board: Board, score: Double) {
        self.card = card
        self.column = column
        self.board = board
        self.score = score
    }
}

/// Service for looking up entities (boards, columns, lists) by name
public enum EntityLookup {

    // MARK: - Board Lookup

    /// Find boards by name using fuzzy matching
    /// - Parameters:
    ///   - query: The search query
    ///   - boards: Available boards
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: Array of board lookup results sorted by score (best match first)
    public static func findBoards(
        query: String,
        in boards: [Board],
        threshold: Double = 0.5
    ) -> [BoardLookupResult] {
        boards.map { board in
            BoardLookupResult(
                board: board,
                score: FuzzyMatcher.similarity(query: query, target: board.title)
            )
        }
        .filter { $0.score >= threshold }
        .sorted { $0.score > $1.score }
    }

    /// Find the best matching board by name
    /// - Parameters:
    ///   - query: The search query
    ///   - boards: Available boards
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: The best matching board, or nil if no match above threshold
    public static func findBestBoard(
        query: String,
        in boards: [Board],
        threshold: Double = 0.5
    ) -> Board? {
        findBoards(query: query, in: boards, threshold: threshold).first?.board
    }

    // MARK: - Column Lookup

    /// Find columns by name using fuzzy matching
    /// - Parameters:
    ///   - query: The search query
    ///   - columns: Available columns
    ///   - boards: Available boards (for context)
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: Array of column lookup results sorted by score (best match first)
    public static func findColumns(
        query: String,
        in columns: [Column],
        boards: [Board],
        threshold: Double = 0.5
    ) -> [ColumnLookupResult] {
        let boardsDict = Dictionary(uniqueKeysWithValues: boards.map { ($0.id, $0) })

        return columns.compactMap { column in
            guard let board = boardsDict[column.board] else { return nil }
            let score = FuzzyMatcher.similarity(query: query, target: column.title)
            return ColumnLookupResult(column: column, board: board, score: score)
        }
        .filter { $0.score >= threshold }
        .sorted { $0.score > $1.score }
    }

    /// Find the best matching column by name
    /// - Parameters:
    ///   - query: The search query
    ///   - columns: Available columns
    ///   - boards: Available boards (for context)
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: The best matching column result, or nil if no match above threshold
    public static func findBestColumn(
        query: String,
        in columns: [Column],
        boards: [Board],
        threshold: Double = 0.5
    ) -> ColumnLookupResult? {
        findColumns(query: query, in: columns, boards: boards, threshold: threshold).first
    }

    /// Find columns within a specific board
    /// - Parameters:
    ///   - query: The search query
    ///   - board: The board to search within
    ///   - columns: Available columns
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: Array of column lookup results for the specified board
    public static func findColumns(
        query: String,
        inBoard board: Board,
        columns: [Column],
        threshold: Double = 0.5
    ) -> [ColumnLookupResult] {
        columns
            .filter { $0.board == board.id }
            .map { column in
                ColumnLookupResult(
                    column: column,
                    board: board,
                    score: FuzzyMatcher.similarity(query: query, target: column.title)
                )
            }
            .filter { $0.score >= threshold }
            .sorted { $0.score > $1.score }
    }

    // MARK: - List Lookup

    /// Find personal lists by name using fuzzy matching
    /// - Parameters:
    ///   - query: The search query
    ///   - lists: Available lists
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: Array of list lookup results sorted by score (best match first)
    public static func findLists(
        query: String,
        in lists: [PersonalList],
        threshold: Double = 0.5
    ) -> [ListLookupResult] {
        lists.map { list in
            ListLookupResult(
                list: list,
                score: FuzzyMatcher.similarity(query: query, target: list.title)
            )
        }
        .filter { $0.score >= threshold }
        .sorted { $0.score > $1.score }
    }

    /// Find the best matching list by name
    /// - Parameters:
    ///   - query: The search query
    ///   - lists: Available lists
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: The best matching list, or nil if no match above threshold
    public static func findBestList(
        query: String,
        in lists: [PersonalList],
        threshold: Double = 0.5
    ) -> PersonalList? {
        findLists(query: query, in: lists, threshold: threshold).first?.list
    }

    // MARK: - Card Lookup

    /// Find cards within a specific board using fuzzy matching
    /// - Parameters:
    ///   - query: The search query
    ///   - board: The board to search within
    ///   - columns: Available columns
    ///   - cards: Available cards
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: Array of card lookup results for the specified board
    public static func findCards(
        query: String,
        inBoard board: Board,
        columns: [Column],
        cards: [Card],
        threshold: Double = 0.5
    ) -> [CardLookupResult] {
        let columnsDict = Dictionary(uniqueKeysWithValues: columns.map { ($0.id, $0) })
        let boardColumnIDs = Set(columns.filter { $0.board == board.id }.map { $0.id })

        return cards.compactMap { card in
            // Only include cards that belong to columns in this board
            guard boardColumnIDs.contains(card.column),
                  let column = columnsDict[card.column] else {
                return nil
            }
            let score = FuzzyMatcher.similarity(query: query, target: card.title)
            return CardLookupResult(card: card, column: column, board: board, score: score)
        }
        .filter { $0.score >= threshold }
        .sorted { $0.score > $1.score }
    }

    /// Find the best matching card within a specific board
    /// - Parameters:
    ///   - query: The search query
    ///   - board: The board to search within
    ///   - columns: Available columns
    ///   - cards: Available cards
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: The best matching card result, or nil if no match above threshold
    public static func findBestCard(
        query: String,
        inBoard board: Board,
        columns: [Column],
        cards: [Card],
        threshold: Double = 0.5
    ) -> CardLookupResult? {
        findCards(query: query, inBoard: board, columns: columns, cards: cards, threshold: threshold).first
    }
}
