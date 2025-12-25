// App/PersistenceSwiftData/Sources/PersistenceSwiftData/SwiftDataListsRepository.swift
// SwiftData implementation of ListsRepository

import Domain
import Foundation
import PersistenceInterfaces
import SwiftData

/// SwiftData implementation of ListsRepository
public final class SwiftDataListsRepository: ListsRepository {
    private let modelContext: ModelContext

    /// Creates a new SwiftData repository
    /// - Parameter modelContext: The SwiftData model context
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates a new in-memory model context for testing
    /// - Returns: A new repository with an in-memory model context
    @MainActor
    public static func inMemory() throws -> SwiftDataListsRepository {
        let schema = Schema([PersonalListModel.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return SwiftDataListsRepository(modelContext: container.mainContext)
    }

    // MARK: - List Operations

    public func createList(_ list: PersonalList) async throws {
        let model = try PersonalListModel(from: list)
        modelContext.insert(model)
        try modelContext.save()
    }

    public func loadLists() async throws -> [PersonalList] {
        let descriptor = FetchDescriptor<PersonalListModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        let models = try modelContext.fetch(descriptor)
        return try models.map { try $0.toDomain() }
    }

    public func loadList(_ id: ListID) async throws -> PersonalList {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<PersonalListModel> { $0.id == idString }
        let descriptor = FetchDescriptor<PersonalListModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("List with ID \(idString) not found")
        }
        return try model.toDomain()
    }

    public func updateList(_ list: PersonalList) async throws {
        let idString = list.id.rawValue.uuidString
        let predicate = #Predicate<PersonalListModel> { $0.id == idString }
        let descriptor = FetchDescriptor<PersonalListModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("List with ID \(idString) not found")
        }

        model.title = list.title
        model.itemsData = try JSONEncoder().encode(list.items)
        model.updatedAt = list.updatedAt

        try modelContext.save()
    }

    public func deleteList(_ id: ListID) async throws {
        let idString = id.rawValue.uuidString
        let predicate = #Predicate<PersonalListModel> { $0.id == idString }
        let descriptor = FetchDescriptor<PersonalListModel>(predicate: predicate)
        guard let model = try modelContext.fetch(descriptor).first else {
            throw PersistenceError.notFound("List with ID \(idString) not found")
        }

        modelContext.delete(model)
        try modelContext.save()
    }

    // MARK: - Query Operations

    public func searchLists(query: String) async throws -> [PersonalList] {
        let descriptor = FetchDescriptor<PersonalListModel>()
        let models = try modelContext.fetch(descriptor)

        let filtered = models.filter { model in
            model.title.localizedCaseInsensitiveContains(query)
        }

        return try filtered.map { try $0.toDomain() }
    }

    public func findListsWithIncompleteItems() async throws -> [PersonalList] {
        let descriptor = FetchDescriptor<PersonalListModel>()
        let models = try modelContext.fetch(descriptor)

        // Filter lists that have at least one incomplete item
        let filtered = try models.filter { model in
            let items = try JSONDecoder().decode([ChecklistItem].self, from: model.itemsData)
            return items.contains { !$0.isDone }
        }

        return try filtered.map { try $0.toDomain() }
    }
}
