// App/UI/Components/DragDropHandler.swift
// Drag and drop handling with haptic feedback

import SwiftUI
import Domain
import UseCases
import PersistenceInterfaces

/// Handles drag and drop operations for cards with haptic feedback
@MainActor
final class DragDropHandler: ObservableObject {
    private let boardsRepository: BoardsRepository
    private let reorderService: CardReorderService

    @Published var draggedCard: Card?

    init(boardsRepository: BoardsRepository) {
        self.boardsRepository = boardsRepository
        self.reorderService = CardReorderService()
    }

    /// Called when a card drag starts
    func startDrag(_ card: Card) {
        draggedCard = card
        // Light haptic feedback when picking up a card
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    /// Called when a card is dropped
    func endDrag() {
        draggedCard = nil
        // Medium haptic feedback when dropping a card
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    /// Reorder a card within the same column
    func reorderCard(_ card: Card, after previousCard: Card?, in cards: [Card]) async throws {
        let sortedCards = cards.sorted { $0.sortKey < $1.sortKey }

        // Calculate new sort key based on position
        let newSortKey: Double
        if let prev = previousCard {
            // Find the card that comes after the previous card in the sorted list
            if let prevIndex = sortedCards.firstIndex(where: { $0.id == prev.id }) {
                let nextCard = prevIndex + 1 < sortedCards.count ? sortedCards[prevIndex + 1] : nil
                newSortKey = await reorderService.calculateMidpoint(
                    after: prev.sortKey,
                    before: nextCard?.id == card.id ? nil : nextCard?.sortKey
                )
            } else {
                newSortKey = 0
            }
        } else {
            // Moving to the start
            if let firstCard = sortedCards.first, firstCard.id != card.id {
                newSortKey = await reorderService.calculateMidpoint(after: nil, before: firstCard.sortKey)
            } else {
                return // Already at the start
            }
        }

        // Update the card with new sort key
        var updatedCard = card
        updatedCard.sortKey = newSortKey
        updatedCard.updatedAt = Date()

        // Save the updated card
        try await boardsRepository.updateCard(updatedCard)

        // Check if normalization is needed
        let allSortKeys = cards.map(\.sortKey)
        if await reorderService.needsNormalization(allSortKeys) {
            await normalizeCards(cards)
        }

        // Success haptic
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Move a card to a different column
    func moveCard(_ card: Card, to targetColumn: ColumnID, after previousCard: Card?, allCards: [Card]) async throws {
        var updatedCard = card
        updatedCard.column = targetColumn

        // Calculate new sort key
        let targetColumnCards = allCards.filter { $0.column == targetColumn }
        if let prev = previousCard, let prevIndex = targetColumnCards.firstIndex(where: { $0.id == prev.id }) {
            let nextCard = prevIndex + 1 < targetColumnCards.count ? targetColumnCards[prevIndex + 1] : nil
            updatedCard.sortKey = await reorderService.calculateMidpoint(
                after: prev.sortKey,
                before: nextCard?.sortKey
            )
        } else if let firstCard = targetColumnCards.first {
            updatedCard.sortKey = firstCard.sortKey - 1
        } else {
            updatedCard.sortKey = 0
        }

        updatedCard.updatedAt = Date()

        // Save the updated card
        try await boardsRepository.updateCard(updatedCard)

        // Success haptic
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    /// Normalize sort keys for a set of cards
    private func normalizeCards(_ cards: [Card]) async {
        var sortedCards = cards.sorted { $0.sortKey < $1.sortKey }
        var sortKeys = sortedCards.map(\.sortKey)
        await reorderService.normalize(&sortKeys)

        for i in sortedCards.indices {
            sortedCards[i].sortKey = sortKeys[i]
            sortedCards[i].updatedAt = Date()
        }

        try? await boardsRepository.saveCards(sortedCards)
    }
}
