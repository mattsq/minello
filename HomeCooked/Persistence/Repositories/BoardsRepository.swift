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
        for column in board.columns {
            modelContext.insert(column)
            for card in column.cards {
                modelContext.insert(card)
                for checklistItem in card.checklist {
                    modelContext.insert(checklistItem)
                }
            }
        }
        try modelContext.save()
    }

    func fetch(id: UUID) async throws -> Board? {
        var descriptor = boardFetchDescriptor()
        descriptor.predicate = #Predicate { $0.id == id }

        guard let board = try modelContext.fetch(descriptor).first else {
            return nil
        }

        hydrateRelationships(for: board)
        sortRelationships(for: board)
        return board
    }

    func fetchAll() async throws -> [Board] {
        let boards = try modelContext.fetch(boardFetchDescriptor())
        boards.forEach {
            hydrateRelationships(for: $0)
            sortRelationships(for: $0)
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

        attachRelationships(for: boardToDelete)

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

    private func boardFetchDescriptor() -> FetchDescriptor<Board> {
        var descriptor = FetchDescriptor<Board>()
        descriptor.includePendingChanges = true
        descriptor.relationshipKeyPathsForPrefetching = [
            \Board.columns,
        ]
        return descriptor
    }

    private func hydrateRelationships(for board: Board) {
        guard let fetchedColumns = try? modelContext.fetch(
            FetchDescriptor<Column>(sortBy: [SortDescriptor(\Column.index)])
        ) else {
            return
        }

        let columns = fetchedColumns.filter { $0.board?.id == board.id }
        board.columns = columns

        for column in board.columns {
            guard let fetchedCards = try? modelContext.fetch(
                FetchDescriptor<Card>(sortBy: [SortDescriptor(\Card.sortKey)])
            ) else {
                column.cards = []
                continue
            }

            let cards = fetchedCards.filter { $0.column?.id == column.id }
            cards.forEach { $0.column = column }
            column.cards = cards

            for card in column.cards {
                guard let fetchedItems = try? modelContext.fetch(FetchDescriptor<ChecklistItem>()) else {
                    card.checklist = []
                    continue
                }

                let items = fetchedItems.filter { $0.card?.id == card.id }
                items.forEach { $0.card = card }
                card.checklist = items
            }
        }
    }
}
