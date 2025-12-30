// Tests/ImportExportTests/TestHelpers.swift
// Shared test helpers for ImportExport tests

import Domain
import Foundation
import PersistenceInterfaces

/// In-memory boards repository for testing
final class InMemoryBoardsRepository: BoardsRepository {
    private var boards: [BoardID: Board] = [:]
    private var columns: [ColumnID: Column] = [:]
    private var cards: [CardID: Card] = [:]

    // MARK: - Board Operations

    func createBoard(_ board: Board) async throws {
        boards[board.id] = board
    }

    func loadBoards() async throws -> [Board] {
        Array(boards.values).sorted { $0.createdAt < $1.createdAt }
    }

    func loadBoard(_ id: BoardID) async throws -> Board {
        guard let board = boards[id] else {
            throw PersistenceError.notFound("Board with ID \(id)")
        }
        return board
    }

    func updateBoard(_ board: Board) async throws {
        guard boards[board.id] != nil else {
            throw PersistenceError.notFound("Board with ID \(board.id)")
        }
        boards[board.id] = board
    }

    func deleteBoard(_ id: BoardID) async throws {
        boards.removeValue(forKey: id)
        let boardColumns = columns.values.filter { $0.board == id }
        for column in boardColumns {
            try await deleteColumn(column.id)
        }
    }

    // MARK: - Column Operations

    func createColumn(_ column: Column) async throws {
        columns[column.id] = column
    }

    func loadColumns(for boardID: BoardID) async throws -> [Column] {
        columns.values
            .filter { $0.board == boardID }
            .sorted { $0.index < $1.index }
    }

    func loadColumn(_ id: ColumnID) async throws -> Column {
        guard let column = columns[id] else {
            throw PersistenceError.notFound("Column with ID \(id)")
        }
        return column
    }

    func updateColumn(_ column: Column) async throws {
        guard columns[column.id] != nil else {
            throw PersistenceError.notFound("Column with ID \(column.id)")
        }
        columns[column.id] = column
    }

    func saveColumns(_ columns: [Column]) async throws {
        for column in columns {
            self.columns[column.id] = column
        }
    }

    func deleteColumn(_ id: ColumnID) async throws {
        columns.removeValue(forKey: id)
        let columnCards = cards.values.filter { $0.column == id }
        for card in columnCards {
            try await deleteCard(card.id)
        }
    }

    // MARK: - Card Operations

    func createCard(_ card: Card) async throws {
        cards[card.id] = card
    }

    func loadCards(for columnID: ColumnID) async throws -> [Card] {
        cards.values
            .filter { $0.column == columnID }
            .sorted { $0.sortKey < $1.sortKey }
    }

    func loadCard(_ id: CardID) async throws -> Card {
        guard let card = cards[id] else {
            throw PersistenceError.notFound("Card with ID \(id)")
        }
        return card
    }

    func updateCard(_ card: Card) async throws {
        guard cards[card.id] != nil else {
            throw PersistenceError.notFound("Card with ID \(card.id)")
        }
        cards[card.id] = card
    }

    func saveCards(_ cards: [Card]) async throws {
        for card in cards {
            self.cards[card.id] = card
        }
    }

    func deleteCard(_ id: CardID) async throws {
        cards.removeValue(forKey: id)
    }

    // MARK: - Query Operations

    func searchCards(query: String) async throws -> [Card] {
        let lowercaseQuery = query.lowercased()
        return cards.values.filter {
            $0.title.lowercased().contains(lowercaseQuery) ||
            $0.details.lowercased().contains(lowercaseQuery)
        }
    }

    func findCards(byTag tag: String) async throws -> [Card] {
        cards.values.filter { $0.tags.contains(tag) }
    }

    func findCards(dueBetween from: Date, and to: Date) async throws -> [Card] {
        cards.values.filter { card in
            guard let due = card.due else { return false }
            return due >= from && due <= to
        }
    }

    // MARK: - Card-Centric Query Operations

