import Foundation
import SwiftData

/// Migration handling for adding sortKey field to Card entities
/// Defines schema versions and migration stages for v0 → v1 migration
enum CardSortKeyMigration {

    /// Schema V1: Initial version without Card.sortKey
    enum SchemaV1: VersionedSchema {
        static let versionIdentifier = Schema.Version(1, 0, 0)

        static var models: [any PersistentModel.Type] {
            [Board.self, Column.self, Card.self, ChecklistItem.self, PersonalList.self, Recipe.self]
        }

        @Model
        final class Board {
            @Attribute(.unique) var id: UUID
            var title: String
            @Relationship(deleteRule: .cascade, inverse: \Column.board)
            var columns: [Column]
            var createdAt: Date
            var updatedAt: Date

            init(
                id: UUID = UUID(),
                title: String,
                columns: [Column] = [],
                createdAt: Date = Date(),
                updatedAt: Date = Date()
            ) {
                self.id = id
                self.title = title
                self.columns = columns
                self.createdAt = createdAt
                self.updatedAt = updatedAt
            }
        }

        @Model
        final class Column {
            @Attribute(.unique) var id: UUID
            var title: String
            var index: Int
            @Relationship(deleteRule: .cascade, inverse: \Card.column)
            var cards: [Card]
            var board: Board?

            init(
                id: UUID = UUID(),
                title: String,
                index: Int,
                cards: [Card] = [],
                board: Board? = nil
            ) {
                self.id = id
                self.title = title
                self.index = index
                self.cards = cards
                self.board = board
            }
        }

        @Model
        final class Card {
            @Attribute(.unique) var id: UUID
            var title: String
            var details: String
            var due: Date?
            var tags: [String]
            @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.card)
            var checklist: [ChecklistItem]
            var column: Column?
            // Note: sortKey doesn't exist in V1
            var createdAt: Date
            var updatedAt: Date

            init(
                id: UUID = UUID(),
                title: String,
                details: String = "",
                due: Date? = nil,
                tags: [String] = [],
                checklist: [ChecklistItem] = [],
                column: Column? = nil,
                createdAt: Date = Date(),
                updatedAt: Date = Date()
            ) {
                self.id = id
                self.title = title
                self.details = details
                self.due = due
                self.tags = tags
                self.checklist = checklist
                self.column = column
                self.createdAt = createdAt
                self.updatedAt = updatedAt
            }
        }

        @Model
        final class ChecklistItem {
            @Attribute(.unique) var id: UUID
            var text: String
            var isDone: Bool
            var quantity: Double?
            var unit: String?
            var note: String?
            var card: Card?
            var personalList: PersonalList?

            init(
                id: UUID = UUID(),
                text: String,
                isDone: Bool = false,
                quantity: Double? = nil,
                unit: String? = nil,
                note: String? = nil,
                card: Card? = nil,
                personalList: PersonalList? = nil
            ) {
                self.id = id
                self.text = text
                self.isDone = isDone
                self.quantity = quantity
                self.unit = unit
                self.note = note
                self.card = card
                self.personalList = personalList
            }
        }

        @Model
        final class PersonalList {
            @Attribute(.unique) var id: UUID
            var title: String
            @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.personalList)
            var items: [ChecklistItem]

