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
        var migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBBoardsRepository(dbQueue: dbQueue)
    }

    /// Creates a new file-based database
    /// - Parameter path: Path to the database file
    /// - Returns: A new repository with a file-based database
    public static func onDisk(at path: String) throws -> GRDBBoardsRepository {
        let dbQueue = try DatabaseQueue(path: path)
        var migrator = HomeCookedMigrator.makeMigrator()
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
                .order(Column("created_at").asc)
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
            var updated = try record.updateAndFetch(db)
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

    public func createColumn(_ column: Column) async throws {
        try await dbQueue.write { db in
            let record = try ColumnRecord(from: column)
            try record.insert(db)
        }
    }

    public func loadColumns(for boardID: BoardID) async throws -> [Column] {
        try await dbQueue.read { db in
            let boardIDString = boardID.rawValue.uuidString
            let records = try ColumnRecord
                .filter(Column("board_id") == boardIDString)
                .order(Column("index").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func loadColumn(_ id: ColumnID) async throws -> Column {
        try await dbQueue.read { db in
            let idString = id.rawValue.uuidString
            guard let record = try ColumnRecord.fetchOne(db, key: idString) else {
                throw PersistenceError.notFound("Column with ID \(idString) not found")
            }
            return try record.toDomain()
        }
    }

    public func updateColumn(_ column: Column) async throws {
        try await dbQueue.write { db in
            let record = try ColumnRecord(from: column)
            let updated = try record.updateAndFetch(db)
            if updated == nil {
                throw PersistenceError.notFound("Column with ID \(column.id.rawValue.uuidString) not found")
            }
        }
    }

    public func saveColumns(_ columns: [Column]) async throws {
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
                .filter(Column("column_id") == columnIDString)
                .order(Column("sort_key").asc)
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
        try await dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: query)
            let sql = """
                SELECT cards.* FROM cards
                JOIN cards_fts ON cards.rowid = cards_fts.rowid
                WHERE cards_fts MATCH ?
                ORDER BY cards.sort_key ASC
                """
            let records = try CardRecord.fetchAll(db, sql: sql, arguments: [pattern])
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCards(byTag tag: String) async throws -> [Card] {
        try await dbQueue.read { db in
            // Since tags are stored as JSON, we need to search using LIKE
            let pattern = "%\"\(tag)\"%"
            let records = try CardRecord
                .filter(Column("tags").like(pattern))
                .order(Column("sort_key").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func findCards(dueBetween from: Date, and to: Date) async throws -> [Card] {
        try await dbQueue.read { db in
            let fromString = ISO8601DateFormatter.iso8601.string(from: from)
            let toString = ISO8601DateFormatter.iso8601.string(from: to)

            let records = try CardRecord
                .filter(Column("due") >= fromString && Column("due") <= toString)
                .order(Column("due").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }
}
