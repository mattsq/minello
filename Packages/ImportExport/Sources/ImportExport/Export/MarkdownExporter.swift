// ImportExport/Sources/ImportExport/Export/MarkdownExporter.swift
// Exports HomeCooked data to Markdown format

import Domain
import Foundation
import PersistenceInterfaces

/// Result of a markdown export operation
public struct MarkdownExportResult: Sendable {
    public let boardsExported: Int
    public let columnsExported: Int
    public let cardsExported: Int
    public let recipesExported: Int
    public let listsExported: Int

    public init(
        boardsExported: Int,
        columnsExported: Int,
        cardsExported: Int,
        recipesExported: Int,
        listsExported: Int
    ) {
        self.boardsExported = boardsExported
        self.columnsExported = columnsExported
        self.cardsExported = cardsExported
        self.recipesExported = recipesExported
        self.listsExported = listsExported
    }

    public var summary: String {
        """
        Markdown Export Summary:
          Boards: \(boardsExported)
          Columns: \(columnsExported)
          Cards: \(cardsExported)
          Recipes: \(recipesExported)
          Lists: \(listsExported)
        """
    }
}

/// Exports HomeCooked data to Markdown format
public actor MarkdownExporter {
    private let boardsRepository: BoardsRepository
    private let recipesRepository: RecipesRepository
    private let listsRepository: ListsRepository

    /// Creates a new markdown exporter
    ///
    /// - Parameters:
    ///   - boardsRepository: The boards repository to read from
    ///   - recipesRepository: The recipes repository to read from
    ///   - listsRepository: The lists repository to read from
    public init(
        boardsRepository: BoardsRepository,
        recipesRepository: RecipesRepository,
        listsRepository: ListsRepository
    ) {
        self.boardsRepository = boardsRepository
        self.recipesRepository = recipesRepository
        self.listsRepository = listsRepository
    }

    /// Exports a single board to markdown
    ///
    /// - Parameter boardID: The board ID to export
    /// - Returns: Markdown string representation
    /// - Throws: Persistence errors
    public func exportBoard(_ boardID: BoardID) async throws -> String {
        let board = try await boardsRepository.loadBoard(boardID)
        let columns = try await boardsRepository.loadColumns(for: boardID)

        var markdown = "# \(board.title)\n\n"
        markdown += "_Created: \(formatDate(board.createdAt))_\n\n"

        if !board.columns.isEmpty {
            markdown += "---\n\n"
        }

        var totalCards = 0
        var totalRecipes = 0
        var totalLists = 0

        for column in columns.sorted(by: { $0.index < $1.index }) {
            let cards = try await boardsRepository.loadCards(for: column.id)
            totalCards += cards.count

            markdown += "## \(column.title)\n\n"

            if cards.isEmpty {
                markdown += "_No cards_\n\n"
            } else {
                for card in cards.sorted(by: { $0.sortKey < $1.sortKey }) {
                    let (recipeCount, listCount) = try await exportCard(card, to: &markdown)
                    totalRecipes += recipeCount
                    totalLists += listCount
                }
            }
        }

        return markdown
    }

    /// Exports all boards to markdown
    ///
    /// - Returns: Markdown string representation of all boards
    /// - Throws: Persistence errors
    public func exportAll() async throws -> String {
        let boards = try await boardsRepository.loadBoards()

        var markdown = "# HomeCooked Export\n\n"
        markdown += "_Exported: \(formatDate(Date()))_\n\n"
        markdown += "**Total Boards:** \(boards.count)\n\n"
        markdown += "---\n\n"

        for board in boards {
            let boardMarkdown = try await exportBoard(board.id)
            markdown += boardMarkdown
            markdown += "\n---\n\n"
        }

        return markdown
    }

    /// Exports to a markdown file
    ///
    /// - Parameter url: The destination file URL
    /// - Returns: Export result with counts
    /// - Throws: Persistence or file system errors
    public func exportToFile(_ url: URL) async throws -> MarkdownExportResult {
        let boards = try await boardsRepository.loadBoards()
        let markdown = try await exportAll()

        try markdown.write(to: url, atomically: true, encoding: .utf8)

        // Calculate statistics
        var totalColumns = 0
        var totalCards = 0
        var totalRecipes = 0
        var totalLists = 0

        for board in boards {
            let columns = try await boardsRepository.loadColumns(for: board.id)
            totalColumns += columns.count

            for column in columns {
                let cards = try await boardsRepository.loadCards(for: column.id)
                totalCards += cards.count

                for card in cards {
                    if card.recipeID != nil {
                        totalRecipes += 1
                    }
                    if card.listID != nil {
                        totalLists += 1
                    }
                }
            }
        }

        return MarkdownExportResult(
            boardsExported: boards.count,
            columnsExported: totalColumns,
            cardsExported: totalCards,
            recipesExported: totalRecipes,
            listsExported: totalLists
        )
    }

    /// Exports a board to a markdown file
    ///
    /// - Parameters:
    ///   - boardID: The board to export
    ///   - url: The destination file URL
    /// - Returns: Export result with counts
    /// - Throws: Persistence or file system errors
    public func exportBoardToFile(_ boardID: BoardID, to url: URL) async throws -> MarkdownExportResult {
        let markdown = try await exportBoard(boardID)
        try markdown.write(to: url, atomically: true, encoding: .utf8)

        // Calculate statistics for this board
        let columns = try await boardsRepository.loadColumns(for: boardID)
        var totalCards = 0
        var totalRecipes = 0
        var totalLists = 0

        for column in columns {
            let cards = try await boardsRepository.loadCards(for: column.id)
            totalCards += cards.count

            for card in cards {
                if card.recipeID != nil {
                    totalRecipes += 1
                }
                if card.listID != nil {
                    totalLists += 1
                }
            }
        }

        return MarkdownExportResult(
            boardsExported: 1,
            columnsExported: columns.count,
            cardsExported: totalCards,
            recipesExported: totalRecipes,
            listsExported: totalLists
        )
    }

    // MARK: - Private Helpers

    /// Exports a single card to markdown, appending to the provided string
    /// Returns tuple of (recipes exported, lists exported)
    private func exportCard(_ card: Card, to markdown: inout String) async throws -> (Int, Int) {
        var recipesExported = 0
        var listsExported = 0

        markdown += "### \(card.title)\n\n"

        // Card metadata
        if let due = card.due {
            markdown += "📅 **Due:** \(formatDate(due))\n\n"
        }

        if !card.tags.isEmpty {
            markdown += "🏷️ **Tags:** \(card.tags.joined(separator: ", "))\n\n"
        }

        // Card details
        if !card.details.isEmpty {
            markdown += "\(card.details)\n\n"
        }

        // Card checklist
        if !card.checklist.isEmpty {
            markdown += "**Checklist:**\n\n"
            for item in card.checklist {
                let checkbox = item.isDone ? "[x]" : "[ ]"
                markdown += "- \(checkbox) \(item.text)"
                if let quantity = item.quantity, let unit = item.unit {
                    markdown += " (\(formatQuantity(quantity)) \(unit))"
                }
                if let note = item.note, !note.isEmpty {
                    markdown += " - _\(note)_"
                }
                markdown += "\n"
            }
            markdown += "\n"
        }

        // Attached recipe
        if card.recipeID != nil {
            if let recipe = try await recipesRepository.loadForCard(card.id) {
                try await exportRecipe(recipe, to: &markdown)
                recipesExported = 1
            }
        }

        // Attached list
        if card.listID != nil {
            if let list = try await listsRepository.loadForCard(card.id) {
                exportList(list, to: &markdown)
                listsExported = 1
            }
        }

        markdown += "\n"

        return (recipesExported, listsExported)
    }

    /// Exports a recipe to markdown, appending to the provided string
    private func exportRecipe(_ recipe: Recipe, to markdown: inout String) async throws {
        markdown += "#### 🍳 Recipe: \(recipe.title)\n\n"

        if !recipe.tags.isEmpty {
            markdown += "**Tags:** \(recipe.tags.joined(separator: ", "))\n\n"
        }

        if !recipe.ingredients.isEmpty {
            markdown += "**Ingredients:**\n\n"
            for ingredient in recipe.ingredients {
                markdown += "- "
                if let quantity = ingredient.quantity, let unit = ingredient.unit {
                    markdown += "\(formatQuantity(quantity)) \(unit) "
                }
                markdown += ingredient.text
                if let note = ingredient.note, !note.isEmpty {
                    markdown += " - _\(note)_"
                }
                markdown += "\n"
            }
            markdown += "\n"
        }

        if !recipe.methodMarkdown.isEmpty {
            markdown += "**Method:**\n\n"
            markdown += "\(recipe.methodMarkdown)\n\n"
        }
    }

    /// Exports a personal list to markdown, appending to the provided string
    private func exportList(_ list: PersonalList, to markdown: inout String) {
        markdown += "#### 📝 List: \(list.title)\n\n"

        if !list.items.isEmpty {
            for item in list.items {
                let checkbox = item.isDone ? "[x]" : "[ ]"
                markdown += "- \(checkbox) "
                if let quantity = item.quantity, let unit = item.unit {
                    markdown += "\(formatQuantity(quantity)) \(unit) "
                }
                markdown += item.text
                if let note = item.note, !note.isEmpty {
                    markdown += " - _\(note)_"
                }
                markdown += "\n"
            }
            markdown += "\n"
        } else {
            markdown += "_No items_\n\n"
        }
    }

    /// Formats a date for markdown output
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Formats a quantity value, removing unnecessary decimal places
    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(quantity))
        } else {
            // Format with up to 2 decimal places, removing trailing zeros
            let formatted = String(format: "%.2f", quantity)
            // Remove trailing zeros and decimal point if not needed
            return formatted.replacingOccurrences(of: #"\.?0+$"#, with: "", options: .regularExpression)
        }
    }
}
