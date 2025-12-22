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
            print("[BoardsRepository] fetch(\(id)) returned nil")
            return nil
        }

        hydrateRelationships(for: board)
        sortRelationships(for: board)
        log(board: board, context: "fetch(id:)")
        return board
    }

    func fetchAll() async throws -> [Board] {
        let boards = try modelContext.fetch(boardFetchDescriptor())
        for board in boards {
            hydrateRelationships(for: board)
            sortRelationships(for: board)
            log(board: board, context: "fetchAll")
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
        // CI repeatedly failed to evaluate relationship predicates (column.board?.id == boardID),
        // so we fetch related models broadly and filter them in-memory for determinism.
        let boardColumns = fetchColumns(forBoardID: board.id)
        board.columns = boardColumns

        for column in board.columns {
            column.board = board
            let cards = fetchCards(forColumnID: column.id)
            column.cards = cards

            for card in column.cards {
                card.column = column
                let checklistItems = fetchChecklistItems(forCardID: card.id)
                card.checklist = checklistItems

                for item in card.checklist {
                    item.card = card
                }
            }
        }
    }

    private func fetchColumns(forBoardID boardID: UUID) -> [Column] {
        let descriptor = FetchDescriptor<Column>(
            sortBy: [SortDescriptor(\Column.index)]
        )

        do {
            return try modelContext
                .fetch(descriptor)
                .filter { $0.board?.id == boardID }
        } catch {
            print("[BoardsRepository] Failed to fetch columns for board \(boardID): \(error)")
            return []
        }
    }

    private func fetchCards(forColumnID columnID: UUID) -> [Card] {
        let descriptor = FetchDescriptor<Card>(
            sortBy: [SortDescriptor(\Card.sortKey)]
        )

        do {
            return try modelContext
                .fetch(descriptor)
                .filter { $0.column?.id == columnID }
        } catch {
            print("[BoardsRepository] Failed to fetch cards for column \(columnID): \(error)")
            return []
        }
    }

    private func fetchChecklistItems(forCardID cardID: UUID) -> [ChecklistItem] {
        let descriptor = FetchDescriptor<ChecklistItem>()

        do {
            return try modelContext
                .fetch(descriptor)
                .filter { $0.card?.id == cardID }
        } catch {
            print("[BoardsRepository] Failed to fetch checklist items for card \(cardID): \(error)")
            return []
        }
    }

    private func log(board: Board, context: String) {
        print("[BoardsRepository] \(context) board=\(board.id) title=\(board.title) columns=\(board.columns.count)")
        for column in board.columns {
            print("  column=\(column.id) title=\(column.title) index=\(column.index) cards=\(column.cards.count)")
            for card in column.cards {
                print(
                    "    card=\(card.id) title=\(card.title) sortKey=\(card.sortKey) checklist=\(card.checklist.count)"
                )
            }
        }
    }
}
