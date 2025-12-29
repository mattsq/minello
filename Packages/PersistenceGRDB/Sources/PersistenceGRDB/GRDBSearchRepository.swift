// PersistenceGRDB/Sources/PersistenceGRDB/GRDBSearchRepository.swift
// GRDB implementation of SearchRepository

import Domain
import Foundation
import GRDB
import PersistenceInterfaces

/// GRDB implementation of SearchRepository
public final class GRDBSearchRepository: SearchRepository {
    private let dbQueue: DatabaseQueue
    private let boardsRepo: BoardsRepository
    private let listsRepo: ListsRepository
    private let recipesRepo: RecipesRepository

    /// Creates a new GRDB search repository
    /// - Parameters:
    ///   - dbQueue: The GRDB database queue
    ///   - boardsRepo: Repository for boards/cards operations
    ///   - listsRepo: Repository for lists operations
    ///   - recipesRepo: Repository for recipes operations
    public init(
        dbQueue: DatabaseQueue,
        boardsRepo: BoardsRepository,
        listsRepo: ListsRepository,
        recipesRepo: RecipesRepository
    ) {
        self.dbQueue = dbQueue
        self.boardsRepo = boardsRepo
        self.listsRepo = listsRepo
        self.recipesRepo = recipesRepo
    }

    // MARK: - Unified Search

    public func search(query: String, filters: Set<EntityType>?) async throws -> [SearchResult] {
        var results: [SearchResult] = []
        let activeFilters = filters ?? Set(EntityType.allCases)

        // Search boards
        if activeFilters.contains(.board) {
            let boards = try await searchBoards(query: query)
            results.append(contentsOf: boards.map { .board($0) })
        }

        // Search cards
        if activeFilters.contains(.card) {
            let cards = try await searchCards(query: query)
            results.append(contentsOf: cards.map { .card($0) })
        }

        // Search lists
        if activeFilters.contains(.list) {
            let lists = try await searchLists(query: query)
            results.append(contentsOf: lists.map { .list($0) })
        }

        // Search recipes
        if activeFilters.contains(.recipe) {
            let recipes = try await searchRecipes(query: query)
            results.append(contentsOf: recipes.map { .recipe($0) })
        }

        // Save to recent searches if query is not empty
        if !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try await saveRecentSearch(query)
        }

        return results
    }

    // MARK: - Entity-Specific Search

    public func searchBoards(query: String) async throws -> [Board] {
        // FTS5 doesn't accept empty MATCH expressions, so return empty results
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return []
        }

        try await dbQueue.read { db in
            let pattern = FTS5Pattern(matchingAllTokensIn: trimmedQuery)
            let sql = """
                SELECT boards.* FROM boards
                JOIN boards_fts ON boards.rowid = boards_fts.rowid
                WHERE boards_fts MATCH ?
                ORDER BY boards.created_at DESC
                """
            let records = try BoardRecord.fetchAll(db, sql: sql, arguments: [pattern])
            return try records.map { try $0.toDomain() }
        }
    }

    public func searchCards(query: String) async throws -> [Card] {
        try await boardsRepo.searchCards(query: query)
    }

    public func searchLists(query: String) async throws -> [PersonalList] {
        try await listsRepo.searchLists(query: query)
    }

    public func searchRecipes(query: String) async throws -> [Recipe] {
        try await recipesRepo.searchRecipes(query: query)
    }

    // MARK: - Tag Search

    public func searchByTag(_ tag: String) async throws -> [SearchResult] {
        var results: [SearchResult] = []

        // Search cards by tag
        let cards = try await boardsRepo.findCards(byTag: tag)
        results.append(contentsOf: cards.map { .card($0) })

        // Search recipes by tag
        let recipes = try await recipesRepo.findRecipesByTag(tag)
        results.append(contentsOf: recipes.map { .recipe($0) })

        return results
    }

    // MARK: - Date Range Search

    public func findCardsDue(from: Date, to: Date) async throws -> [Card] {
        try await boardsRepo.findCards(dueBetween: from, and: to)
    }

    // MARK: - Recent Searches

    public func saveRecentSearch(_ query: String) async throws {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        try await dbQueue.write { db in
            // Delete existing entry with same query (case-insensitive)
            try db.execute(
                sql: "DELETE FROM recent_searches WHERE LOWER(query) = LOWER(?)",
                arguments: [trimmed]
            )

            // Insert new entry
            try db.execute(
                sql: "INSERT INTO recent_searches (query, searched_at) VALUES (?, ?)",
                arguments: [trimmed, ISO8601DateFormatter.iso8601.string(from: Date())]
            )

            // Keep only the 50 most recent searches
            try db.execute(
                sql: """
                    DELETE FROM recent_searches
                    WHERE rowid NOT IN (
                        SELECT rowid FROM recent_searches
                        ORDER BY searched_at DESC
                        LIMIT 50
                    )
                    """
            )
        }
    }

    public func loadRecentSearches(limit: Int = 10) async throws -> [String] {
        try await dbQueue.read { db in
            let sql = """
                SELECT query FROM recent_searches
                ORDER BY searched_at DESC
                LIMIT ?
                """
            let rows = try Row.fetchAll(db, sql: sql, arguments: [limit])
            return rows.map { $0["query"] as String }
        }
    }

    public func clearRecentSearches() async throws {
        try await dbQueue.write { db in
            try db.execute(sql: "DELETE FROM recent_searches")
        }
    }
}
