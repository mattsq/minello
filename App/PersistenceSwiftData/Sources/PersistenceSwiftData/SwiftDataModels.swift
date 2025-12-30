// App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataModels.swift
// SwiftData models for HomeCooked

import Domain
import Foundation
import SwiftData

// MARK: - Board Model

/// SwiftData model for Board
@Model
final class BoardModel {
    @Attribute(.unique) var id: String
    var title: String
    var columnsData: Data // Stores [ColumnID] as JSON
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ColumnModel.board)
    var columns: [ColumnModel]?

    init(id: String, title: String, columnsData: Data, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.title = title
        self.columnsData = columnsData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a SwiftData model from a Domain Board
    convenience init(from board: Board) throws {
        let columnsData = try JSONEncoder().encode(board.columns.map { $0.rawValue.uuidString })
        self.init(
            id: board.id.rawValue.uuidString,
            title: board.title,
            columnsData: columnsData,
            createdAt: board.createdAt,
            updatedAt: board.updatedAt
        )
    }

    /// Converts this SwiftData model to a Domain Board
    func toDomain() throws -> Board {
        guard let uuid = UUID(uuidString: id) else {
            throw ConversionError.invalidUUID(id)
        }

        let columnIDs: [ColumnID]
        if columnsData.isEmpty {
            columnIDs = []
        } else {
            let columnStrings = try JSONDecoder().decode([String].self, from: columnsData)
            columnIDs = try columnStrings.map { uuidString in
                guard let uuid = UUID(uuidString: uuidString) else {
                    throw ConversionError.invalidUUID(uuidString)
                }
                return ColumnID(rawValue: uuid)
            }
        }

        return Board(
            id: BoardID(rawValue: uuid),
            title: title,
            columns: columnIDs,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Column Model

/// SwiftData model for Column
@Model
final class ColumnModel {
    @Attribute(.unique) var id: String
    var boardID: String
    var title: String
    var index: Int
    var cardsData: Data // Stores [CardID] as JSON
    var createdAt: Date
    var updatedAt: Date

    var board: BoardModel?

    @Relationship(deleteRule: .cascade, inverse: \CardModel.column)
    var cards: [CardModel]?

    init(id: String, boardID: String, title: String, index: Int, cardsData: Data, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.boardID = boardID
        self.title = title
        self.index = index
        self.cardsData = cardsData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a SwiftData model from a Domain Column
    convenience init(from column: Column) throws {
        let cardsData = try JSONEncoder().encode(column.cards.map { $0.rawValue.uuidString })
        self.init(
            id: column.id.rawValue.uuidString,
            boardID: column.board.rawValue.uuidString,
            title: column.title,
            index: column.index,
            cardsData: cardsData,
            createdAt: column.createdAt,
            updatedAt: column.updatedAt
        )
    }

    /// Converts this SwiftData model to a Domain Column
    func toDomain() throws -> Column {
        guard let uuid = UUID(uuidString: id) else {
            throw ConversionError.invalidUUID(id)
        }
        guard let boardUUID = UUID(uuidString: boardID) else {
            throw ConversionError.invalidUUID(boardID)
        }

        let cardIDs: [CardID]
        if cardsData.isEmpty {
            cardIDs = []
        } else {
            let cardStrings = try JSONDecoder().decode([String].self, from: cardsData)
            cardIDs = try cardStrings.map { uuidString in
                guard let uuid = UUID(uuidString: uuidString) else {
                    throw ConversionError.invalidUUID(uuidString)
                }
                return CardID(rawValue: uuid)
            }
        }

        return Column(
            id: ColumnID(rawValue: uuid),
            board: BoardID(rawValue: boardUUID),
            title: title,
            index: index,
            cards: cardIDs,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Card Model

/// SwiftData model for Card
@Model
final class CardModel {
    @Attribute(.unique) var id: String
    var columnID: String
    var title: String
    var details: String
    var due: Date?
    var tagsData: Data // Stores [String] as JSON
    var checklistData: Data // Stores [ChecklistItem] as JSON
    var sortKey: Double
    var recipeID: String? // Card-centric: optional attached recipe
    var listID: String? // Card-centric: optional attached list
    var createdAt: Date
    var updatedAt: Date

    var column: ColumnModel?

    init(id: String, columnID: String, title: String, details: String, due: Date?, tagsData: Data, checklistData: Data, sortKey: Double, recipeID: String?, listID: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.columnID = columnID
        self.title = title
        self.details = details
        self.due = due
        self.tagsData = tagsData
        self.checklistData = checklistData
        self.sortKey = sortKey
        self.recipeID = recipeID
        self.listID = listID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a SwiftData model from a Domain Card
    convenience init(from card: Card) throws {
        let tagsData = try JSONEncoder().encode(card.tags)
        let checklistData = try JSONEncoder().encode(card.checklist)
        self.init(
            id: card.id.rawValue.uuidString,
            columnID: card.column.rawValue.uuidString,
            title: card.title,
            details: card.details,
            due: card.due,
            tagsData: tagsData,
            checklistData: checklistData,
            sortKey: card.sortKey,
            recipeID: card.recipeID?.rawValue.uuidString,
            listID: card.listID?.rawValue.uuidString,
            createdAt: card.createdAt,
            updatedAt: card.updatedAt
        )
    }

    /// Converts this SwiftData model to a Domain Card
    func toDomain() throws -> Card {
        guard let uuid = UUID(uuidString: id) else {
            throw ConversionError.invalidUUID(id)
        }
        guard let columnUUID = UUID(uuidString: columnID) else {
            throw ConversionError.invalidUUID(columnID)
        }

        let tags = try JSONDecoder().decode([String].self, from: tagsData)
        let checklist = try JSONDecoder().decode([ChecklistItem].self, from: checklistData)

        // Parse optional recipeID and listID (card-centric design)
        let recipeIDParsed: RecipeID? = try recipeID.map { recipeIDString in
            guard let uuid = UUID(uuidString: recipeIDString) else {
                throw ConversionError.invalidUUID(recipeIDString)
            }
            return RecipeID(rawValue: uuid)
        }

        let listIDParsed: ListID? = try listID.map { listIDString in
            guard let uuid = UUID(uuidString: listIDString) else {
                throw ConversionError.invalidUUID(listIDString)
            }
            return ListID(rawValue: uuid)
        }

        return Card(
            id: CardID(rawValue: uuid),
            column: ColumnID(rawValue: columnUUID),
            title: title,
            details: details,
            due: due,
            tags: tags,
            checklist: checklist,
            sortKey: sortKey,
            recipeID: recipeIDParsed,
            listID: listIDParsed,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - PersonalList Model

/// SwiftData model for PersonalList
@Model
final class PersonalListModel {
    @Attribute(.unique) var id: String
    var cardID: String? // Card-centric: list must belong to a card (optional for alpha migration)
    var title: String
    var itemsData: Data // Stores [ChecklistItem] as JSON
    var createdAt: Date
    var updatedAt: Date

    init(id: String, cardID: String?, title: String, itemsData: Data, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.cardID = cardID
        self.title = title
        self.itemsData = itemsData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a SwiftData model from a Domain PersonalList
    convenience init(from list: PersonalList) throws {
        let itemsData = try JSONEncoder().encode(list.items)
        self.init(
            id: list.id.rawValue.uuidString,
            cardID: list.cardID.rawValue.uuidString,
            title: list.title,
            itemsData: itemsData,
            createdAt: list.createdAt,
            updatedAt: list.updatedAt
        )
    }

    /// Converts this SwiftData model to a Domain PersonalList
    func toDomain() throws -> PersonalList {
        guard let uuid = UUID(uuidString: id) else {
            throw ConversionError.invalidUUID(id)
        }

        let items = try JSONDecoder().decode([ChecklistItem].self, from: itemsData)

        // Card-centric design: lists must belong to a card
        // For alpha: use dummy CardID if not present (migration path)
        let cardIDParsed: CardID
        if let cardIDString = self.cardID, let cardUUID = UUID(uuidString: cardIDString) {
            cardIDParsed = CardID(rawValue: cardUUID)
        } else {
            // Alpha migration: create dummy cardID for old records
            cardIDParsed = CardID()
        }

        return PersonalList(
            id: ListID(rawValue: uuid),
            cardID: cardIDParsed,
            title: title,
            items: items,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Recipe Model

/// SwiftData model for Recipe
@Model
final class RecipeModel {
    @Attribute(.unique) var id: String
    var cardID: String? // Card-centric: recipe must belong to a card (optional for alpha migration)
    var title: String
    var ingredientsData: Data // Stores [ChecklistItem] as JSON
    var methodMarkdown: String
    var tagsData: Data // Stores [String] as JSON
    var createdAt: Date
    var updatedAt: Date

    init(id: String, cardID: String?, title: String, ingredientsData: Data, methodMarkdown: String, tagsData: Data, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.cardID = cardID
        self.title = title
        self.ingredientsData = ingredientsData
        self.methodMarkdown = methodMarkdown
        self.tagsData = tagsData
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Creates a SwiftData model from a Domain Recipe
    convenience init(from recipe: Recipe) throws {
        let ingredientsData = try JSONEncoder().encode(recipe.ingredients)
        let tagsData = try JSONEncoder().encode(recipe.tags)
        self.init(
            id: recipe.id.rawValue.uuidString,
            cardID: recipe.cardID.rawValue.uuidString,
            title: recipe.title,
            ingredientsData: ingredientsData,
            methodMarkdown: recipe.methodMarkdown,
            tagsData: tagsData,
            createdAt: recipe.createdAt,
            updatedAt: recipe.updatedAt
        )
    }

    /// Converts this SwiftData model to a Domain Recipe
    func toDomain() throws -> Recipe {
        guard let uuid = UUID(uuidString: id) else {
            throw ConversionError.invalidUUID(id)
        }

        let ingredients = try JSONDecoder().decode([ChecklistItem].self, from: ingredientsData)
        let tags = try JSONDecoder().decode([String].self, from: tagsData)

        // Card-centric design: recipes must belong to a card
        // For alpha: use dummy CardID if not present (migration path)
        let cardIDParsed: CardID
        if let cardIDString = self.cardID, let cardUUID = UUID(uuidString: cardIDString) {
            cardIDParsed = CardID(rawValue: cardUUID)
        } else {
            // Alpha migration: create dummy cardID for old records
            cardIDParsed = CardID()
        }

        return Recipe(
            id: RecipeID(rawValue: uuid),
            cardID: cardIDParsed,
            title: title,
            ingredients: ingredients,
            methodMarkdown: methodMarkdown,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

// MARK: - Errors

enum ConversionError: Error, LocalizedError {
    case invalidUUID(String)

    var errorDescription: String? {
        switch self {
        case .invalidUUID(let string):
            return "Invalid UUID string: \(string)"
        }
    }
}
