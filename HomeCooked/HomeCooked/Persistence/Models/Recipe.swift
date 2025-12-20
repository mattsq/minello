import Foundation
import SwiftData

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
