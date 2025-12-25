// SyncCloudKit/Sources/SyncCloudKit/CloudKitRecordMapper.swift
// Maps domain models to/from CloudKit records

#if canImport(CloudKit)
import CloudKit
import Domain
import Foundation

/// Maps domain models to CloudKit CKRecord
enum CloudKitRecordMapper {
    // MARK: - Record Types

    static let boardRecordType = "Board"
    static let columnRecordType = "Column"
    static let cardRecordType = "Card"
    static let listRecordType = "PersonalList"
    static let recipeRecordType = "Recipe"

    // MARK: - Board Mapping

    static func record(from board: Board, zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(recordName: board.id.rawValue.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: boardRecordType, recordID: recordID)

        record["title"] = board.title as CKRecordValue
        record["columns"] = board.columns.map { $0.rawValue.uuidString } as CKRecordValue
        record["createdAt"] = board.createdAt as CKRecordValue
        record["updatedAt"] = board.updatedAt as CKRecordValue

        return record
    }

    static func board(from record: CKRecord) throws -> Board {
        guard let title = record["title"] as? String,
              let columnStrings = record["columns"] as? [String],
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date
        else {
            throw CloudKitSyncError.invalidRecord("Invalid board record")
        }

        let columns = columnStrings.compactMap { UUID(uuidString: $0) }.map { ColumnID(rawValue: $0) }
        let id = BoardID(rawValue: UUID(uuidString: record.recordID.recordName)!)

        return Board(
            id: id,
            title: title,
            columns: columns,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Column Mapping

    static func record(from column: Column, zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(recordName: column.id.rawValue.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: columnRecordType, recordID: recordID)

        record["boardID"] = column.board.rawValue.uuidString as CKRecordValue
        record["title"] = column.title as CKRecordValue
        record["index"] = column.index as CKRecordValue
        record["cards"] = column.cards.map { $0.rawValue.uuidString } as CKRecordValue
        record["createdAt"] = column.createdAt as CKRecordValue
        record["updatedAt"] = column.updatedAt as CKRecordValue

        return record
    }

    static func column(from record: CKRecord) throws -> Column {
        guard let boardIDString = record["boardID"] as? String,
              let boardUUID = UUID(uuidString: boardIDString),
              let title = record["title"] as? String,
              let index = record["index"] as? Int,
              let cardStrings = record["cards"] as? [String],
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date
        else {
            throw CloudKitSyncError.invalidRecord("Invalid column record")
        }

        let cards = cardStrings.compactMap { UUID(uuidString: $0) }.map { CardID(rawValue: $0) }
        let id = ColumnID(rawValue: UUID(uuidString: record.recordID.recordName)!)
        let boardID = BoardID(rawValue: boardUUID)

        return Column(
            id: id,
            board: boardID,
            title: title,
            index: index,
            cards: cards,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Card Mapping

    static func record(from card: Card, zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(recordName: card.id.rawValue.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: cardRecordType, recordID: recordID)

        record["columnID"] = card.column.rawValue.uuidString as CKRecordValue
        record["title"] = card.title as CKRecordValue
        record["details"] = card.details as CKRecordValue
        record["due"] = card.due as? CKRecordValue
        record["tags"] = card.tags as CKRecordValue
        record["sortKey"] = card.sortKey as CKRecordValue
        record["createdAt"] = card.createdAt as CKRecordValue
        record["updatedAt"] = card.updatedAt as CKRecordValue

        // Encode checklist as JSON
        if let checklistData = try? JSONEncoder().encode(card.checklist),
           let checklistString = String(data: checklistData, encoding: .utf8)
        {
            record["checklist"] = checklistString as CKRecordValue
        }

        return record
    }

    static func card(from record: CKRecord) throws -> Card {
        guard let columnIDString = record["columnID"] as? String,
              let columnUUID = UUID(uuidString: columnIDString),
              let title = record["title"] as? String,
              let details = record["details"] as? String,
              let sortKey = record["sortKey"] as? Double,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date
        else {
            throw CloudKitSyncError.invalidRecord("Invalid card record")
        }

        let id = CardID(rawValue: UUID(uuidString: record.recordID.recordName)!)
        let columnID = ColumnID(rawValue: columnUUID)
        let due = record["due"] as? Date
        let tags = record["tags"] as? [String] ?? []

        var checklist: [ChecklistItem] = []
        if let checklistString = record["checklist"] as? String,
           let checklistData = checklistString.data(using: .utf8)
        {
            checklist = (try? JSONDecoder().decode([ChecklistItem].self, from: checklistData)) ?? []
        }

        return Card(
            id: id,
            column: columnID,
            title: title,
            details: details,
            due: due,
            tags: tags,
            checklist: checklist,
            sortKey: sortKey,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - PersonalList Mapping

    static func record(from list: PersonalList, zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(recordName: list.id.rawValue.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: listRecordType, recordID: recordID)

        record["title"] = list.title as CKRecordValue
        record["createdAt"] = list.createdAt as CKRecordValue
        record["updatedAt"] = list.updatedAt as CKRecordValue

        // Encode items as JSON
        if let itemsData = try? JSONEncoder().encode(list.items),
           let itemsString = String(data: itemsData, encoding: .utf8)
        {
            record["items"] = itemsString as CKRecordValue
        }

        return record
    }

    static func personalList(from record: CKRecord) throws -> PersonalList {
        guard let title = record["title"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date
        else {
            throw CloudKitSyncError.invalidRecord("Invalid list record")
        }

        let id = ListID(rawValue: UUID(uuidString: record.recordID.recordName)!)

        var items: [ChecklistItem] = []
        if let itemsString = record["items"] as? String,
           let itemsData = itemsString.data(using: .utf8)
        {
            items = (try? JSONDecoder().decode([ChecklistItem].self, from: itemsData)) ?? []
        }

        return PersonalList(
            id: id,
            title: title,
            items: items,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    // MARK: - Recipe Mapping

    static func record(from recipe: Recipe, zoneID: CKRecordZone.ID) -> CKRecord {
        let recordID = CKRecord.ID(recordName: recipe.id.rawValue.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: recipeRecordType, recordID: recordID)

        record["title"] = recipe.title as CKRecordValue
        record["methodMarkdown"] = recipe.methodMarkdown as CKRecordValue
        record["tags"] = recipe.tags as CKRecordValue
        record["createdAt"] = recipe.createdAt as CKRecordValue
        record["updatedAt"] = recipe.updatedAt as CKRecordValue

        // Encode ingredients as JSON
        if let ingredientsData = try? JSONEncoder().encode(recipe.ingredients),
           let ingredientsString = String(data: ingredientsData, encoding: .utf8)
        {
            record["ingredients"] = ingredientsString as CKRecordValue
        }

        return record
    }

    static func recipe(from record: CKRecord) throws -> Recipe {
        guard let title = record["title"] as? String,
              let methodMarkdown = record["methodMarkdown"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date
        else {
            throw CloudKitSyncError.invalidRecord("Invalid recipe record")
        }

        let id = RecipeID(rawValue: UUID(uuidString: record.recordID.recordName)!)
        let tags = record["tags"] as? [String] ?? []

        var ingredients: [ChecklistItem] = []
        if let ingredientsString = record["ingredients"] as? String,
           let ingredientsData = ingredientsString.data(using: .utf8)
        {
            ingredients = (try? JSONDecoder().decode([ChecklistItem].self, from: ingredientsData)) ?? []
        }

        return Recipe(
            id: id,
            title: title,
            ingredients: ingredients,
            methodMarkdown: methodMarkdown,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

/// Errors that can occur during CloudKit sync
enum CloudKitSyncError: Error, Equatable {
    case invalidRecord(String)
    case networkUnavailable
    case accountNotAvailable
    case unknownError(String)
}
#endif
