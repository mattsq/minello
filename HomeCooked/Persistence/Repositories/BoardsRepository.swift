import Foundation
import SwiftData

protocol BoardsRepository {
    func create(board: Board) async throws
    func fetch(id: UUID) async throws -> Board?
    func fetchAll() async throws -> [Board]
    func update(board: Board) async throws
    func delete(board: Board) async throws
}

@MainActor
final class SwiftDataBoardsRepository: BoardsRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(board: Board) async throws {
        linkRelationships(for: board)
        modelContext.insert(board)
        try modelContext.save()
    }

    func fetch(id: UUID) async throws -> Board? {
        let descriptor = FetchDescriptor<Board>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchAll() async throws -> [Board] {
        let descriptor = FetchDescriptor<Board>(
            sortBy: [SortDescriptor(\Board.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    func update(board: Board) async throws {
        board.updatedAt = Date()
        try modelContext.save()
    }

    func delete(board: Board) async throws {
        modelContext.delete(board)
        try modelContext.save()
    }

    private func linkRelationships(for board: Board) {
        for column in board.columns {
            column.board = board
            for card in column.cards {
                card.column = column
                for item in card.checklist {
                    item.card = card
                }
            }
        }
    }
}
