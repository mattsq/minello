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
        let boardID = board.id
        let columnsDescriptor = FetchDescriptor<Column>(
            predicate: #Predicate { column in
                column.board?.id == boardID
            },
            sortBy: [SortDescriptor(\Column.index)]
        )

        guard let fetchedColumns = try? modelContext.fetch(columnsDescriptor) else {
            board.columns = []
            return
        }

        board.columns = fetchedColumns

        for column in board.columns {
            column.board = board

            let columnID = column.id
            let cardsDescriptor = FetchDescriptor<Card>(
                predicate: #Predicate { card in
                    card.column?.id == columnID
                },
                sortBy: [SortDescriptor(\Card.sortKey)]
            )

            guard let fetchedCards = try? modelContext.fetch(cardsDescriptor) else {
                print("[BoardsRepository] No cards fetched for column \(column.id)")
                column.cards = []
                continue
            }

            column.cards = fetchedCards

            for card in column.cards {
                card.column = column

                let cardID = card.id
                let checklistDescriptor = FetchDescriptor<ChecklistItem>(
                    predicate: #Predicate { item in
                        item.card?.id == cardID
                    }
                )

                guard let fetchedItems = try? modelContext.fetch(checklistDescriptor) else {
                    print("[BoardsRepository] No checklist items fetched for card \(card.id)")
                    card.checklist = []
                    continue
                }

                card.checklist = fetchedItems
                for item in card.checklist {
                    item.card = card
                }
            }
        }
    }

    private func log(board: Board, context: String) {
        print("[BoardsRepository] \(context) board=\(board.id) title=\(board.title) columns=\(board.columns.count)")
        for column in board.columns {
            print("  column=\(column.id) title=\(column.title) index=\(column.index) cards=\(column.cards.count)")
            for card in column.cards {
                print("    card=\(card.id) title=\(card.title) sortKey=\(card.sortKey) checklist=\(card.checklist.count)")
            }
        }
    }
}
