// PersistenceGRDB/Sources/PersistenceGRDB/GRDBSearchRepository.swift
// GRDB implementation of SearchRepository

import Domain
import Foundation
import GRDB
import PersistenceInterfaces

/// GRDB implementation of SearchRepository
public actor GRDBSearchRepository: SearchRepository {
    private let dbWriter: any DatabaseWriter

    public init(dbWriter: any DatabaseWriter) {
        self.dbWriter = dbWriter
    }

    /// Creates a new in-memory database for testing
    /// - Returns: A new repository with an in-memory database
    public static func inMemory() throws -> GRDBSearchRepository {
        let dbQueue = try DatabaseQueue()
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBSearchRepository(dbWriter: dbQueue)
    }

    /// Creates a new file-based database
    /// - Parameter path: Path to the database file
    /// - Returns: A new repository with a file-based database
    public static func onDisk(at path: String) throws -> GRDBSearchRepository {
        let dbQueue = try DatabaseQueue(path: path)
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBSearchRepository(dbWriter: dbQueue)
    }

    // MARK: - Basic Search Operations

    public func searchCardsByText(_ query: String) async throws -> [Card] {
        try await dbWriter.read { db in
            let pattern = "%\(query)%"
            let records = try CardRecord
                .filter(sql: "title LIKE ? OR details LIKE ?", arguments: [pattern, pattern])
                .order(sql: "created_at DESC")
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCardsWithRecipe(boardID: BoardID?) async throws -> [Card] {
        try await dbWriter.read { db in
            var sql = "SELECT cards.* FROM cards WHERE recipe_id IS NOT NULL"
            var arguments: [DatabaseValueConvertible] = []

            if let boardID = boardID {
                sql += " AND column_id IN (SELECT id FROM columns WHERE board_id = ?)"
                arguments.append(boardID.rawValue.uuidString)
            }

            sql += " ORDER BY created_at DESC"

            let records = try CardRecord.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCardsWithList(boardID: BoardID?) async throws -> [Card] {
        try await dbWriter.read { db in
            var sql = "SELECT cards.* FROM cards WHERE list_id IS NOT NULL"
            var arguments: [DatabaseValueConvertible] = []

            if let boardID = boardID {
                sql += " AND column_id IN (SELECT id FROM columns WHERE board_id = ?)"
                arguments.append(boardID.rawValue.uuidString)
            }

            sql += " ORDER BY created_at DESC"

            let records = try CardRecord.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCardsByTag(_ tag: String, boardID: BoardID?) async throws -> [Card] {
        try await dbWriter.read { db in
            // Search for tag in JSON array
            // SQLite JSON extension: json_each to extract array elements
            var sql = """
                SELECT DISTINCT cards.*
                FROM cards, json_each(cards.tags) AS tag
                WHERE tag.value = ?
                """

            var arguments: [DatabaseValueConvertible] = [tag]

            if let boardID = boardID {
                sql += """
                    AND cards.column_id IN (
                        SELECT id FROM columns WHERE board_id = ?
                    )
                    """
                arguments.append(boardID.rawValue.uuidString)
            }

            sql += " ORDER BY cards.created_at DESC"

            let records = try CardRecord.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCardsByDueDate(from: Date, to: Date, boardID: BoardID?) async throws -> [Card] {
        try await dbWriter.read { db in
            let fromString = ISO8601DateFormatter.iso8601.string(from: from)
            let toString = ISO8601DateFormatter.iso8601.string(from: to)

            var sql = "SELECT cards.* FROM cards WHERE due >= ? AND due <= ?"
            var arguments: [DatabaseValueConvertible] = [fromString, toString]

            if let boardID = boardID {
                sql += " AND column_id IN (SELECT id FROM columns WHERE board_id = ?)"
                arguments.append(boardID.rawValue.uuidString)
            }

            sql += " ORDER BY created_at DESC"

            let records = try CardRecord.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))
            return try records.map { try $0.toDomain() }
        }
    }

    // MARK: - Advanced Filtering

    public func searchCards(filter: CardFilter) async throws -> [CardSearchResult] {
        try await dbWriter.read { db in
            // Build SQL query based on filter criteria
            var conditions: [String] = []
            var arguments: [DatabaseValueConvertible] = []

            // Text search
            if let text = filter.text, !text.isEmpty {
                let pattern = "%\(text)%"
                conditions.append("(cards.title LIKE ? OR cards.details LIKE ?)")
                arguments.append(contentsOf: [pattern, pattern])
            }

            // Has recipe filter
            if let hasRecipe = filter.hasRecipe {
                if hasRecipe {
                    conditions.append("cards.recipe_id IS NOT NULL")
                } else {
                    conditions.append("cards.recipe_id IS NULL")
                }
            }

            // Has list filter
            if let hasList = filter.hasList {
                if hasList {
                    conditions.append("cards.list_id IS NOT NULL")
                } else {
                    conditions.append("cards.list_id IS NULL")
                }
            }

            // Tag filter
            if let tag = filter.tag, !tag.isEmpty {
                conditions.append("""
                    cards.id IN (
                        SELECT DISTINCT cards.id
                        FROM cards, json_each(cards.tags) AS tag
                        WHERE tag.value = ?
                    )
                    """)
                arguments.append(tag)
            }

            // Due date range filter
            if let (from, to) = filter.dueDateRange {
                let fromString = ISO8601DateFormatter.iso8601.string(from: from)
                let toString = ISO8601DateFormatter.iso8601.string(from: to)
                conditions.append("cards.due >= ? AND cards.due <= ?")
                arguments.append(contentsOf: [fromString, toString])
            }

            // Board filter
            if let boardID = filter.boardID {
                conditions.append("columns.board_id = ?")
                arguments.append(boardID.rawValue.uuidString)
            }

            // Build the complete query with joins
            // Note: "index" is a SQL reserved keyword, so we quote it
            var sql = """
                SELECT
                    cards.*,
                    columns.id as column_id,
                    columns.board_id as column_board_id,
                    columns.title as column_title,
                    columns."index" as column_index,
                    columns.cards as column_cards,
                    columns.created_at as column_created_at,
                    columns.updated_at as column_updated_at,
                    boards.id as board_id,
                    boards.title as board_title,
                    boards.columns as board_columns,
                    boards.created_at as board_created_at,
                    boards.updated_at as board_updated_at
                FROM cards
                INNER JOIN columns ON cards.column_id = columns.id
                INNER JOIN boards ON columns.board_id = boards.id
                """

            if !conditions.isEmpty {
                sql += " WHERE " + conditions.joined(separator: " AND ")
            }

            sql += " ORDER BY cards.created_at DESC"

            // Execute query and build results
            let rows = try Row.fetchAll(db, sql: sql, arguments: StatementArguments(arguments))

            var results: [CardSearchResult] = []
            for row in rows {
                // Parse card using row decoding
                let cardRow = Row([
                    "id": row["id"],
                    "column_id": row["column_id"],
                    "title": row["title"],
                    "details": row["details"],
                    "due": row["due"],
                    "tags": row["tags"],
                    "checklist": row["checklist"],
                    "sort_key": row["sort_key"],
                    "recipe_id": row["recipe_id"],
                    "list_id": row["list_id"],
                    "created_at": row["created_at"],
                    "updated_at": row["updated_at"]
                ])
                let card = try CardRecord(row: cardRow).toDomain()

                // Parse column using row decoding
                let columnRow = Row([
                    "id": row["column_id"],
                    "board_id": row["column_board_id"],
                    "title": row["column_title"],
                    "index": row["column_index"],
                    "cards": row["column_cards"],
                    "created_at": row["column_created_at"],
                    "updated_at": row["column_updated_at"]
                ])
                let column = try ColumnRecord(row: columnRow).toDomain()

                // Parse board using row decoding
                let boardRow = Row([
                    "id": row["board_id"],
                    "title": row["board_title"],
                    "columns": row["board_columns"],
                    "created_at": row["board_created_at"],
                    "updated_at": row["board_updated_at"]
                ])
                let board = try BoardRecord(row: boardRow).toDomain()

                // Build result
                let result = CardSearchResult(
                    card: card,
                    column: column,
                    board: board,
                    hasRecipe: card.recipeID != nil,
                    hasList: card.listID != nil
                )
                results.append(result)
            }

            return results
        }
    }
}

