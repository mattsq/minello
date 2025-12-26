// App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataBoardsRepository.swift
// SwiftData implementation of BoardsRepository

import Domain
import Foundation
import PersistenceInterfaces
import SwiftData

/// SwiftData implementation of BoardsRepository
public final class SwiftDataBoardsRepository: @unchecked Sendable, BoardsRepository {
    private let modelContext: ModelContext

    /// Creates a new SwiftData repository
    /// - Parameter modelContext: The SwiftData model context
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates a new in-memory model context for testing
    /// - Returns: A new repository with an in-memory model context
    @MainActor
    public static func inMemory() throws -> SwiftDataBoardsRepository {
        let schema = Schema([
            BoardModel.self,
            ColumnModel.self,
            CardModel.self,
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return SwiftDataBoardsRepository(modelContext: container.mainContext)
    }

    // MARK: - Board Operations

    public func createBoard(_ board: Board) async throws {
        let model = try BoardModel(from: board)
        modelContext.insert(model)
        try modelContext.save()
    }

    public func loadBoards() async throws -> [Board] {
        let descriptor = FetchDescriptor<BoardModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.map { try $0.toDomain() }
    }

    public func loadBoard(_ id: BoardID) async throws -> Board {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<BoardModel> { $0.id == idString }
        let descriptor = FetchDescriptor<BoardModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Board with ID \(idString) not found")
        }
        return try model.toDomain()
    }

    public func updateBoard(_ board: Board) async throws {
        let idString = board.id.rawValue.uuidString
        let predicate = #Predicate<BoardModel> { $0.id == idString }
        let descriptor = FetchDescriptor<BoardModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Board with ID \(idString) not found")
        }

        model.title = board.title
        model.columnsData = try JSONEncoder().encode(board.columns.map { $0.rawValue.uuidString })
        model.updatedAt = board.updatedAt

        try modelContext.save()
    }

    public func deleteBoard(_ id: BoardID) async throws {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<BoardModel> { $0.id == idString }
        let descriptor = FetchDescriptor<BoardModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Board with ID \(idString) not found")
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    // MARK: - Column Operations

    public func createColumn(_ column: Column) async throws {
        let model = try ColumnModel(from: column)
        modelContext.insert(model)
        try modelContext.save()
    }

    public func loadColumns(for boardID: BoardID) async throws -> [Column] {
        let boardIDString = boardID.rawValue.uuidString
        let predicate = #Predicate<ColumnModel> { $0.boardID == boardIDString }
        let descriptor = FetchDescriptor<ColumnModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.index, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.map { try $0.toDomain() }
    }

    public func loadColumn(_ id: ColumnID) async throws -> Column {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<ColumnModel> { $0.id == idString }
        let descriptor = FetchDescriptor<ColumnModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Column with ID \(idString) not found")
        }
        return try model.toDomain()
    }

    public func updateColumn(_ column: Column) async throws {
        let idString = column.id.rawValue.uuidString
        let predicate = #Predicate<ColumnModel> { $0.id == idString }
        let descriptor = FetchDescriptor<ColumnModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Column with ID \(idString) not found")
        }

        model.title = column.title
        model.index = column.index
        model.cardsData = try JSONEncoder().encode(column.cards.map { $0.rawValue.uuidString })
        model.updatedAt = column.updatedAt

