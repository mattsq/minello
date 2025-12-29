// Domain/Sources/Domain/Models.swift
// Core domain models for HomeCooked

import Foundation

// MARK: - ID Types

/// Unique identifier for a Board
public struct BoardID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = UUID()
    }
}

/// Unique identifier for a Column
public struct ColumnID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = UUID()
    }
}

/// Unique identifier for a Card
public struct CardID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = UUID()
    }
}

/// Unique identifier for a PersonalList
public struct ListID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = UUID()
    }
}

/// Unique identifier for a Recipe
public struct RecipeID: Hashable, Codable, Sendable {
    public let rawValue: UUID

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }

    public init() {
        self.rawValue = UUID()
    }
}

// MARK: - ChecklistItem

/// A checklist item that can be used in Cards, PersonalLists, or Recipe ingredients
public struct ChecklistItem: Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public var text: String
    public var isDone: Bool
    public var quantity: Double?
    public var unit: String?
    public var note: String?

    public init(
        id: UUID = UUID(),
        text: String,
        isDone: Bool = false,
        quantity: Double? = nil,
        unit: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.text = text
        self.isDone = isDone
        self.quantity = quantity
        self.unit = unit
        self.note = note
    }
}

// MARK: - Board

/// A board contains columns and represents a workflow
public struct Board: Codable, Equatable, Hashable, Sendable {
    public var id: BoardID
    public var title: String
    public var columns: [ColumnID]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: BoardID = BoardID(),
        title: String,
        columns: [ColumnID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.columns = columns
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Column

/// A column belongs to a board and contains cards
public struct Column: Codable, Equatable, Hashable, Sendable {
    public var id: ColumnID
    public var board: BoardID
    public var title: String
    public var index: Int
    public var cards: [CardID]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: ColumnID = ColumnID(),
        board: BoardID,
        title: String,
        index: Int,
        cards: [CardID] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.board = board
        self.title = title
        self.index = index
        self.cards = cards
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Card

/// A card belongs to a column and contains task details
public struct Card: Codable, Equatable, Hashable, Sendable {
    public var id: CardID
    public var column: ColumnID
    public var title: String
    public var details: String
    public var due: Date?
    public var tags: [String]
    public var checklist: [ChecklistItem]
    public var sortKey: Double
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: CardID = CardID(),
        column: ColumnID,
        title: String,
        details: String = "",
        due: Date? = nil,
        tags: [String] = [],
        checklist: [ChecklistItem] = [],
        sortKey: Double = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.column = column
        self.title = title
        self.details = details
        self.due = due
        self.tags = tags
        self.checklist = checklist
        self.sortKey = sortKey
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - PersonalList

/// A personal list (e.g., grocery list, packing list) with checklist items
public struct PersonalList: Codable, Equatable, Hashable, Sendable {
    public var id: ListID
    public var title: String
    public var items: [ChecklistItem]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: ListID = ListID(),
        title: String,
        items: [ChecklistItem] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.items = items
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Recipe

/// A recipe with ingredients (as checklist items) and markdown method
public struct Recipe: Codable, Equatable, Hashable, Sendable {
    public var id: RecipeID
    public var title: String
    public var ingredients: [ChecklistItem]
    public var methodMarkdown: String
    public var tags: [String]
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: RecipeID = RecipeID(),
        title: String,
        ingredients: [ChecklistItem] = [],
        methodMarkdown: String = "",
        tags: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.ingredients = ingredients
        self.methodMarkdown = methodMarkdown
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - SearchResult

/// Represents a search result from unified search across all entity types
public enum SearchResult: Hashable, Sendable {
    case board(Board)
    case card(Card)
    case list(PersonalList)
    case recipe(Recipe)

    /// The title of the search result
    public var title: String {
        switch self {
        case .board(let board): return board.title
        case .card(let card): return card.title
        case .list(let list): return list.title
        case .recipe(let recipe): return recipe.title
        }
    }

    /// The entity type of the search result
    public var entityType: EntityType {
        switch self {
        case .board: return .board
        case .card: return .card
        case .list: return .list
        case .recipe: return .recipe
        }
    }

    /// The creation date of the search result
    public var createdAt: Date {
        switch self {
        case .board(let board): return board.createdAt
        case .card(let card): return card.createdAt
        case .list(let list): return list.createdAt
        case .recipe(let recipe): return recipe.createdAt
        }
    }
}

/// Entity type for filtering search results
public enum EntityType: String, Codable, CaseIterable, Sendable {
    case board = "Board"
    case card = "Card"
    case list = "List"
    case recipe = "Recipe"
}
