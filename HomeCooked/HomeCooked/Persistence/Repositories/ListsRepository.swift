import Foundation
import SwiftData

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
        let descriptor = FetchDescriptor<PersonalList>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }

    func fetchAll() async throws -> [PersonalList] {
        let descriptor = FetchDescriptor<PersonalList>(
            sortBy: [SortDescriptor(\PersonalList.title)]
        )
        return try modelContext.fetch(descriptor)
    }

    func update(list: PersonalList) async throws {
        try modelContext.save()
    }

    func delete(list: PersonalList) async throws {
        modelContext.delete(list)
        try modelContext.save()
    }
}
