import Foundation
import SwiftData

@MainActor
protocol ListsRepository {
    func create(list: PersonalList) async throws
    func fetch(id: UUID) async throws -> PersonalList?
    func fetchAll() async throws -> [PersonalList]
    func update(list: PersonalList) async throws
    func delete(list: PersonalList) async throws
}

@MainActor
final class SwiftDataListsRepository: ListsRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func create(list: PersonalList) async throws {
        modelContext.insert(list)
        try modelContext.save()
    }

    func fetch(id: UUID) async throws -> PersonalList? {
        let descriptor = FetchDescriptor<PersonalList>()
        return try modelContext.fetch(descriptor).first { $0.id == id }
    }

    func fetchAll() async throws -> [PersonalList] {
        let descriptor = FetchDescriptor<PersonalList>()
        let lists = try modelContext.fetch(descriptor)
        return lists.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    func update(list: PersonalList) async throws {
        try modelContext.save()
    }

    func delete(list: PersonalList) async throws {
        // Manual cascade delete for CI compatibility
        // SwiftData will automatically load relationships when accessed (lazy loading)
        for item in list.items {
            modelContext.delete(item)
        }

        modelContext.delete(list)
        try modelContext.save()
    }
}
