// PersistenceGRDB/Sources/PersistenceGRDB/GRDBBoardsRepository.swift
// GRDB implementation of BoardsRepository

import Domain
import Foundation
import GRDB
import PersistenceInterfaces

/// GRDB implementation of BoardsRepository
public final class GRDBBoardsRepository: BoardsRepository {
    private let dbQueue: DatabaseQueue

    /// Creates a new GRDB repository
    /// - Parameter dbQueue: The GRDB database queue
    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    /// Creates a new in-memory database for testing
    /// - Returns: A new repository with an in-memory database
    public static func inMemory() throws -> GRDBBoardsRepository {
        let dbQueue = try DatabaseQueue()
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBBoardsRepository(dbQueue: dbQueue)
    }

    /// Creates a new file-based database
    /// - Parameter path: Path to the database file
    /// - Returns: A new repository with a file-based database
    public static func onDisk(at path: String) throws -> GRDBBoardsRepository {
        let dbQueue = try DatabaseQueue(path: path)
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBBoardsRepository(dbQueue: dbQueue)
    }

    // MARK: - Board Operations

    public func createBoard(_ board: Board) async throws {
        try await dbQueue.write { db in
            let record = try BoardRecord(from: board)
            try record.insert(db)
        }
    }

    public func loadBoards() async throws -> [Board] {
        try await dbQueue.read { db in
            let records = try BoardRecord
                .order(GRDB.Column("created_at").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func loadBoard(_ id: BoardID) async throws -> Board {
        try await dbQueue.read { db in
            let idString = id.rawValue.uuidString
            guard let record = try BoardRecord.fetchOne(db, key: idString) else {
                throw PersistenceError.notFound("Board with ID \(idString) not found")
            }
            return try record.toDomain()
        }
    }

    public func updateBoard(_ board: Board) async throws {
        try await dbQueue.write { db in
            let record = try BoardRecord(from: board)
            let updated = try record.updateAndFetch(db)
            if updated == nil {
                throw PersistenceError.notFound("Board with ID \(board.id.rawValue.uuidString) not found")
            }
        }
    }

    public func deleteBoard(_ id: BoardID) async throws {
        try await dbQueue.write { db in
            let idString = id.rawValue.uuidString
            let deleted = try BoardRecord.deleteOne(db, key: idString)
            if !deleted {
                throw PersistenceError.notFound("Board with ID \(idString) not found")
            }
        }
    }

    // MARK: - Column Operations

    public func createColumn(_ column: Domain.Column) async throws {
        try await dbQueue.write { db in
            let record = try ColumnRecord(from: column)
            try record.insert(db)
        }
    }

    public func loadColumns(for boardID: BoardID) async throws -> [Domain.Column] {
        try await dbQueue.read { db in
            let boardIDString = boardID.rawValue.uuidString
            let records = try ColumnRecord
                .filter(GRDB.Column("board_id") == boardIDString)
                .order(GRDB.Column("index").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func loadColumn(_ id: ColumnID) async throws -> Domain.Column {
        try await dbQueue.read { db in
            let idString = id.rawValue.uuidString
            guard let record = try ColumnRecord.fetchOne(db, key: idString) else {
                throw PersistenceError.notFound("Column with ID \(idString) not found")
            }
            return try record.toDomain()
        }
    }

    public func updateColumn(_ column: Domain.Column) async throws {
        try await dbQueue.write { db in
            let record = try ColumnRecord(from: column)
            let updated = try record.updateAndFetch(db)
            if updated == nil {
                throw PersistenceError.notFound("Column with ID \(column.id.rawValue.uuidString) not found")
            }
        }
    }

    public func saveColumns(_ columns: [Domain.Column]) async throws {
        try await dbQueue.write { db in
            for column in columns {
                let record = try ColumnRecord(from: column)
                try record.save(db)
            }
        }
    }

    public func deleteColumn(_ id: ColumnID) async throws {
        try await dbQueue.write { db in
            let idString = id.rawValue.uuidString
            let deleted = try ColumnRecord.deleteOne(db, key: idString)
            if !deleted {
                throw PersistenceError.notFound("Column with ID \(idString) not found")
            }
        }
    }

    // MARK: - Card Operations

    public func createCard(_ card: Card) async throws {
        try await dbQueue.write { db in
            let record = try CardRecord(from: card)
            try record.insert(db)
        }
    }

    public func loadCards(for columnID: ColumnID) async throws -> [Card] {
        try await dbQueue.read { db in
            let columnIDString = columnID.rawValue.uuidString
            let records = try CardRecord
                .filter(GRDB.Column("column_id") == columnIDString)
                .order(GRDB.Column("sort_key").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func loadCard(_ id: CardID) async throws -> Card {
        try await dbQueue.read { db in
            let idString = id.rawValue.uuidString
            guard let record = try CardRecord.fetchOne(db, key: idString) else {
                throw PersistenceError.notFound("Card with ID \(idString) not found")
            }
            return try record.toDomain()
        }
    }

    public func updateCard(_ card: Card) async throws {
        try await dbQueue.write { db in
            let record = try CardRecord(from: card)
            let updated = try record.updateAndFetch(db)
            if updated == nil {
                throw PersistenceError.notFound("Card with ID \(card.id.rawValue.uuidString) not found")
            }
        }
    }

    public func saveCards(_ cards: [Card]) async throws {
        try await dbQueue.write { db in
            for card in cards {
                let record = try CardRecord(from: card)
                try record.save(db)
            }
        }
    }

    public func deleteCard(_ id: CardID) async throws {
        try await dbQueue.write { db in
            let idString = id.rawValue.uuidString
            let deleted = try CardRecord.deleteOne(db, key: idString)
            if !deleted {
                throw PersistenceError.notFound("Card with ID \(idString) not found")
            }
        }
    }

    // MARK: - Query Operations

    public func searchCards(query: String) async throws -> [Card] {
        // FTS5 doesn't accept empty MATCH expressions, so return empty results
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        return try await dbQueue.read { db in
            // Use prefix matching with wildcards to handle cases like "grocery" matching "groceries"
            // Split query into tokens and add wildcard to each for prefix matching
            // The porter tokenizer stems words, so "grocery*" matches "groceries", "grocer", etc.
            let tokens = trimmedQuery.split(separator: " ").map { String($0) + "*" }
            let ftsQuery = tokens.joined(separator: " OR ")

            let sql = """
                SELECT cards.* FROM cards
                JOIN cards_fts ON cards.rowid = cards_fts.rowid
                WHERE cards_fts MATCH ?
                ORDER BY cards.sort_key ASC
                """
            let records = try CardRecord.fetchAll(db, sql: sql, arguments: [ftsQuery])
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCards(byTag tag: String) async throws -> [Card] {
        try await dbQueue.read { db in
            // Since tags are stored as JSON, we need to search using LIKE
            let pattern = "%\"\(tag)\"%"
            let records = try CardRecord
                .filter(GRDB.Column("tags").like(pattern))
                .order(GRDB.Column("sort_key").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCards(dueBetween from: Date, and to: Date) async throws -> [Card] {
        try await dbQueue.read { db in
            let fromString = ISO8601DateFormatter.iso8601.string(from: from)
            let toString = ISO8601DateFormatter.iso8601.string(from: to)

            let records = try CardRecord
                .filter(GRDB.Column("due") >= fromString && GRDB.Column("due") <= toString)
                .order(GRDB.Column("due").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }
}
