import Foundation
import SwiftData

/// Service for managing card reordering with floating-point sortKey using midpoint insertion strategy.
/// Includes background normalization to prevent sortKey drift.
@MainActor
final class CardReorderService {
    private let modelContext: ModelContext
    private let normalizationThreshold: Double = 1000.0

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Reorder a card within the same column using midpoint insertion
    func reorderWithinColumn(
        card: Card,
        fromIndex: Int,
        toIndex: Int,
        inColumn column: Column
    ) async throws {
        let sortedCards = column.cards.sorted { $0.sortKey < $1.sortKey }

        guard fromIndex != toIndex,
              sortedCards.indices.contains(fromIndex),
              sortedCards.indices.contains(toIndex)
        else { return }

        let newSortKey = calculateMidpointSortKey(
            for: toIndex,
            in: sortedCards,
            excluding: card
        )

        card.sortKey = newSortKey
        card.updatedAt = Date()

        try modelContext.save()

        // Normalize in background if needed
        await normalizeIfNeeded(column: column)
    }

    /// Move a card to a different column using midpoint insertion
    func moveToColumn(
        card: Card,
        fromColumn: Column,
        toColumn: Column,
        atIndex targetIndex: Int
    ) async throws {
        // Remove from old column
        card.column = toColumn
        card.updatedAt = Date()

        let sortedCards = toColumn.cards
            .filter { $0.id != card.id }
            .sorted { $0.sortKey < $1.sortKey }

        let newSortKey = calculateMidpointSortKey(
            for: targetIndex,
            in: sortedCards,
            excluding: nil
        )

        card.sortKey = newSortKey

        try modelContext.save()

        // Normalize both columns if needed
        await normalizeIfNeeded(column: fromColumn)
        await normalizeIfNeeded(column: toColumn)
    }

    /// Calculate midpoint sortKey for insertion at target index
    private func calculateMidpointSortKey(
        for targetIndex: Int,
        in sortedCards: [Card],
        excluding excludedCard: Card?
    ) -> Double {
        let filteredCards = sortedCards.filter { $0.id != excludedCard?.id }

        // Insert at beginning
        if targetIndex == 0 {
            if let firstCard = filteredCards.first {
                return firstCard.sortKey - 1.0
            } else {
                return 0.0
            }
        }

        // Insert at end
        if targetIndex >= filteredCards.count {
            if let lastCard = filteredCards.last {
                return lastCard.sortKey + 1.0
            } else {
                return 0.0
            }
        }

        // Insert in middle - use midpoint between adjacent cards
        let beforeIndex = targetIndex - 1
        let afterIndex = targetIndex

        let beforeKey = filteredCards[beforeIndex].sortKey
        let afterKey = filteredCards[afterIndex].sortKey

        return (beforeKey + afterKey) / 2.0
    }

    /// Normalize sortKeys if they're getting too large or too close together
    private func normalizeIfNeeded(column: Column) async {
        let cards = column.cards.sorted { $0.sortKey < $1.sortKey }

        guard !cards.isEmpty else { return }

        // Check if normalization is needed
        let maxKey = cards.map(\.sortKey).max() ?? 0
        let minKey = cards.map(\.sortKey).min() ?? 0
        let range = maxKey - minKey

        // Check for keys that are too close together
        var needsNormalization = range > normalizationThreshold

        if !needsNormalization {
            for i in 0 ..< cards.count - 1 {
                let gap = cards[i + 1].sortKey - cards[i].sortKey
                if gap < 0.001 { // Keys too close
                    needsNormalization = true
                    break
                }
            }
        }

        guard needsNormalization else { return }

        // Normalize: reassign keys as integers
        for (index, card) in cards.enumerated() {
            card.sortKey = Double(index)
        }

        try? modelContext.save()
    }

    /// Force normalization of all cards in a column (useful for maintenance)
    func normalizeColumn(_ column: Column) async throws {
        let cards = column.cards.sorted { $0.sortKey < $1.sortKey }

        for (index, card) in cards.enumerated() {
            card.sortKey = Double(index)
        }

        try modelContext.save()
    }
}
