// PersistenceGRDB/Sources/PersistenceGRDB/GRDBListsRepository.swift
// GRDB implementation of ListsRepository

import Domain
import Foundation
import GRDB
import PersistenceInterfaces

/// GRDB implementation of ListsRepository
public final class GRDBListsRepository: ListsRepository {
    private let dbQueue: DatabaseQueue

    /// Creates a new GRDB repository
    /// - Parameter dbQueue: The GRDB database queue
    public init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    /// Creates a new in-memory database for testing
    /// - Returns: A new repository with an in-memory database
    public static func inMemory() throws -> GRDBListsRepository {
        let dbQueue = try DatabaseQueue()
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBListsRepository(dbQueue: dbQueue)
    }

    /// Creates a new file-based database
    /// - Parameter path: Path to the database file
    /// - Returns: A new repository with a file-based database
    public static func onDisk(at path: String) throws -> GRDBListsRepository {
        let dbQueue = try DatabaseQueue(path: path)
        let migrator = HomeCookedMigrator.makeMigrator()
        try migrator.migrate(dbQueue)
        return GRDBListsRepository(dbQueue: dbQueue)
    }

    // MARK: - List Operations

    public func createList(_ list: PersonalList) async throws {
        try await dbQueue.write { db in
            let record = try PersonalListRecord(from: list)
            try record.insert(db)
        }
    }

    public func loadLists() async throws -> [PersonalList] {
        try await dbQueue.read { db in
            let records = try PersonalListRecord
                .order(Column("created_at").asc)
                .fetchAll(db)
            return try records.map { try $0.toDomain() }
        }
    }

    public func loadList(_ id: ListID) async throws -> PersonalList {
        try await dbQueue.read { db in
            let idString = id.rawValue.uuidString
            guard let record = try PersonalListRecord.fetchOne(db, key: idString) else {
                throw PersistenceError.notFound("List with ID \(idString) not found")
            }
            return try record.toDomain()
        }
    }

    public func updateList(_ list: PersonalList) async throws {
        do {
            try await dbQueue.write { db in
                let record = try PersonalListRecord(from: list)
                try record.update(db)
            }
        } catch _ as GRDB.RecordError {
            // GRDB throws RecordError.recordNotFound when trying to update a non-existent record
            throw PersistenceError.notFound("List with ID \(list.id.rawValue.uuidString) not found")
        } catch {
            // Other database errors
            throw PersistenceError.databaseError(error.localizedDescription)
        }
    }

    public func deleteList(_ id: ListID) async throws {
        try await dbQueue.write { db in
            let idString = id.rawValue.uuidString
            let deleted = try PersonalListRecord.deleteOne(db, key: idString)
            if !deleted {
                throw PersistenceError.notFound("List with ID \(idString) not found")
            }
        }
    }

    // MARK: - Query Operations

    public func searchLists(query: String) async throws -> [PersonalList] {
        try await dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: query)
            let sql = """
                SELECT personal_lists.* FROM personal_lists
                JOIN personal_lists_fts ON personal_lists.rowid = personal_lists_fts.rowid
                WHERE personal_lists_fts MATCH ?
                ORDER BY personal_lists.created_at ASC
                """
            let records = try PersonalListRecord.fetchAll(db, sql: sql, arguments: [pattern])
            return try records.map { try $0.toDomain() }
        }
    }

    public func findListsWithIncompleteItems() async throws -> [PersonalList] {
        try await dbQueue.read { db in
            // Fetch all lists and filter in memory since items are JSON
            let allRecords = try PersonalListRecord
                .order(Column("created_at").asc)
                .fetchAll(db)

            let allLists = try allRecords.map { try $0.toDomain() }

            // Filter lists that have at least one incomplete item
            return allLists.filter { list in
                list.items.contains { !$0.isDone }
            }
        }
    }

    // MARK: - Card-Centric Query Operations

    public func loadForCard(_ cardID: CardID) async throws -> PersonalList? {
        try await dbQueue.read { db in
            let cardIDString = cardID.rawValue.uuidString
            let record = try PersonalListRecord
                .filter(Column("card_id") == cardIDString)
                .fetchOne(db)
            return try record?.toDomain()
        }
    }
}
