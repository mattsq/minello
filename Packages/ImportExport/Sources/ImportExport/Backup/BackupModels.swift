// ImportExport/Sources/ImportExport/Backup/BackupModels.swift
// JSON schema for backup/restore operations

import Domain
import Foundation

/// Versioned backup schema for HomeCooked data
public struct BackupExport: Codable {
    /// Schema version for compatibility checking
    public let version: Int

    /// Timestamp when backup was created
    public let exportedAt: Date

    /// All boards with their columns and cards
    public let boards: [BoardExport]

    /// All personal lists
    public let lists: [PersonalList]

    /// All recipes
    public let recipes: [Recipe]

    public init(
        version: Int = 1,
        exportedAt: Date = Date(),
        boards: [BoardExport],
        lists: [PersonalList],
        recipes: [Recipe]
    ) {
        self.version = version
        self.exportedAt = exportedAt
        self.boards = boards
        self.lists = lists
        self.recipes = recipes
    }
}

/// A board export includes the board itself and all its columns with cards
public struct BoardExport: Codable {
    /// The board metadata
    public let board: Board

    /// All columns belonging to this board
    public let columns: [ColumnExport]

    public init(board: Board, columns: [ColumnExport]) {
        self.board = board
        self.columns = columns
    }
}

/// A column export includes the column itself and all its cards
public struct ColumnExport: Codable {
    /// The column metadata
    public let column: Column

    /// All cards belonging to this column
    public let cards: [Card]

    public init(column: Column, cards: [Card]) {
        self.column = column
        self.cards = cards
    }
}