    func loadCardWithRecipe(_ cardID: CardID) async throws -> (Card, Recipe?) {
        let card = try await loadCard(cardID)
        return (card, nil)
    }

    func loadCardWithList(_ cardID: CardID) async throws -> (Card, PersonalList?) {
        let card = try await loadCard(cardID)
        return (card, nil)
    }

    func findCardsWithRecipes(boardID: BoardID?) async throws -> [Card] {
        if let boardID = boardID {
            let boardColumns = columns.values.filter { $0.board == boardID }
            let columnIDs = Set(boardColumns.map { $0.id })
            return cards.values.filter { columnIDs.contains($0.column) && $0.recipeID != nil }
        }
        return cards.values.filter { $0.recipeID != nil }
    }

    func findCardsWithLists(boardID: BoardID?) async throws -> [Card] {
        if let boardID = boardID {
            let boardColumns = columns.values.filter { $0.board == boardID }
            let columnIDs = Set(boardColumns.map { $0.id })
            return cards.values.filter { columnIDs.contains($0.column) && $0.listID != nil }
        }
        return cards.values.filter { $0.listID != nil }
    }
}

/// In-memory lists repository for testing
final class InMemoryListsRepository: ListsRepository {
    private var lists: [ListID: PersonalList] = [:]

    func createList(_ list: PersonalList) async throws {
        lists[list.id] = list
    }

    func loadLists() async throws -> [PersonalList] {
        Array(lists.values).sorted { $0.createdAt < $1.createdAt }
    }

    func loadList(_ id: ListID) async throws -> PersonalList {
        guard let list = lists[id] else {
            throw PersistenceError.notFound("List with ID \(id)")
        }
        return list
    }

    func updateList(_ list: PersonalList) async throws {
        guard lists[list.id] != nil else {
            throw PersistenceError.notFound("List with ID \(list.id)")
        }
        lists[list.id] = list
    }

    func deleteList(_ id: ListID) async throws {
        lists.removeValue(forKey: id)
    }

    func searchLists(query: String) async throws -> [PersonalList] {
        let lowercaseQuery = query.lowercased()
        return lists.values.filter {
            $0.title.lowercased().contains(lowercaseQuery)
        }
    }

    func findListsWithIncompleteItems() async throws -> [PersonalList] {
        lists.values.filter { list in
            list.items.contains { !$0.isDone }
        }
    }

    func loadForCard(_ cardID: CardID) async throws -> PersonalList? {
        lists.values.first { $0.cardID == cardID }
    }
}

/// In-memory recipes repository for testing
final class InMemoryRecipesRepository: RecipesRepository {
    private var recipes: [RecipeID: Recipe] = [:]

    func createRecipe(_ recipe: Recipe) async throws {
        recipes[recipe.id] = recipe
    }

    func loadRecipes() async throws -> [Recipe] {
        Array(recipes.values).sorted { $0.createdAt < $1.createdAt }
    }

    func loadRecipe(_ id: RecipeID) async throws -> Recipe {
        guard let recipe = recipes[id] else {
            throw PersistenceError.notFound("Recipe with ID \(id)")
        }
        return recipe
    }

    func updateRecipe(_ recipe: Recipe) async throws {
        guard recipes[recipe.id] != nil else {
            throw PersistenceError.notFound("Recipe with ID \(recipe.id)")
        }
        recipes[recipe.id] = recipe
    }

    func deleteRecipe(_ id: RecipeID) async throws {
        recipes.removeValue(forKey: id)
    }

    func searchRecipes(query: String) async throws -> [Recipe] {
        let lowercaseQuery = query.lowercased()
        return recipes.values.filter {
            $0.title.lowercased().contains(lowercaseQuery) ||
            $0.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }

    func findRecipesByTag(_ tag: String) async throws -> [Recipe] {
        recipes.values.filter { $0.tags.contains(tag) }
    }

    func loadForCard(_ cardID: CardID) async throws -> Recipe? {
        recipes.values.first { $0.cardID == cardID }
    }
}
