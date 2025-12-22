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
