import Foundation
import SwiftData

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
