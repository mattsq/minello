import Foundation
import SwiftData

@MainActor
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
        attachRelationships(for: board)
        modelContext.insert(board)
        try modelContext.save()
    }

    func fetch(id: UUID) async throws -> Board? {
        let descriptor = FetchDescriptor<Board>()
        guard let board = try modelContext.fetch(descriptor).first(where: { $0.id == id }) else {
            return nil
        }
        sortRelationships(for: board)
        return board
    }

    func fetchAll() async throws -> [Board] {
        let descriptor = FetchDescriptor<Board>()
        let boards = try modelContext.fetch(descriptor)
        boards.forEach { sortRelationships(for: $0) }
        return boards.sorted { $0.updatedAt > $1.updatedAt }
    }

    private func sortRelationships(for board: Board) {
        board.columns.sort { $0.index < $1.index }
        for column in board.columns {
            column.cards.sort { $0.sortKey < $1.sortKey }
        }
    }

    func update(board: Board) async throws {
        board.updatedAt = Date()
        try modelContext.save()
    }

    func delete(board: Board) async throws {
        guard let boardToDelete = try await fetch(id: board.id) else {
            return
        }

        attachRelationships(for: boardToDelete)

        let columns = boardToDelete.columns
        for column in columns {
            let cards = column.cards
            for card in cards {
                modelContext.delete(card)
            }
            modelContext.delete(column)
        }

        modelContext.delete(boardToDelete)
        try modelContext.save()
    }

    private func attachRelationships(for board: Board) {
        for column in board.columns {
            column.board = board
            for card in column.cards {
                card.column = column
                for checklistItem in card.checklist {
                    checklistItem.card = card
                }
            }
        }
    }
}
