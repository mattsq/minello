// ImportExport/Sources/ImportExport/Trello/TrelloMapper.swift
// Maps Trello export structures to Domain models

import Domain
import Foundation

/// Maps Trello JSON structures to Domain models
public enum TrelloMapper {
    /// Maps a Trello export to a Board with Columns and Cards
    ///
    /// - Parameter export: The decoded Trello export
    /// - Returns: Tuple of (Board, [Column], [Card])
    public static func map(_ export: TrelloExport) -> (board: Board, columns: [Column], cards: [Card]) {
        // Create board ID
        let boardID = BoardID()
        let now = Date()

        // Map lists to columns, filtering out closed lists
        let activeLists = export.lists.filter { list in
            !(list.closed ?? false)
        }

        // Sort lists by position
        let sortedLists = activeLists.sorted { ($0.pos ?? 0) < ($1.pos ?? 0) }

        // Create a map of Trello list ID to our Column ID
        var listIDMap: [String: ColumnID] = [:]

        let columns: [Column] = sortedLists.enumerated().map { index, list in
            let columnID = ColumnID()
            listIDMap[list.id] = columnID

            return Column(
                id: columnID,
                board: boardID,
                title: list.name,
                index: index,
                cards: [], // Will be populated when we process cards
                createdAt: now,
                updatedAt: now
            )
        }

        // Map cards, filtering out closed cards and cards in closed lists
        let activeCards = export.cards.filter { card in
            !(card.closed ?? false) && listIDMap[card.idList] != nil
        }

        // Group cards by list ID and sort by position
        var cardsByList: [String: [TrelloCard]] = [:]
        for card in activeCards {
            cardsByList[card.idList, default: []].append(card)
        }

        // Sort cards within each list
        for listID in cardsByList.keys {
            cardsByList[listID] = cardsByList[listID]?.sorted { ($0.pos ?? 0) < ($1.pos ?? 0) }
        }

        // Create cards with proper sort keys
        var cards: [Card] = []
        var columnCardMap: [ColumnID: [CardID]] = [:]

        for (listID, cardsInList) in cardsByList {
            guard let columnID = listIDMap[listID] else { continue }

            for (index, trelloCard) in cardsInList.enumerated() {
                let cardID = CardID()

                // Map labels to tags
                let tags = mapLabels(trelloCard.labels ?? [])

                // Map checklists to checklist items
                let checklist = mapChecklists(trelloCard.checklists ?? [])

                // Parse due date
                let dueDate = parseDueDate(trelloCard.due)

                let card = Card(
                    id: cardID,
                    column: columnID,
                    title: trelloCard.name,
                    details: trelloCard.desc ?? "",
                    due: dueDate,
                    tags: tags,
                    checklist: checklist,
                    sortKey: Double(index),
                    createdAt: now,
                    updatedAt: now
                )

                cards.append(card)
                columnCardMap[columnID, default: []].append(cardID)
            }
        }

        // Update columns with card IDs
        let updatedColumns = columns.map { column in
            var updated = column
            updated.cards = columnCardMap[column.id] ?? []
            return updated
        }

        // Create board with column IDs
        let columnIDs = updatedColumns.map { $0.id }
        let board = Board(
            id: boardID,
            title: export.name,
            columns: columnIDs,
            createdAt: now,
            updatedAt: now
        )

        return (board, updatedColumns, cards)
    }

    /// Maps Trello labels to sanitized tags
    private static func mapLabels(_ labels: [TrelloLabel]) -> [String] {
        var tags: [String] = []

        for label in labels {
            // Prefer label name, fall back to color
            if let name = label.name, !name.isEmpty {
                tags.append(name)
            } else if let color = label.color, !color.isEmpty {
                tags.append(color)
            }
        }

        // Sanitize tags using Domain helper
        return TagHelpers.sanitize(tags)
    }

    /// Maps Trello checklists to checklist items
    private static func mapChecklists(_ checklists: [TrelloChecklist]) -> [ChecklistItem] {
        var items: [ChecklistItem] = []

        for checklist in checklists {
            // Sort check items by position
            let sortedItems = checklist.checkItems.sorted { ($0.pos ?? 0) < ($1.pos ?? 0) }

            for checkItem in sortedItems {
                let isDone = checkItem.state == "complete"

                let item = ChecklistItem(
                    id: UUID(),
                    text: checkItem.name,
                    isDone: isDone,
                    quantity: nil,
                    unit: nil,
                    note: checklist.name // Store checklist name as note if present
                )

                items.append(item)
            }
        }

        return items
    }

    /// Parses Trello due date string to Date
    /// Trello uses ISO8601 format: "2024-12-31T23:59:59.999Z"
    private static func parseDueDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            return date
        }

        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }
}
