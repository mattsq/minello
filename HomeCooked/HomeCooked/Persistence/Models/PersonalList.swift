import Foundation
import SwiftData

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
