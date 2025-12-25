// ImportExport/Sources/ImportExport/Backup/BackupExporter.swift
// Exports HomeCooked data to versioned JSON backup

import Domain
import Foundation
import PersistenceInterfaces

/// Result of a backup export operation
public struct BackupExportResult {
    public let boardsExported: Int
    public let columnsExported: Int
    public let cardsExported: Int
    public let listsExported: Int
    public let recipesExported: Int

    public init(
        boardsExported: Int,
        columnsExported: Int,
        cardsExported: Int,
        listsExported: Int,
        recipesExported: Int
    ) {
        self.boardsExported = boardsExported
        self.columnsExported = columnsExported
        self.cardsExported = cardsExported
        self.listsExported = listsExported
        self.recipesExported = recipesExported
    }

    public var summary: String {
        """
        Backup Summary:
          Boards: \(boardsExported)
          Columns: \(columnsExported)
          Cards: \(cardsExported)
          Lists: \(listsExported)
          Recipes: \(recipesExported)
        """
    }
}

/// Exports HomeCooked data to JSON backup
public actor BackupExporter {
    private let boardsRepository: BoardsRepository

    /// Creates a new backup exporter
    ///
    /// - Parameter boardsRepository: The boards repository to read from
    public init(boardsRepository: BoardsRepository) {
        self.boardsRepository = boardsRepository
    }

    /// Exports all data to a BackupExport structure
    ///
    /// - Returns: The backup export with all data
    /// - Throws: Persistence errors
    public func export() async throws -> BackupExport {
        // Load all boards
        let boards = try await boardsRepository.loadBoards()

        // Build board exports with their columns and cards
        var boardExports: [BoardExport] = []
        var totalColumns = 0
        var totalCards = 0

        for board in boards {
            // Load columns for this board
            let columns = try await boardsRepository.loadColumns(for: board.id)

            // Build column exports with their cards
            var columnExports: [ColumnExport] = []

            for column in columns {
                // Load cards for this column
                let cards = try await boardsRepository.loadCards(for: column.id)

                columnExports.append(ColumnExport(column: column, cards: cards))
                totalCards += cards.count
            }

            boardExports.append(BoardExport(board: board, columns: columnExports))
            totalColumns += columns.count
        }

        // For now, lists and recipes are empty (will be implemented in ticket #6)
        // We export empty arrays to maintain schema compatibility
        let lists: [PersonalList] = []
        let recipes: [Recipe] = []

        return BackupExport(
            version: 1,
            exportedAt: Date(),
            boards: boardExports,
            lists: lists,
            recipes: recipes
        )
    }

    /// Exports all data to JSON Data
    ///
    /// - Parameter pretty: If true, format JSON with indentation
    /// - Returns: JSON data
    /// - Throws: Encoding or persistence errors
    public func exportToData(pretty: Bool = true) async throws -> Data {
        let backup = try await export()

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if pretty {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }

        return try encoder.encode(backup)
    }

    /// Exports all data to a JSON file
    ///
    /// - Parameters:
    ///   - url: The destination file URL
    ///   - pretty: If true, format JSON with indentation
    /// - Returns: Export result with counts
    /// - Throws: Encoding, persistence, or file system errors
    public func exportToFile(_ url: URL, pretty: Bool = true) async throws -> BackupExportResult {
        let data = try await exportToData(pretty: pretty)
        try data.write(to: url)

        // Calculate stats
        let backup = try await export()
        var totalColumns = 0
        var totalCards = 0

        for boardExport in backup.boards {
            totalColumns += boardExport.columns.count
            for columnExport in boardExport.columns {
                totalCards += columnExport.cards.count
            }
        }

        return BackupExportResult(
            boardsExported: backup.boards.count,
            columnsExported: totalColumns,
            cardsExported: totalCards,
            listsExported: backup.lists.count,
            recipesExported: backup.recipes.count
        )
    }
}
