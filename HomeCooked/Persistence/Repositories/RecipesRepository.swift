import Foundation
import SwiftData

@MainActor
protocol RecipesRepository {
    func create(recipe: Recipe) async throws
    func fetch(id: UUID) async throws -> Recipe?
    func fetchAll() async throws -> [Recipe]
    func update(recipe: Recipe) async throws
    func delete(recipe: Recipe) async throws
}

@MainActor
final class SwiftDataRecipesRepository: RecipesRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(recipe: Recipe) async throws {
        modelContext.insert(recipe)
        try modelContext.save()
    }

    func fetch(id: UUID) async throws -> Recipe? {
        let descriptor = FetchDescriptor<Recipe>()
        return try modelContext.fetch(descriptor).first { $0.id == id }
    }

    func fetchAll() async throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>()
        let recipes = try modelContext.fetch(descriptor)
        return recipes.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func update(recipe: Recipe) async throws {
        try modelContext.save()
    }

    func delete(recipe: Recipe) async throws {
        modelContext.delete(recipe)
        try modelContext.save()
    }
}
