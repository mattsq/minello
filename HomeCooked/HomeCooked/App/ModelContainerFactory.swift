import Foundation
import SwiftData

enum ModelContainerFactory {
    static let schema = Schema([
        Board.self,
        Column.self,
        Card.self,
        ChecklistItem.self,
        PersonalList.self,
        Recipe.self
    ])

    /// Creates a persistent ModelContainer for production use
    static func create(
        cloudKitContainerIdentifier: String? = nil
    ) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKitContainerIdentifier.map { .private($0) }
        )
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }

    /// Creates an in-memory ModelContainer for testing
    static func createInMemory() throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
    }
}
