import Foundation
import SwiftData

enum ModelContainerFactory {
    static let schema = Schema([
        Board.self,
        Column.self,
        Card.self,
        ChecklistItem.self,
        PersonalList.self,
        Recipe.self,
    ])

    /// Creates a persistent ModelContainer for production use
    /// Uses the CardSortKeyMigration.MigrationPlan to handle schema migrations
    static func create(
        cloudKitContainerIdentifier: String? = nil
    ) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: cloudKitContainerIdentifier.map { .private($0) } ?? .none
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: CardSortKeyMigration.MigrationPlan.self,
            configurations: [configuration]
        )
    }

    /// Creates an in-memory ModelContainer for testing
    /// Note: In-memory containers don't need migration plans as they start fresh each time
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
