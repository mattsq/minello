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
        log(board: board, context: "create(board:)")
        logColumnStoreSnapshot(context: "post-create")
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
        let boardColumns = fetchColumns(for: board)
        board.columns = boardColumns

        for column in board.columns {
            column.board = board
            let cards = fetchCards(for: column)
            column.cards = cards

            for card in column.cards {
                card.column = column
                let checklistItems = fetchChecklistItems(for: card)
                card.checklist = checklistItems

                for item in card.checklist {
                    item.card = card
                }
            }
        }
    }

    private func fetchColumns(for board: Board) -> [Column] {
        let boardModelID = board.persistentModelID

        var descriptor = FetchDescriptor<Column>(
            sortBy: [SortDescriptor(\Column.index)]
        )
        descriptor.includePendingChanges = true

        do {
            let fetched = try modelContext.fetch(descriptor)
            print(
                "[BoardsRepository] fetchColumns board=\(board.id) boardModelID=\(boardModelID) fetched=\(fetched.count)"
            )
            for column in fetched {
                let parentID = column.board?.id.uuidString ?? "nil"
                let parentModelID = describeIdentifier(column.board?.persistentModelID)
                print(
                    "  column candidate id=\(column.id) boardID=\(parentID) boardModelID=\(parentModelID)"
                )
            }
            let filtered = fetched.filter {
                $0.board?.persistentModelID == boardModelID
            }
            print(
                "[BoardsRepository] fetchColumns board=\(board.id) matched=\(filtered.count)"
            )
            return filtered
        } catch {
            print("[BoardsRepository] Failed to fetch columns for board \(board.id): \(error)")
            return []
        }
    }

    private func fetchCards(for column: Column) -> [Card] {
        let columnModelID = column.persistentModelID

        var descriptor = FetchDescriptor<Card>(
            sortBy: [SortDescriptor(\Card.sortKey)]
        )
        descriptor.includePendingChanges = true

        do {
            let fetched = try modelContext.fetch(descriptor)
            print(
                "[BoardsRepository] fetchCards column=\(column.id) columnModelID=\(columnModelID) fetched=\(fetched.count)"
            )
            for card in fetched {
                let parentID = card.column?.id.uuidString ?? "nil"
                let parentModelID = describeIdentifier(card.column?.persistentModelID)
                print(
                    "  card candidate id=\(card.id) columnID=\(parentID) columnModelID=\(parentModelID)"
                )
            }
            let filtered = fetched.filter {
                $0.column?.persistentModelID == columnModelID
            }
            print(
                "[BoardsRepository] fetchCards column=\(column.id) matched=\(filtered.count)"
            )
            return filtered
        } catch {
            print("[BoardsRepository] Failed to fetch cards for column \(column.id): \(error)")
            return []
        }
    }

    private func fetchChecklistItems(for card: Card) -> [ChecklistItem] {
        let cardModelID = card.persistentModelID

        var descriptor = FetchDescriptor<ChecklistItem>()
        descriptor.includePendingChanges = true

        do {
            let fetched = try modelContext.fetch(descriptor)
            print(
                "[BoardsRepository] fetchChecklist card=\(card.id) cardModelID=\(cardModelID) fetched=\(fetched.count)"
            )
            for item in fetched {
                let parentID = item.card?.id.uuidString ?? "nil"
                let parentModelID = describeIdentifier(item.card?.persistentModelID)
                print(
                    "  checklist candidate id=\(item.id) cardID=\(parentID) cardModelID=\(parentModelID)"
                )
            }
            let filtered = fetched.filter {
                $0.card?.persistentModelID == cardModelID
            }
            print(
                "[BoardsRepository] fetchChecklist card=\(card.id) matched=\(filtered.count)"
            )
            return filtered
        } catch {
            print("[BoardsRepository] Failed to fetch checklist items for card \(card.id): \(error)")
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

    private func logColumnStoreSnapshot(context: String) {
        var descriptor = FetchDescriptor<Column>(sortBy: [SortDescriptor(\Column.index)])
        descriptor.includePendingChanges = true
        guard let columns = try? modelContext.fetch(descriptor) else {
            print("[BoardsRepository] \(context) column snapshot unavailable")
            return
        }
        print("[BoardsRepository] \(context) totalColumns=\(columns.count)")
        for column in columns {
            let boardID = column.board?.id.uuidString ?? "nil"
            let boardModelID = describeIdentifier(column.board?.persistentModelID)
            print("  stored column id=\(column.id) boardID=\(boardID) boardModelID=\(boardModelID)")
        }
    }

    private func describeIdentifier(_ identifier: PersistentIdentifier?) -> String {
        guard let identifier else {
            return "nil"
        }
        return String(describing: identifier)
    }
}
