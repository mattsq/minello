import Foundation
import SwiftData

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
        let descriptor = FetchDescriptor<Recipe>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchAll() async throws -> [Recipe] {
        let descriptor = FetchDescriptor<Recipe>(
            sortBy: [SortDescriptor(\Recipe.title)]
        )
        return try modelContext.fetch(descriptor)
    }

    func update(recipe: Recipe) async throws {
        try modelContext.save()
    }

    func delete(recipe: Recipe) async throws {
        modelContext.delete(recipe)
        try modelContext.save()
    }
}
