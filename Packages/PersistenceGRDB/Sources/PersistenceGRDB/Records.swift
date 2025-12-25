// PersistenceGRDB/Sources/PersistenceGRDB/Records.swift
// GRDB record types for domain models

import Domain
import Foundation
import GRDB

// MARK: - Date Formatting

extension ISO8601DateFormatter {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

// MARK: - BoardRecord

/// GRDB record for Board
struct BoardRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "boards"

    var id: String
    var title: String
    var columns: String // JSON array
    var created_at: String // ISO8601
    var updated_at: String // ISO8601

    /// Converts domain Board to BoardRecord
    init(from board: Board) throws {
        self.id = board.id.rawValue.uuidString
        self.title = board.title

        let columnIDs = board.columns.map { $0.rawValue.uuidString }
        let jsonData = try JSONEncoder().encode(columnIDs)
        self.columns = String(data: jsonData, encoding: .utf8)!

        self.created_at = ISO8601DateFormatter.iso8601.string(from: board.createdAt)
        self.updated_at = ISO8601DateFormatter.iso8601.string(from: board.updatedAt)
    }

    /// Converts BoardRecord to domain Board
    func toDomain() throws -> Board {
        guard let id = UUID(uuidString: self.id) else {
            throw PersistenceError.invalidData("Invalid board ID: \(self.id)")
        }

        guard let columnsData = self.columns.data(using: .utf8) else {
            throw PersistenceError.invalidData("Invalid columns JSON")
        }
        let columnUUIDs = try JSONDecoder().decode([String].self, from: columnsData)
        let columnIDs = try columnUUIDs.map { uuidString -> ColumnID in
            guard let uuid = UUID(uuidString: uuidString) else {
                throw PersistenceError.invalidData("Invalid column ID: \(uuidString)")
            }
            return ColumnID(rawValue: uuid)
        }

        guard let createdAt = ISO8601DateFormatter.iso8601.date(from: self.created_at) else {
            throw PersistenceError.invalidData("Invalid created_at date: \(self.created_at)")
        }

        guard let updatedAt = ISO8601DateFormatter.iso8601.date(from: self.updated_at) else {
            throw PersistenceError.invalidData("Invalid updated_at date: \(self.updated_at)")
        }

        return Board(
            id: BoardID(rawValue: id),
            title: self.title,
            columns: columnIDs,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - ColumnRecord

/// GRDB record for Column
struct ColumnRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "columns"

    var id: String
    var board_id: String
    var title: String
    var index: Int
    var cards: String // JSON array
    var created_at: String // ISO8601
    var updated_at: String // ISO8601

    /// Converts domain Column to ColumnRecord
    init(from column: Column) throws {
        self.id = column.id.rawValue.uuidString
        self.board_id = column.board.rawValue.uuidString
        self.title = column.title
        self.index = column.index

        let cardIDs = column.cards.map { $0.rawValue.uuidString }
        let jsonData = try JSONEncoder().encode(cardIDs)
        self.cards = String(data: jsonData, encoding: .utf8)!

        self.created_at = ISO8601DateFormatter.iso8601.string(from: column.createdAt)
        self.updated_at = ISO8601DateFormatter.iso8601.string(from: column.updatedAt)
    }

    /// Converts ColumnRecord to domain Column
    func toDomain() throws -> Column {
        guard let id = UUID(uuidString: self.id) else {
            throw PersistenceError.invalidData("Invalid column ID: \(self.id)")
        }

        guard let boardID = UUID(uuidString: self.board_id) else {
            throw PersistenceError.invalidData("Invalid board ID: \(self.board_id)")
        }

        guard let cardsData = self.cards.data(using: .utf8) else {
            throw PersistenceError.invalidData("Invalid cards JSON")
        }
        let cardUUIDs = try JSONDecoder().decode([String].self, from: cardsData)
        let cardIDs = try cardUUIDs.map { uuidString -> CardID in
            guard let uuid = UUID(uuidString: uuidString) else {
                throw PersistenceError.invalidData("Invalid card ID: \(uuidString)")
            }
            return CardID(rawValue: uuid)
        }

        guard let createdAt = ISO8601DateFormatter.iso8601.date(from: self.created_at) else {
            throw PersistenceError.invalidData("Invalid created_at date: \(self.created_at)")
        }

        guard let updatedAt = ISO8601DateFormatter.iso8601.date(from: self.updated_at) else {
            throw PersistenceError.invalidData("Invalid updated_at date: \(self.updated_at)")
        }

        return Column(
            id: ColumnID(rawValue: id),
            board: BoardID(rawValue: boardID),
            title: self.title,
            index: self.index,
            cards: cardIDs,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - CardRecord

/// GRDB record for Card
struct CardRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "cards"

    var id: String
    var column_id: String
    var title: String
    var details: String
    var due: String? // ISO8601, nullable
    var tags: String // JSON array
    var checklist: String // JSON array of ChecklistItem
    var sort_key: Double
    var created_at: String // ISO8601
    var updated_at: String // ISO8601

    /// Converts domain Card to CardRecord
    init(from card: Card) throws {
        self.id = card.id.rawValue.uuidString
        self.column_id = card.column.rawValue.uuidString
        self.title = card.title
        self.details = card.details
        self.due = card.due.map { ISO8601DateFormatter.iso8601.string(from: $0) }

        let jsonEncoder = JSONEncoder()
        let tagsData = try jsonEncoder.encode(card.tags)
        self.tags = String(data: tagsData, encoding: .utf8)!

        let checklistData = try jsonEncoder.encode(card.checklist)
        self.checklist = String(data: checklistData, encoding: .utf8)!

        self.sort_key = card.sortKey
        self.created_at = ISO8601DateFormatter.iso8601.string(from: card.createdAt)
        self.updated_at = ISO8601DateFormatter.iso8601.string(from: card.updatedAt)
    }

    /// Converts CardRecord to domain Card
    func toDomain() throws -> Card {
        guard let id = UUID(uuidString: self.id) else {
            throw PersistenceError.invalidData("Invalid card ID: \(self.id)")
        }

        guard let columnID = UUID(uuidString: self.column_id) else {
            throw PersistenceError.invalidData("Invalid column ID: \(self.column_id)")
        }

        let due: Date? = try self.due.map { dueString in
            guard let date = ISO8601DateFormatter.iso8601.date(from: dueString) else {
                throw PersistenceError.invalidData("Invalid due date: \(dueString)")
            }
            return date
        }

        guard let tagsData = self.tags.data(using: .utf8) else {
            throw PersistenceError.invalidData("Invalid tags JSON")
        }
        let tags = try JSONDecoder().decode([String].self, from: tagsData)

        guard let checklistData = self.checklist.data(using: .utf8) else {
            throw PersistenceError.invalidData("Invalid checklist JSON")
        }
        let checklist = try JSONDecoder().decode([ChecklistItem].self, from: checklistData)

        guard let createdAt = ISO8601DateFormatter.iso8601.date(from: self.created_at) else {
            throw PersistenceError.invalidData("Invalid created_at date: \(self.created_at)")
        }

        guard let updatedAt = ISO8601DateFormatter.iso8601.date(from: self.updated_at) else {
            throw PersistenceError.invalidData("Invalid updated_at date: \(self.updated_at)")
        }

        return Card(
            id: CardID(rawValue: id),
            column: ColumnID(rawValue: columnID),
            title: self.title,
            details: self.details,
            due: due,
            tags: tags,
            checklist: checklist,
            sortKey: self.sort_key,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - PersonalListRecord

/// GRDB record for PersonalList
struct PersonalListRecord: Codable, FetchableRecord, PersistableRecord {
    static let databaseTableName = "personal_lists"

    var id: String
    var title: String
    var items: String // JSON array of ChecklistItem
    var created_at: String // ISO8601
    var updated_at: String // ISO8601

    /// Converts domain PersonalList to PersonalListRecord
    init(from list: PersonalList) throws {
        self.id = list.id.rawValue.uuidString
        self.title = list.title

        let jsonEncoder = JSONEncoder()
        let itemsData = try jsonEncoder.encode(list.items)
        self.items = String(data: itemsData, encoding: .utf8)!

        self.created_at = ISO8601DateFormatter.iso8601.string(from: list.createdAt)
        self.updated_at = ISO8601DateFormatter.iso8601.string(from: list.updatedAt)
    }

    /// Converts PersonalListRecord to domain PersonalList
    func toDomain() throws -> PersonalList {
        guard let id = UUID(uuidString: self.id) else {
            throw PersistenceError.invalidData("Invalid list ID: \(self.id)")
        }

        guard let itemsData = self.items.data(using: .utf8) else {
            throw PersistenceError.invalidData("Invalid items JSON")
        }
        let items = try JSONDecoder().decode([ChecklistItem].self, from: itemsData)

        guard let createdAt = ISO8601DateFormatter.iso8601.date(from: self.created_at) else {
            throw PersistenceError.invalidData("Invalid created_at date: \(self.created_at)")
        }

        guard let updatedAt = ISO8601DateFormatter.iso8601.date(from: self.updated_at) else {
            throw PersistenceError.invalidData("Invalid updated_at date: \(self.updated_at)")
        }

        return PersonalList(
            id: ListID(rawValue: id),
            title: self.title,
            items: items,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