            init(
                id: UUID = UUID(),
                title: String,
                items: [ChecklistItem] = []
            ) {
                self.id = id
                self.title = title
                self.items = items
            }
        }

        @Model
        final class Recipe {
            @Attribute(.unique) var id: UUID
            var title: String
            var ingredients: String
            var methodMarkdown: String
            var tags: [String]

            init(
                id: UUID = UUID(),
                title: String,
                ingredients: String = "",
                methodMarkdown: String = "",
                tags: [String] = []
            ) {
                self.id = id
                self.title = title
                self.ingredients = ingredients
                self.methodMarkdown = methodMarkdown
                self.tags = tags
            }
        }
    }

    /// Schema V2: Version with Card.sortKey added
    enum SchemaV2: VersionedSchema {
        static let versionIdentifier = Schema.Version(2, 0, 0)

        static var models: [any PersistentModel.Type] {
            [Board.self, Column.self, Card.self, ChecklistItem.self, PersonalList.self, Recipe.self]
        }

        @Model
        final class Board {
            @Attribute(.unique) var id: UUID
            var title: String
            @Relationship(deleteRule: .cascade, inverse: \Column.board)
            var columns: [Column]
            var createdAt: Date
            var updatedAt: Date

            init(
                id: UUID = UUID(),
                title: String,
                columns: [Column] = [],
                createdAt: Date = Date(),
                updatedAt: Date = Date()
            ) {
                self.id = id
                self.title = title
                self.columns = columns
                self.createdAt = createdAt
                self.updatedAt = updatedAt
            }
        }

        @Model
        final class Column {
            @Attribute(.unique) var id: UUID
            var title: String
            var index: Int
            @Relationship(deleteRule: .cascade, inverse: \Card.column)
            var cards: [Card]
            var board: Board?

            init(
                id: UUID = UUID(),
                title: String,
                index: Int,
                cards: [Card] = [],
                board: Board? = nil
            ) {
                self.id = id
                self.title = title
                self.index = index
                self.cards = cards
                self.board = board
            }
        }

        @Model
        final class Card {
            @Attribute(.unique) var id: UUID
            var title: String
            var details: String
            var due: Date?
            var tags: [String]
            @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.card)
            var checklist: [ChecklistItem]
            var column: Column?
            var sortKey: Double // New in V2
            var createdAt: Date
            var updatedAt: Date

            init(
                id: UUID = UUID(),
                title: String,
                details: String = "",
                due: Date? = nil,
                tags: [String] = [],
                checklist: [ChecklistItem] = [],
                column: Column? = nil,
                sortKey: Double = 0,
                createdAt: Date = Date(),
                updatedAt: Date = Date()
            ) {
                self.id = id
                self.title = title
                self.details = details
                self.due = due
                self.tags = tags
                self.checklist = checklist
                self.column = column
                self.sortKey = sortKey
                self.createdAt = createdAt
                self.updatedAt = updatedAt
            }
        }

        @Model
        final class ChecklistItem {
            @Attribute(.unique) var id: UUID
            var text: String
            var isDone: Bool
            var quantity: Double?
            var unit: String?
            var note: String?
            var card: Card?
            var personalList: PersonalList?

            init(
                id: UUID = UUID(),
                text: String,
                isDone: Bool = false,
                quantity: Double? = nil,
                unit: String? = nil,
                note: String? = nil,
                card: Card? = nil,
                personalList: PersonalList? = nil
            ) {
                self.id = id
                self.text = text
                self.isDone = isDone
                self.quantity = quantity
                self.unit = unit
                self.note = note
                self.card = card
                self.personalList = personalList
            }
        }

        @Model
        final class PersonalList {
            @Attribute(.unique) var id: UUID
            var title: String
            @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.personalList)
            var items: [ChecklistItem]

            init(
                id: UUID = UUID(),
                title: String,
                items: [ChecklistItem] = []
            ) {
                self.id = id
                self.title = title
                self.items = items
            }
        }

        @Model
        final class Recipe {
            @Attribute(.unique) var id: UUID
            var title: String
            var ingredients: String
            var methodMarkdown: String
            var tags: [String]

            init(
                id: UUID = UUID(),
                title: String,
                ingredients: String = "",
                methodMarkdown: String = "",
                tags: [String] = []
            ) {
                self.id = id
                self.title = title
                self.ingredients = ingredients
                self.methodMarkdown = methodMarkdown
                self.tags = tags
            }
        }
    }

    /// Schema V3: Adds stored parent identifiers for relationship fallback matching
    enum SchemaV3: VersionedSchema {
        static let versionIdentifier = Schema.Version(3, 0, 0)

        static var models: [any PersistentModel.Type] {
            [Board.self, Column.self, Card.self, ChecklistItem.self, PersonalList.self, Recipe.self]
        }

        @Model
        final class Board {
            @Attribute(.unique) var id: UUID
            var title: String
            @Relationship(deleteRule: .cascade, inverse: \Column.board)
            var columns: [Column]
            var createdAt: Date
            var updatedAt: Date

            init(
                id: UUID = UUID(),
                title: String,
                columns: [Column] = [],
                createdAt: Date = Date(),
                updatedAt: Date = Date()
            ) {
                self.id = id
                self.title = title
                self.columns = columns
                self.createdAt = createdAt
                self.updatedAt = updatedAt
            }
        }

        @Model
        final class Column {
            @Attribute(.unique) var id: UUID
            var title: String
            var index: Int
            @Relationship(deleteRule: .cascade, inverse: \Card.column)
            var cards: [Card]
            var board: Board?
            var boardID: UUID?

            init(
                id: UUID = UUID(),
                title: String,
                index: Int,
                cards: [Card] = [],
                board: Board? = nil,
                boardID: UUID? = nil
            ) {
                self.id = id
                self.title = title
                self.index = index
                self.cards = cards
                self.board = board
                self.boardID = boardID
            }
        }

        @Model
        final class Card {
            @Attribute(.unique) var id: UUID
            var title: String
            var details: String
            var due: Date?
            var tags: [String]
            @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.card)
            var checklist: [ChecklistItem]
            var column: Column?
            var columnID: UUID?
            var sortKey: Double
            var createdAt: Date
            var updatedAt: Date

            init(
                id: UUID = UUID(),
                title: String,
                details: String = "",
                due: Date? = nil,
                tags: [String] = [],
                checklist: [ChecklistItem] = [],
                column: Column? = nil,
                columnID: UUID? = nil,
                sortKey: Double = 0,
                createdAt: Date = Date(),
                updatedAt: Date = Date()
            ) {
                self.id = id
                self.title = title
                self.details = details
                self.due = due
                self.tags = tags
                self.checklist = checklist
                self.column = column
                self.columnID = columnID
                self.sortKey = sortKey
                self.createdAt = createdAt
                self.updatedAt = updatedAt
            }
        }

        @Model
        final class ChecklistItem {
            @Attribute(.unique) var id: UUID
            var text: String
            var isDone: Bool
            var quantity: Double?
            var unit: String?
            var note: String?
            var card: Card?
            var cardID: UUID?
            var personalList: PersonalList?

            init(
                id: UUID = UUID(),
                text: String,
                isDone: Bool = false,
                quantity: Double? = nil,
                unit: String? = nil,
                note: String? = nil,
                card: Card? = nil,
                cardID: UUID? = nil,
                personalList: PersonalList? = nil
            ) {
                self.id = id
                self.text = text
                self.isDone = isDone
                self.quantity = quantity
                self.unit = unit
                self.note = note
                self.card = card
                self.cardID = cardID
                self.personalList = personalList
            }
        }

        @Model
        final class PersonalList {
            @Attribute(.unique) var id: UUID
            var title: String
            @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.personalList)
            var items: [ChecklistItem]

            init(
                id: UUID = UUID(),
                title: String,
                items: [ChecklistItem] = []
            ) {
                self.id = id
                self.title = title
                self.items = items
            }
        }

        @Model
        final class Recipe {
            @Attribute(.unique) var id: UUID
            var title: String
            var ingredients: String
            var methodMarkdown: String
            var tags: [String]

            init(
                id: UUID = UUID(),
                title: String,
                ingredients: String = "",
                methodMarkdown: String = "",
                tags: [String] = []
            ) {
                self.id = id
                self.title = title
                self.ingredients = ingredients
                self.methodMarkdown = methodMarkdown
                self.tags = tags
            }
        }
    }

    /// Migration plan that orchestrates the schema migrations
    enum MigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            [SchemaV1.self, SchemaV2.self, SchemaV3.self]
        }

        static var stages: [MigrationStage] {
            [migrateV1toV2, migrateV2toV3]
        }

        /// Custom migration stage that initializes sortKey for all cards
        static let migrateV1toV2 = MigrationStage.custom(
            fromVersion: SchemaV1.self,
            toVersion: SchemaV2.self,
            willMigrate: nil,
            didMigrate: { context in
                // Initialize sortKey for all cards based on their position in columns
                let columnDescriptor = FetchDescriptor<SchemaV2.Column>()
                let columns = try context.fetch(columnDescriptor)

                for column in columns {
                    for (index, card) in column.cards.enumerated() {
                        // Set sortKey to index * 100 to allow for midpoint insertion later
                        card.sortKey = Double(index * 100)
                    }
                }

                try context.save()
            }
        )

        static let migrateV2toV3 = MigrationStage.custom(
            fromVersion: SchemaV2.self,
            toVersion: SchemaV3.self,
            willMigrate: nil,
            didMigrate: { context in
                do {
                    let columns = try context.fetch(FetchDescriptor<SchemaV3.Column>())
                    for column in columns {
                        column.boardID = column.board?.id
                    }

                    let cards = try context.fetch(FetchDescriptor<SchemaV3.Card>())
                    for card in cards {
                        card.columnID = card.column?.id
                    }

                    let checklistItems = try context.fetch(FetchDescriptor<SchemaV3.ChecklistItem>())
                    for item in checklistItems {
                        item.cardID = item.card?.id
                    }

                    try context.save()
                } catch {
                    print("[Migration] Failed to populate parent identifiers: \(error)")
                }
            }
        )
    }

    /// Helper enum for testing migration logic
    /// Provides a way to test the migration apply logic without full ModelContainer setup
    enum MigrateV0toV1 {
        /// Applies the sortKey initialization logic to a context
        /// This is primarily for testing purposes
        static func apply(to context: ModelContext) throws {
            let columnDescriptor = FetchDescriptor<Column>()
            let columns = try context.fetch(columnDescriptor)

            for column in columns {
                for (index, card) in column.cards.enumerated() {
                    card.sortKey = Double(index * 100)
                }
            }

            try context.save()
        }
    }
}
