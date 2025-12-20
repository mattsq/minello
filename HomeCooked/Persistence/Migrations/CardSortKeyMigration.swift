import Foundation
import SwiftData

/// Migration planner that adds and initializes the sortKey field for Card entities
/// This handles the v0 → v1 migration where sortKey is added as a Double field
enum CardSortKeyMigration {
    /// Defines the migration plan for adding Card.sortKey
    static let migrationPlan = SchemaMigrationPlan([
        MigrateV0toV1(),
    ])

    /// Migration stage that adds sortKey field and initializes it based on card position in column
    struct MigrateV0toV1: SchemaMigration {
        static let versionIdentifier = Schema.Version(1, 0, 0)

        /// Applies lightweight migration to add sortKey field
        /// Note: SwiftData automatically handles adding new fields with default values
        /// This migration ensures cards are initialized with ascending sortKey values
        static func apply(to context: ModelContext) throws {
            // Fetch all columns with their cards
            let columnDescriptor = FetchDescriptor<Column>()
            let columns = try context.fetch(columnDescriptor)

            // Initialize sortKey for cards in each column based on their current order
            for column in columns {
                for (index, card) in column.cards.enumerated() {
                    // Set sortKey to index * 100 to allow for midpoint insertion later
                    card.sortKey = Double(index * 100)
                }
            }

            try context.save()
        }
    }
}
