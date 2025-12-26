// ImportExport/Sources/ImportExport/Trello/TrelloImporter.swift
// Imports Trello JSON exports into the repository

import Domain
import Foundation
import PersistenceInterfaces

/// Result of a Trello import operation
public struct TrelloImportResult {
    public let boardsImported: Int
    public let columnsImported: Int
    public let cardsImported: Int
    public let skipped: Int

    public init(boardsImported: Int, columnsImported: Int, cardsImported: Int, skipped: Int) {
        self.boardsImported = boardsImported
        self.columnsImported = columnsImported
        self.cardsImported = cardsImported
        self.skipped = skipped
    }

    public var summary: String {
        """
        Import Summary:
          Boards: \(boardsImported)
          Columns: \(columnsImported)
          Cards: \(cardsImported)
          Skipped (duplicates): \(skipped)
        """
    }
}

/// Imports Trello JSON exports with deduplication
public actor TrelloImporter {
    private let repository: BoardsRepository

    /// Creates a new Trello importer
    ///
    /// - Parameter repository: The boards repository to write to
    public init(repository: BoardsRepository) {
        self.repository = repository
    }

    /// Imports a Trello JSON export from data
    ///
    /// - Parameters:
    ///   - data: JSON data from Trello export
    ///   - deduplicate: If true, skip boards with matching title and approximate creation date
    /// - Returns: Import result with counts
    /// - Throws: Import errors or persistence errors
    public func importData(_ data: Data, deduplicate: Bool = true) async throws -> TrelloImportResult {
        // Decode JSON
        let decoder = JSONDecoder()
        let export = try decoder.decode(TrelloExport.self, from: data)

        return try await importExport(export, deduplicate: deduplicate)
    }

    /// Imports a Trello JSON export from a file
    ///
    /// - Parameters:
    ///   - url: URL to the Trello JSON file
    ///   - deduplicate: If true, skip boards with matching title and approximate creation date
    /// - Returns: Import result with counts
    /// - Throws: Import errors or persistence errors
    public func importFile(_ url: URL, deduplicate: Bool = true) async throws -> TrelloImportResult {
        let data = try Data(contentsOf: url)
        return try await importData(data, deduplicate: deduplicate)
    }

    /// Imports a decoded Trello export
    ///
    /// - Parameters:
    ///   - export: The decoded Trello export
    ///   - deduplicate: If true, skip boards with matching title
    /// - Returns: Import result with counts
    /// - Throws: Persistence errors
    public func importExport(_ export: TrelloExport, deduplicate: Bool = true) async throws -> TrelloImportResult {
        // Check for duplicates if requested
        let skipped = 0

        if deduplicate {
            let existingBoards = try await repository.loadBoards()

            // Check if a board with the same title already exists
            // We use a simple name match as the deduplication heuristic
            let isDuplicate = existingBoards.contains { board in
                board.title.lowercased() == export.name.lowercased()
            }

            if isDuplicate {
                // Skip this import
                return TrelloImportResult(
                    boardsImported: 0,
                    columnsImported: 0,
                    cardsImported: 0,
                    skipped: 1
                )
            }
        }

        // Map Trello structures to Domain models
        let (board, columns, cards) = TrelloMapper.map(export)

        // Write to repository
        try await repository.createBoard(board)

        // Create all columns
        for column in columns {
            try await repository.createColumn(column)
        }

        // Create all cards
        for card in cards {
            try await repository.createCard(card)
        }

        return TrelloImportResult(
            boardsImported: 1,
            columnsImported: columns.count,
            cardsImported: cards.count,
            skipped: skipped
        )
    }

    /// Imports multiple Trello exports
    ///
    /// - Parameters:
    ///   - exports: Array of Trello exports to import
    ///   - deduplicate: If true, skip boards with matching title
    /// - Returns: Combined import result
    /// - Throws: Persistence errors
    public func importMultiple(_ exports: [TrelloExport], deduplicate: Bool = true) async throws -> TrelloImportResult {
        var totalBoards = 0
        var totalColumns = 0
        var totalCards = 0
        var totalSkipped = 0

        for export in exports {
            let result = try await importExport(export, deduplicate: deduplicate)
            totalBoards += result.boardsImported
            totalColumns += result.columnsImported
            totalCards += result.cardsImported
            totalSkipped += result.skipped
        }

        return TrelloImportResult(
            boardsImported: totalBoards,
            columnsImported: totalColumns,
            cardsImported: totalCards,
            skipped: totalSkipped
        )
    }
}
