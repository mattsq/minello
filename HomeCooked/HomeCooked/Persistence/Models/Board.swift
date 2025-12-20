import Foundation
import SwiftData

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