        try modelContext.save()
    }

    public func saveColumns(_ columns: [Column]) async throws {
        for column in columns {
            let idString = column.id.rawValue.uuidString
            let predicate = #Predicate<ColumnModel> { $0.id == idString }
            let descriptor = FetchDescriptor<ColumnModel>(predicate: predicate)

            if let model = try modelContext.fetch(descriptor).first {
                // Update existing
                model.title = column.title
                model.index = column.index
                model.cardsData = try JSONEncoder().encode(column.cards.map { $0.rawValue.uuidString })
                model.updatedAt = column.updatedAt
            } else {
                // Insert new
                let model = try ColumnModel(from: column)
                modelContext.insert(model)
            }
        }
        try modelContext.save()
    }

    public func deleteColumn(_ id: ColumnID) async throws {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<ColumnModel> { $0.id == idString }
        let descriptor = FetchDescriptor<ColumnModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Column with ID \(idString) not found")
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    // MARK: - Card Operations

    public func createCard(_ card: Card) async throws {
        let model = try CardModel(from: card)
        modelContext.insert(model)
        try modelContext.save()
    }

    public func loadCards(for columnID: ColumnID) async throws -> [Card] {
        let columnIDString = columnID.rawValue.uuidString
        let predicate = #Predicate<CardModel> { $0.columnID == columnIDString }
        let descriptor = FetchDescriptor<CardModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.sortKey, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.map { try $0.toDomain() }
    }

    public func loadCard(_ id: CardID) async throws -> Card {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<CardModel> { $0.id == idString }
        let descriptor = FetchDescriptor<CardModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Card with ID \(idString) not found")
        }
        return try model.toDomain()
    }

    public func updateCard(_ card: Card) async throws {
        let idString = card.id.rawValue.uuidString
        let predicate = #Predicate<CardModel> { $0.id == idString }
        let descriptor = FetchDescriptor<CardModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Card with ID \(idString) not found")
        }

        model.title = card.title
        model.details = card.details
        model.due = card.due
        model.tagsData = try JSONEncoder().encode(card.tags)
        model.checklistData = try JSONEncoder().encode(card.checklist)
        model.sortKey = card.sortKey
        model.updatedAt = card.updatedAt

        try modelContext.save()
    }

    public func saveCards(_ cards: [Card]) async throws {
        for card in cards {
            let idString = card.id.rawValue.uuidString
            let predicate = #Predicate<CardModel> { $0.id == idString }
            let descriptor = FetchDescriptor<CardModel>(predicate: predicate)

            if let model = try modelContext.fetch(descriptor).first {
                // Update existing
                model.title = card.title
                model.details = card.details
                model.due = card.due
                model.tagsData = try JSONEncoder().encode(card.tags)
                model.checklistData = try JSONEncoder().encode(card.checklist)
                model.sortKey = card.sortKey
                model.updatedAt = card.updatedAt
            } else {
                // Insert new
                let model = try CardModel(from: card)
                modelContext.insert(model)
            }
        }
        try modelContext.save()
    }

    public func deleteCard(_ id: CardID) async throws {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<CardModel> { $0.id == idString }
        let descriptor = FetchDescriptor<CardModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Card with ID \(idString) not found")
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    // MARK: - Query Operations

    public func searchCards(query: String) async throws -> [Card] {
        // SwiftData doesn't have built-in FTS, so we do manual filtering
        let descriptor = FetchDescriptor<CardModel>()
        let models = try modelContext.fetch(descriptor)

        let filtered = models.filter { model in
            model.title.localizedCaseInsensitiveContains(query) ||
            model.details.localizedCaseInsensitiveContains(query)
        }

        let sorted = filtered.sorted { $0.sortKey < $1.sortKey }
        return try sorted.map { try $0.toDomain() }
    }

    public func findCards(byTag tag: String) async throws -> [Card] {
        let descriptor = FetchDescriptor<CardModel>(
            sortBy: [SortDescriptor(\.sortKey, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)

        // Filter by tag
        let filtered = try models.filter { model in
            let tags = try JSONDecoder().decode([String].self, from: model.tagsData)
            return tags.contains(tag)
        }

        return try filtered.map { try $0.toDomain() }
    }

    public func findCards(dueBetween from: Date, and to: Date) async throws -> [Card] {
        let descriptor = FetchDescriptor<CardModel>(
            sortBy: [SortDescriptor(\.due, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)

        // Filter by due date range
        let filtered = models.filter { model in
            guard let due = model.due else { return false }
            return due >= from && due <= to
        }

        return try filtered.map { try $0.toDomain() }
    }
}
