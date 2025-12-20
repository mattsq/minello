import Foundation
import SwiftData

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
