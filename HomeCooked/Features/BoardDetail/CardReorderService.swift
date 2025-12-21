import Foundation
import SwiftData

/// Service responsible for reordering cards using floating sortKey with midpoint insertion
/// and background normalization to prevent precision issues.
@MainActor
final class CardReorderService {
    private let modelContext: ModelContext
    private let normalizationThreshold: Double = 0.001

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Moves a card to a new position within the same column or to a different column
    /// - Parameters:
    ///   - card: The card to move
    ///   - destinationColumn: The column to move the card to
    ///   - index: The target index in the destination column (0-based)
    func moveCard(_ card: Card, to destinationColumn: Column, at index: Int) throws {
        let sourceColumn = card.column

        // Get current cards in destination column, sorted by sortKey
        let destinationCards = destinationColumn.cards
            .filter { $0.id != card.id } // Exclude the card being moved
            .sorted { $0.sortKey < $1.sortKey }

        // Calculate new sortKey using midpoint insertion
        let newSortKey = calculateSortKey(
            for: index,
            in: destinationCards
        )

        // Update card properties
        card.sortKey = newSortKey
        card.column = destinationColumn
        card.updatedAt = Date()

        // If moving between columns, update relationships
        if sourceColumn?.id != destinationColumn.id {
            sourceColumn?.cards.removeAll { $0.id == card.id }
            if !destinationColumn.cards.contains(where: { $0.id == card.id }) {
                destinationColumn.cards.append(card)
            }
        }

        // Check if normalization is needed
        if shouldNormalize(destinationCards + [card]) {
            Task {
                try await normalizeColumn(destinationColumn)
            }
        }
    }

    /// Calculates the sortKey for a card being inserted at the given index
    /// Uses midpoint insertion strategy
    private func calculateSortKey(for index: Int, in cards: [Card]) -> Double {
        // Edge case: Empty column
        if cards.isEmpty {
            return 1000.0
        }

        // Insert at beginning
        if index == 0 {
            let firstCard = cards[0]
            return firstCard.sortKey - 1000.0
        }

        // Insert at end
        if index >= cards.count {
            let lastCard = cards[cards.count - 1]
            return lastCard.sortKey + 1000.0
        }

        // Insert in middle - use midpoint between neighbors
        let beforeCard = cards[index - 1]
        let afterCard = cards[index]

        return (beforeCard.sortKey + afterCard.sortKey) / 2.0
    }

    /// Determines if column needs normalization
    /// Normalization is needed when sortKeys are too close together
    private func shouldNormalize(_ cards: [Card]) -> Bool {
        let sorted = cards.sorted { $0.sortKey < $1.sortKey }

        for i in 0 ..< sorted.count - 1 {
            let diff = sorted[i + 1].sortKey - sorted[i].sortKey
            if abs(diff) < normalizationThreshold {
                return true
            }
        }

        return false
    }

    /// Normalizes sortKeys in a column to be evenly spaced integers
    /// This prevents precision issues from repeated midpoint insertions
    func normalizeColumn(_ column: Column) async throws {
        // Get all cards in the column, sorted by current sortKey
        let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }

        // Reassign sortKeys as evenly-spaced integers starting from 1000
        for (index, card) in sortedCards.enumerated() {
            let newSortKey = Double((index + 1) * 1000)
            if abs(card.sortKey - newSortKey) > 0.01 {
                card.sortKey = newSortKey
                card.updatedAt = Date()
            }
        }

        try modelContext.save()
    }

    /// Reorders a card within the same column
    func reorderWithinColumn(_ card: Card, to index: Int) throws {
        guard let column = card.column else {
            throw CardReorderError.cardHasNoColumn
        }

        try moveCard(card, to: column, at: index)
    }

    /// Moves a card to a different column
    func moveToColumn(_ card: Card, column: Column, at index: Int) throws {
        try moveCard(card, to: column, at: index)
    }
}

enum CardReorderError: Error, LocalizedError {
    case cardHasNoColumn
    case invalidIndex

    var errorDescription: String? {
        switch self {
        case .cardHasNoColumn:
            return "Card must belong to a column"
        case .invalidIndex:
            return "Invalid destination index"
        }
    }
}
