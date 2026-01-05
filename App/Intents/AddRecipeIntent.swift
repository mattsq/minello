// App/Intents/AddRecipeIntent.swift
// App Intent for adding or updating recipes on cards

import AppIntents
import Domain
import PersistenceInterfaces
import UseCases

/// App Intent for adding a recipe to a card
/// Example: "Add Pasta Carbonara recipe to Dinner card on Meal Planning board"
@available(iOS 17.0, macOS 14.0, *)
struct AddRecipeIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Recipe to Card"
    static let description = IntentDescription("Add or update a recipe on a card")

    @Parameter(title: "Recipe Name")
    var recipeName: String

    @Parameter(title: "Board Name")
    var boardName: String

    @Parameter(title: "Card Name")
    var cardName: String

    @Parameter(title: "Ingredients", default: nil)
    var ingredientsText: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$recipeName) to \(\.$cardName) on \(\.$boardName)") {
            \.$ingredientsText
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get repository provider from the app
        guard let provider = await getRepositoryProvider() else {
            throw IntentError.repositoryNotAvailable
        }

        let boardsRepo = provider.boardsRepository
        let recipesRepo = provider.recipesRepository

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
        let allColumns = try await boardsRepo.loadColumns(for: board.id)

        // Load all cards across all columns
        var allCards: [Card] = []
        for column in allColumns {
            let columnCards = try await boardsRepo.loadCards(for: column.id)
            allCards.append(contentsOf: columnCards)
        }

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

        // 4. Parse ingredients text into ChecklistItems
        let ingredients = parseIngredients(ingredientsText ?? "")

        // 5. Load or create the recipe for this card
        var targetRecipe: Recipe
        let (card, existingRecipe) = try await boardsRepo.loadCardWithRecipe(targetCard.id)
        targetCard = card // Update with fresh card data

        if let recipe = existingRecipe {
            // Card already has a recipe - update it
            targetRecipe = recipe
            var updatedRecipe = targetRecipe
            updatedRecipe.title = recipeName
            updatedRecipe.ingredients = ingredients
            updatedRecipe.updatedAt = Date()
            try await recipesRepo.updateRecipe(updatedRecipe)
        } else {
            // Create new recipe for this card
            targetRecipe = Recipe(
                cardID: targetCard.id,
                title: recipeName,
                ingredients: ingredients,
                methodMarkdown: "",
                tags: []
            )
            try await recipesRepo.createRecipe(targetRecipe)

            // Update card's recipeID reference
            var updatedCard = targetCard
            updatedCard.recipeID = targetRecipe.id
            updatedCard.updatedAt = Date()
            try await boardsRepo.saveCards([updatedCard])
        }

        // Return success message
        let ingredientCount = ingredients.count
        let ingredientText = ingredientCount > 0 ? " with \(ingredientCount) ingredients" : ""

        return .result(
            dialog: "Added recipe '\(recipeName)' to \(targetCard.title) on \(board.title)\(ingredientText)"
        )
    }

    @MainActor
    private func getRepositoryProvider() async -> RepositoryProvider? {
        // Access the repository provider from the app's dependency container
        return AppDependencyContainer.shared.repositoryProvider
    }

    /// Parse ingredients text into ChecklistItems
    /// Splits by commas or newlines and creates simple text items
    private func parseIngredients(_ text: String) -> [ChecklistItem] {
        // Split by commas first, then by newlines
        let rawIngredients = text
            .split(whereSeparator: { $0 == "," || $0.isNewline })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return rawIngredients.map { text in
            ChecklistItem(
                text: String(text),
                isDone: false,
                quantity: nil,
                unit: nil
            )
        }
    }
}
