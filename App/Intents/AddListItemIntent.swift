// App/Intents/AddListItemIntent.swift
// App Intent for adding items to personal lists

import AppIntents
import Domain
import PersistenceInterfaces
import UseCases

/// App Intent for adding an item to a card's list
/// Example: "Add milk to Shopping card on Home board"
@available(iOS 17.0, macOS 14.0, *)
struct AddListItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Item to Card List"
    static let description = IntentDescription("Add an item to a card's list on a board")

    @Parameter(title: "Item Name")
    var itemName: String

    @Parameter(title: "Board Name")
    var boardName: String

    @Parameter(title: "Card Name")
    var cardName: String

    @Parameter(title: "Quantity", default: nil)
    var quantity: Double?

    @Parameter(title: "Unit", default: nil)
    var unit: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$itemName) to \(\.$cardName) on \(\.$boardName)") {
            \.$quantity
            \.$unit
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get repository provider from the app
        guard let provider = await getRepositoryProvider() else {
            throw IntentError.repositoryNotAvailable
        }

        let boardsRepo = provider.boardsRepository
        let listsRepo = provider.listsRepository

        // 1. Load all boards and find the target board
        let allBoards = try await boardsRepo.loadBoards()
        guard let board = EntityLookup.findBestBoard(
            query: boardName,
            in: allBoards,
            threshold: 0.5
        ) else {
            throw IntentError.boardNotFound(boardName)
        }

        // 2. Load columns and cards for this board
        let allColumns = try await boardsRepo.loadColumns(forBoard: board.id)
        let allCards = try await boardsRepo.loadCards(forBoard: board.id)

        // 3. Find the card (or create it if not found)
        var targetCard: Card
        var targetColumn: Column

        if let cardResult = EntityLookup.findBestCard(
            query: cardName,
            inBoard: board,
            columns: allColumns,
            cards: allCards,
            threshold: 0.5
        ) {
            // Card found
            targetCard = cardResult.card
            targetColumn = cardResult.column
        } else {
            // Card not found - create it on the first column
            guard let firstColumn = allColumns.first else {
                throw IntentError.noColumnsInBoard(board.title)
            }
            targetColumn = firstColumn

            // Calculate sort key for new card (append to end of column)
            let cardsInColumn = allCards.filter { $0.column == firstColumn.id }
            let maxSortKey = cardsInColumn.map { $0.sortKey }.max() ?? 0
            let newSortKey = maxSortKey + 1

            targetCard = Card(
                column: firstColumn.id,
                title: cardName,
                details: "",
                sortKey: newSortKey
            )
            try await boardsRepo.saveCards([targetCard])
        }

        // 4. Load or create the list for this card
        var targetList: PersonalList
        let (card, existingList) = try await boardsRepo.loadCardWithList(targetCard.id)
        targetCard = card // Update with fresh card data

        if let list = existingList {
            // Card already has a list
            targetList = list
        } else {
            // Create new list for this card
            targetList = PersonalList(
                cardID: targetCard.id,
                title: "\(targetCard.title) List"
            )
            try await listsRepo.createList(targetList)

            // Update card's listID reference
            var updatedCard = targetCard
            updatedCard.listID = targetList.id
            updatedCard.updatedAt = Date()
            try await boardsRepo.saveCards([updatedCard])
        }

        // 5. Create the new checklist item
        let newItem = ChecklistItem(
            text: itemName,
            isDone: false,
            quantity: quantity,
            unit: unit
        )

        // 6. Update the list with the new item
        var updatedList = targetList
        updatedList.items.append(newItem)
        updatedList.updatedAt = Date()

        try await listsRepo.updateList(updatedList)

        // Return success message
        let quantityText = quantity.map { q in
            let unitText = unit.map { " \($0)" } ?? ""
            return "\(q)\(unitText) "
        } ?? ""

        return .result(
            dialog: "Added \(quantityText)\(itemName) to \(targetCard.title) on \(board.title)"
        )
    }

    @MainActor
    private func getRepositoryProvider() async -> RepositoryProvider? {
        // Access the repository provider from the app's dependency container
        // This assumes AppDependencyContainer is set up as a singleton or accessible
        return AppDependencyContainer.shared.repositoryProvider
    }
}

/// Errors that can occur during intent execution
enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case repositoryNotAvailable
    case listNotFound(String)
    case boardNotFound(String)
    case columnNotFound(String, String)
    case noColumnsInBoard(String)
    case cardNotFound(String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .repositoryNotAvailable:
            return "Repository is not available"
        case .listNotFound(let name):
            return "Could not find a list matching '\(name)'"
        case .boardNotFound(let name):
            return "Could not find a board matching '\(name)'"
        case .columnNotFound(let columnName, let boardName):
            return "Could not find column '\(columnName)' in board '\(boardName)'"
        case .noColumnsInBoard(let boardName):
            return "Board '\(boardName)' has no columns"
        case .cardNotFound(let name):
            return "Could not find a card matching '\(name)'"
        }
    }
}
