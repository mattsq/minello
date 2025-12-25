// ImportExport/Sources/ImportExport/Backup/BackupRestorer.swift
// Restores HomeCooked data from versioned JSON backup

import Domain
import Foundation
import PersistenceInterfaces

/// Restore mode for handling existing data
public enum RestoreMode {
    /// Merge with existing data, skipping items with matching IDs
    case merge

    /// Overwrite existing data with backup data (matching IDs are updated)
    case overwrite
}

/// Result of a backup restore operation
public struct BackupRestoreResult {
    public let boardsRestored: Int
    public let columnsRestored: Int
    public let cardsRestored: Int
    public let listsRestored: Int
    public let recipesRestored: Int
    public let skipped: Int

    public init(
        boardsRestored: Int,
        columnsRestored: Int,
        cardsRestored: Int,
        listsRestored: Int,
        recipesRestored: Int,
        skipped: Int
    ) {
        self.boardsRestored = boardsRestored
        self.columnsRestored = columnsRestored
        self.cardsRestored = cardsRestored
        self.listsRestored = listsRestored
        self.recipesRestored = recipesRestored
        self.skipped = skipped
    }

    public var summary: String {
        """
        Restore Summary:
          Boards: \(boardsRestored)
          Columns: \(columnsRestored)
          Cards: \(cardsRestored)
          Lists: \(listsRestored)
          Recipes: \(recipesRestored)
          Skipped: \(skipped)
        """
    }
}

/// Restores HomeCooked data from JSON backup
public actor BackupRestorer {
    private let boardsRepository: BoardsRepository

    /// Creates a new backup restorer
    ///
    /// - Parameter boardsRepository: The boards repository to write to
    public init(boardsRepository: BoardsRepository) {
        self.boardsRepository = boardsRepository
    }

    /// Restores data from a BackupExport structure
    ///
    /// - Parameters:
    ///   - backup: The backup to restore
    ///   - mode: Restore mode (merge or overwrite)
    /// - Returns: Restore result with counts
    /// - Throws: Persistence errors
    public func restore(_ backup: BackupExport, mode: RestoreMode) async throws -> BackupRestoreResult {
        // Validate schema version
        guard backup.version == 1 else {
            throw BackupError.unsupportedVersion(backup.version)
        }

        var boardsRestored = 0
        var columnsRestored = 0
        var cardsRestored = 0
        var skipped = 0

        // Load existing boards to check for conflicts
        let existingBoards: Set<BoardID>
        if mode == .merge {
            existingBoards = Set(try await boardsRepository.loadBoards().map { $0.id })
        } else {
            existingBoards = []
        }

        // Restore each board with its columns and cards
        for boardExport in backup.boards {
            // Check if board already exists in merge mode
            if mode == .merge && existingBoards.contains(boardExport.board.id) {
                skipped += 1
                continue
            }

            // Create or update board
            if mode == .overwrite {
                // Try to update if exists, otherwise create
                do {
                    _ = try await boardsRepository.loadBoard(boardExport.board.id)
                    try await boardsRepository.updateBoard(boardExport.board)
                } catch {
                    try await boardsRepository.createBoard(boardExport.board)
                }
            } else {
                try await boardsRepository.createBoard(boardExport.board)
            }
            boardsRestored += 1

            // Restore columns for this board
            for columnExport in boardExport.columns {
                if mode == .overwrite {
                    // Try to update if exists, otherwise create
                    do {
                        _ = try await boardsRepository.loadColumn(columnExport.column.id)
                        try await boardsRepository.updateColumn(columnExport.column)
                    } catch {
                        try await boardsRepository.createColumn(columnExport.column)
                    }
                } else {
                    try await boardsRepository.createColumn(columnExport.column)
                }
                columnsRestored += 1

                // Restore cards for this column
                for card in columnExport.cards {
                    if mode == .overwrite {
                        // Try to update if exists, otherwise create
                        do {
                            _ = try await boardsRepository.loadCard(card.id)
                            try await boardsRepository.updateCard(card)
                        } catch {
                            try await boardsRepository.createCard(card)
                        }
                    } else {
                        try await boardsRepository.createCard(card)
                    }
                    cardsRestored += 1
                }
            }
        }

        // Lists and recipes will be restored in ticket #6
        // For now, we just track counts as 0
        let listsRestored = 0
        let recipesRestored = 0

        return BackupRestoreResult(
            boardsRestored: boardsRestored,
            columnsRestored: columnsRestored,
            cardsRestored: cardsRestored,
            listsRestored: listsRestored,
            recipesRestored: recipesRestored,
            skipped: skipped
        )
    }

    /// Restores data from JSON Data
    ///
    /// - Parameters:
    ///   - data: JSON backup data
    ///   - mode: Restore mode (merge or overwrite)
    /// - Returns: Restore result with counts
    /// - Throws: Decoding or persistence errors
    public func restoreFromData(_ data: Data, mode: RestoreMode) async throws -> BackupRestoreResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let backup = try decoder.decode(BackupExport.self, from: data)
        return try await restore(backup, mode: mode)
    }

    /// Restores data from a JSON file
    ///
    /// - Parameters:
    ///   - url: The source file URL
    ///   - mode: Restore mode (merge or overwrite)
    /// - Returns: Restore result with counts
    /// - Throws: Decoding, persistence, or file system errors
    public func restoreFromFile(_ url: URL, mode: RestoreMode) async throws -> BackupRestoreResult {
        let data = try Data(contentsOf: url)
        return try await restoreFromData(data, mode: mode)
    }
}

/// Errors that can occur during backup/restore operations
public enum BackupError: Error, CustomStringConvertible {
    case unsupportedVersion(Int)
    case invalidData(String)

    public var description: String {
        switch self {
        case .unsupportedVersion(let version):
            return "Unsupported backup version: \(version). This tool supports version 1."
        case .invalidData(let message):
            return "Invalid backup data: \(message)"
        }
    }
}
