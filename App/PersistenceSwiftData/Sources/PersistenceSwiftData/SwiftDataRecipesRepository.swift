// App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataRecipesRepository.swift
// SwiftData implementation of RecipesRepository

import Domain
import Foundation
import PersistenceInterfaces
import SwiftData

/// SwiftData implementation of RecipesRepository
public final class SwiftDataRecipesRepository: @unchecked Sendable, RecipesRepository {
    private let modelContext: ModelContext

    /// Creates a new SwiftData repository
    /// - Parameter modelContext: The SwiftData model context
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates a new in-memory model context for testing
    /// - Returns: A new repository with an in-memory model context
    @MainActor
    public static func inMemory() throws -> SwiftDataRecipesRepository {
        let schema = Schema([RecipeModel.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return SwiftDataRecipesRepository(modelContext: container.mainContext)
    }

    // MARK: - Recipe Operations

    public func createRecipe(_ recipe: Recipe) async throws {
        let model = try RecipeModel(from: recipe)
        modelContext.insert(model)
        try modelContext.save()
    }

    public func loadRecipes() async throws -> [Recipe] {
        let descriptor = FetchDescriptor<RecipeModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.map { try $0.toDomain() }
    }

    public func loadRecipe(_ id: RecipeID) async throws -> Recipe {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<RecipeModel> { $0.id == idString }
        let descriptor = FetchDescriptor<RecipeModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Recipe with ID \(idString) not found")
        }
        return try model.toDomain()
    }

    public func updateRecipe(_ recipe: Recipe) async throws {
        let idString = recipe.id.rawValue.uuidString
        let predicate = #Predicate<RecipeModel> { $0.id == idString }
        let descriptor = FetchDescriptor<RecipeModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Recipe with ID \(idString) not found")
        }

        model.title = recipe.title
        model.ingredientsData = try JSONEncoder().encode(recipe.ingredients)
        model.methodMarkdown = recipe.methodMarkdown
        model.tagsData = try JSONEncoder().encode(recipe.tags)
        model.updatedAt = recipe.updatedAt

        try modelContext.save()
    }

    public func deleteRecipe(_ id: RecipeID) async throws {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<RecipeModel> { $0.id == idString }
        let descriptor = FetchDescriptor<RecipeModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("Recipe with ID \(idString) not found")
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    // MARK: - Query Operations

    public func searchRecipes(query: String) async throws -> [Recipe] {
        let descriptor = FetchDescriptor<RecipeModel>()
        let models = try modelContext.fetch(descriptor)

        // Filter by title or method content (case-insensitive)
        let filtered = models.filter { model in
            model.title.localizedCaseInsensitiveContains(query) ||
            model.methodMarkdown.localizedCaseInsensitiveContains(query)
        }

        return try filtered.map { try $0.toDomain() }
    }

    public func findRecipesByTag(_ tag: String) async throws -> [Recipe] {
        let descriptor = FetchDescriptor<RecipeModel>()
        let models = try modelContext.fetch(descriptor)

        // Filter recipes that contain the specified tag (case-insensitive)
        let filtered = try models.filter { model in
            let tags = try JSONDecoder().decode([String].self, from: model.tagsData)
            return tags.contains { $0.lowercased() == tag.lowercased() }
        }

        return try filtered.map { try $0.toDomain() }
    }

    // MARK: - Card-Centric Query Operations

    public func loadForCard(_ cardID: CardID) async throws -> Recipe? {
        let cardIDString = cardID.rawValue.uuidString
        let predicate = #Predicate<RecipeModel> { $0.cardID == cardIDString }
        let descriptor = FetchDescriptor<RecipeModel>(predicate: predicate)
        let model = try modelContext.fetch(descriptor).first
        return try model?.toDomain()
    }
}
