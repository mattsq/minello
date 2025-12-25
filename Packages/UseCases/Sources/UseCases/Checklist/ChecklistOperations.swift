// UseCases/Sources/UseCases/Checklist/ChecklistOperations.swift
// Operations for checklist items (toggle, reorder, quantities)

import Domain
import Foundation

/// Policy for bulk operations that require confirmation
public enum BulkActionPolicy {
    /// Threshold for requiring confirmation
    public static let confirmationThreshold = 10

    /// Check if a bulk action requires confirmation
    /// - Parameter itemCount: Number of items being affected
    /// - Returns: True if confirmation is required
    public static func requiresConfirmation(itemCount: Int) -> Bool {
        return itemCount > confirmationThreshold
    }
}

/// Result of a bulk action that may require confirmation
public enum BulkActionResult: Equatable {
    /// Action completed successfully
    case completed([ChecklistItem])

    /// Action requires user confirmation before proceeding
    case requiresConfirmation(itemCount: Int)
}

/// Service for managing checklist item operations
///
/// This service provides operations for managing checklist items including
/// toggling completion status, reordering, and managing quantities/units.
public actor ChecklistOperations {

    public init() {}

    // MARK: - Toggle Operations

    /// Toggle a single item's completion status
    /// - Parameter item: The item to toggle
    /// - Returns: The updated item
    public func toggleItem(_ item: ChecklistItem) -> ChecklistItem {
        var updated = item
        updated.isDone = !item.isDone
        return updated
    }

    /// Toggle all items in a list
    /// - Parameters:
    ///   - items: The items to toggle
    ///   - newStatus: The new completion status for all items
    ///   - skipConfirmation: If true, skip confirmation policy check
    /// - Returns: Result indicating completion or confirmation requirement
    public func toggleAllItems(
        _ items: [ChecklistItem],
        to newStatus: Bool,
        skipConfirmation: Bool = false
    ) -> BulkActionResult {
        // Check if confirmation is required
        if !skipConfirmation && BulkActionPolicy.requiresConfirmation(itemCount: items.count) {
            return .requiresConfirmation(itemCount: items.count)
        }

        // Toggle all items
        let updated = items.map { item -> ChecklistItem in
            var updated = item
            updated.isDone = newStatus
            return updated
        }

        return .completed(updated)
    }

    /// Clear all completed items from a list
    /// - Parameters:
    ///   - items: The items to filter
    ///   - skipConfirmation: If true, skip confirmation policy check
    /// - Returns: Result indicating completion or confirmation requirement
    public func clearCompletedItems(
        _ items: [ChecklistItem],
        skipConfirmation: Bool = false
    ) -> BulkActionResult {
        let completedCount = items.filter { $0.isDone }.count

        // Check if confirmation is required
        if !skipConfirmation && BulkActionPolicy.requiresConfirmation(itemCount: completedCount) {
            return .requiresConfirmation(itemCount: completedCount)
        }

        // Remove completed items
        let remaining = items.filter { !$0.isDone }
        return .completed(remaining)
    }

    // MARK: - Reorder Operations

    /// Reorder an item within a list
    /// - Parameters:
    ///   - items: The current list of items
    ///   - itemID: The ID of the item to move
    ///   - toIndex: The target index
    /// - Returns: The reordered list of items
    public func reorderItem(
        _ items: [ChecklistItem],
        itemID: UUID,
        toIndex: Int
    ) throws -> [ChecklistItem] {
        guard let fromIndex = items.firstIndex(where: { $0.id == itemID }) else {
            throw ChecklistError.itemNotFound(itemID)
        }

        guard toIndex >= 0 && toIndex < items.count else {
            throw ChecklistError.invalidIndex(toIndex)
        }

        var mutableItems = items
        let item = mutableItems.remove(at: fromIndex)
        mutableItems.insert(item, at: toIndex)

        return mutableItems
    }

    /// Move an item to the top of the list
    /// - Parameters:
    ///   - items: The current list of items
    ///   - itemID: The ID of the item to move
    /// - Returns: The reordered list of items
    public func moveItemToTop(
        _ items: [ChecklistItem],
        itemID: UUID
    ) throws -> [ChecklistItem] {
        try reorderItem(items, itemID: itemID, toIndex: 0)
    }

    /// Move an item to the bottom of the list
    /// - Parameters:
    ///   - items: The current list of items
    ///   - itemID: The ID of the item to move
    /// - Returns: The reordered list of items
    public func moveItemToBottom(
        _ items: [ChecklistItem],
        itemID: UUID
    ) throws -> [ChecklistItem] {
        try reorderItem(items, itemID: itemID, toIndex: items.count - 1)
    }

    // MARK: - Quantity and Unit Operations

    /// Update the quantity for an item
    /// - Parameters:
    ///   - item: The item to update
    ///   - quantity: The new quantity (nil to remove)
    /// - Returns: The updated item
    public func updateQuantity(
        _ item: ChecklistItem,
        quantity: Double?
    ) -> ChecklistItem {
        var updated = item
        updated.quantity = quantity
        return updated
    }

    /// Update the unit for an item
    /// - Parameters:
    ///   - item: The item to update
    ///   - unit: The new unit (nil to remove)
    /// - Returns: The updated item
    public func updateUnit(
        _ item: ChecklistItem,
        unit: String?
    ) -> ChecklistItem {
        var updated = item
        updated.unit = unit
        return updated
    }

    /// Update both quantity and unit for an item
    /// - Parameters:
    ///   - item: The item to update
    ///   - quantity: The new quantity
    ///   - unit: The new unit
    /// - Returns: The updated item
    public func updateQuantityAndUnit(
        _ item: ChecklistItem,
        quantity: Double?,
        unit: String?
    ) -> ChecklistItem {
        var updated = item
        updated.quantity = quantity
        updated.unit = unit
        return updated
    }

    /// Increment the quantity for an item
    /// - Parameters:
    ///   - item: The item to update
    ///   - by: The amount to increment (default 1.0)
    /// - Returns: The updated item
    public func incrementQuantity(
        _ item: ChecklistItem,
        by amount: Double = 1.0
    ) -> ChecklistItem {
        var updated = item
        let currentQuantity = item.quantity ?? 0.0
        updated.quantity = currentQuantity + amount
        return updated
    }

    /// Decrement the quantity for an item
    /// - Parameters:
    ///   - item: The item to update
    ///   - by: The amount to decrement (default 1.0)
    /// - Returns: The updated item (quantity won't go below 0)
    public func decrementQuantity(
        _ item: ChecklistItem,
        by amount: Double = 1.0
    ) -> ChecklistItem {
        var updated = item
        let currentQuantity = item.quantity ?? 0.0
        updated.quantity = max(0.0, currentQuantity - amount)
        return updated
    }

    // MARK: - Note Operations

    /// Update the note for an item
    /// - Parameters:
    ///   - item: The item to update
    ///   - note: The new note (nil to remove)
    /// - Returns: The updated item
    public func updateNote(
        _ item: ChecklistItem,
        note: String?
    ) -> ChecklistItem {
        var updated = item
        updated.note = note
        return updated
    }

    // MARK: - Statistics

    /// Calculate completion statistics for a list of items
    /// - Parameter items: The items to analyze
    /// - Returns: Statistics about the items
    public func calculateStatistics(
        _ items: [ChecklistItem]
    ) -> ChecklistStatistics {
        let total = items.count
        let completed = items.filter { $0.isDone }.count
        let incomplete = total - completed
        let percentComplete = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0

        return ChecklistStatistics(
            totalItems: total,
            completedItems: completed,
            incompleteItems: incomplete,
            percentComplete: percentComplete
        )
    }
}

// MARK: - Supporting Types

/// Statistics for a checklist
public struct ChecklistStatistics: Equatable, Sendable {
    public let totalItems: Int
    public let completedItems: Int
    public let incompleteItems: Int
    public let percentComplete: Double

    public init(
        totalItems: Int,
        completedItems: Int,
        incompleteItems: Int,
        percentComplete: Double
    ) {
        self.totalItems = totalItems
        self.completedItems = completedItems
        self.incompleteItems = incompleteItems
        self.percentComplete = percentComplete
    }
}

/// Errors that can occur during checklist operations
public enum ChecklistError: Error, Equatable {
    case itemNotFound(UUID)
    case invalidIndex(Int)
}

extension ChecklistError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .itemNotFound(let id):
            return "Checklist item with ID \(id) not found"
        case .invalidIndex(let index):
            return "Invalid index: \(index)"
        }
    }
}

// MARK: - Sendable Conformance

extension ChecklistOperations: Sendable {}
