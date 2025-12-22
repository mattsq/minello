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
        // Ensure the object graph is fully connected and manual IDs are populated
        // Insert the root object
        modelContext.insert(board)

        for column in board.columns {
            column.board = board
            column.boardID = board.id
            modelContext.insert(column)
            
            for card in column.cards {
                card.column = column
                card.columnID = column.id
                modelContext.insert(card)
                
                for checklistItem in card.checklist {
                    checklistItem.card = card
                    checklistItem.cardID = card.id
                    modelContext.insert(checklistItem)
                }
            }
        }
        
        try modelContext.save()
        print("[BoardsRepository] create(board:) completed for \(board.id)")
    }

    func fetch(id: UUID) async throws -> Board? {
        var descriptor = boardFetchDescriptor()
        descriptor.predicate = #Predicate { $0.id == id }

        guard let board = try modelContext.fetch(descriptor).first else {
            print("[BoardsRepository] fetch(\(id)) returned nil")
            return nil
        }

        sortRelationships(for: board)

        print("[BoardsRepository] fetch(id:) found board \(board.id) with \(board.columns.count) columns")
        return board
    }

    func fetchAll() async throws -> [Board] {
        let boards = try modelContext.fetch(boardFetchDescriptor())
        for board in boards {
            sortRelationships(for: board)
        }
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

        modelContext.delete(boardToDelete)
        try modelContext.save()
    }

    private func boardFetchDescriptor() -> FetchDescriptor<Board> {
        var descriptor = FetchDescriptor<Board>()
        descriptor.includePendingChanges = true
        descriptor.relationshipKeyPathsForPrefetching = [
            \Board.columns,
        ]
        return descriptor
    }
}
