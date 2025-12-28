// App/Intents/AddCardIntent.swift
// App Intent for adding cards to boards

import AppIntents
import Domain
import PersistenceInterfaces
import UseCases

/// App Intent for adding a card to a board's column
/// Example: "Add 'Pay strata' to 'Home' → 'To Do'"
@available(iOS 17.0, macOS 14.0, *)
struct AddCardIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Card to Board"
    static let description = IntentDescription("Add a card to a specific column on a board")

    @Parameter(title: "Card Title")
    var cardTitle: String

    @Parameter(title: "Board Name")
    var boardName: String

    @Parameter(title: "Column Name")
    var columnName: String

    @Parameter(title: "Details")
    var details: String?

    @Parameter(title: "Due Date")
    var dueDate: Date?

    static var parameterSummary: some ParameterSummary {
        Summary("Add '\(\.$cardTitle)' to \(\.$boardName) → \(\.$columnName)") {
            \.$details
            \.$dueDate
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get repository provider from the app
        guard let provider = await getRepositoryProvider() else {
            throw IntentError.repositoryNotAvailable
        }

        let boardsRepo = provider.boardsRepository

        // Load all boards
        let allBoards = try await boardsRepo.loadBoards()

        // Find the best matching board using fuzzy lookup
        guard let targetBoard = EntityLookup.findBestBoard(
            query: boardName,
            in: allBoards,
            threshold: 0.5
        ) else {
            throw IntentError.boardNotFound(boardName)
        }

        // Load columns for the board
        let columns = try await boardsRepo.loadColumns(for: targetBoard.id)

        // Find the best matching column using fuzzy lookup
        guard let columnResult = EntityLookup.findBestColumn(
            query: columnName,
            in: columns,
            boards: [targetBoard],
            threshold: 0.5
        ) else {
            throw IntentError.columnNotFound(columnName, targetBoard.title)
        }

        let targetColumn = columnResult.column

        // Load existing cards in the column to determine sort key
        let existingCards = try await boardsRepo.loadCards(for: targetColumn.id)
        let maxSortKey = existingCards.map(\.sortKey).max() ?? 0
        let newSortKey = maxSortKey + 1

        // Create the new card
        let newCard = Card(
            column: targetColumn.id,
            title: cardTitle,
            details: details ?? "",
            due: dueDate,
            sortKey: newSortKey
        )

        try await boardsRepo.createCard(newCard)

        // Return success message
        let dueText = dueDate.map { date in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return ", due \(formatter.string(from: date))"
        } ?? ""

        return .result(
            dialog: "Added '\(cardTitle)' to \(targetBoard.title) → \(targetColumn.title)\(dueText)"
        )
    }

    @MainActor
    private func getRepositoryProvider() async -> RepositoryProvider? {
        // Access the repository provider from the app's dependency container
        AppDependencyContainer.shared.repositoryProvider
    }
}
