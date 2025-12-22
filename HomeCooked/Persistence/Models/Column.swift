import Foundation
import SwiftData

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
