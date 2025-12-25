// Domain/Sources/Domain/Helpers.swift
// Helper utilities for domain models

import Foundation

// MARK: - Tag Utilities

/// Utilities for sanitizing and normalizing tags
public enum TagHelpers {
    /// Sanitizes a tag by trimming whitespace, converting to lowercase,
    /// and removing invalid characters
    ///
    /// - Parameter tag: The raw tag string
    /// - Returns: A sanitized tag string, or nil if the tag is invalid
    public static func sanitize(_ tag: String) -> String? {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)

        // Empty after trimming
        guard !trimmed.isEmpty else { return nil }

        // Convert to lowercase
        let lowercased = trimmed.lowercased()

        // Remove non-alphanumeric characters except hyphens and underscores
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_"))
        let filtered = lowercased.unicodeScalars.filter { allowed.contains($0) }
        let sanitized = String(String.UnicodeScalarView(filtered))

        // Check if result is empty
        guard !sanitized.isEmpty else { return nil }

        return sanitized
    }

    /// Sanitizes multiple tags, removing duplicates and invalid tags
    ///
    /// - Parameter tags: Array of raw tag strings
    /// - Returns: Array of unique, sanitized tags
    public static func sanitize(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for tag in tags {
            if let sanitized = sanitize(tag), !seen.contains(sanitized) {
                seen.insert(sanitized)
                result.append(sanitized)
            }
        }

        return result
    }
}

// MARK: - Checklist Utilities

/// Utilities for working with checklist items
public enum ChecklistHelpers {
    /// Toggles the done status of a checklist item
    ///
    /// - Parameter item: The checklist item to toggle
    /// - Returns: A new item with toggled done status
    public static func toggle(_ item: ChecklistItem) -> ChecklistItem {
        var updated = item
        updated.isDone.toggle()
        return updated
    }

    /// Toggles all items in a checklist to the specified done status
    ///
    /// - Parameters:
    ///   - items: The checklist items
    ///   - isDone: The target done status
    /// - Returns: New array with all items set to the specified status
    public static func toggleAll(_ items: [ChecklistItem], isDone: Bool) -> [ChecklistItem] {
        items.map { item in
            var updated = item
            updated.isDone = isDone
            return updated
        }
    }

    /// Marks all items as done
    ///
    /// - Parameter items: The checklist items
    /// - Returns: New array with all items marked as done
    public static func markAllDone(_ items: [ChecklistItem]) -> [ChecklistItem] {
        toggleAll(items, isDone: true)
    }

    /// Marks all items as not done
    ///
    /// - Parameter items: The checklist items
    /// - Returns: New array with all items marked as not done
    public static func markAllUndone(_ items: [ChecklistItem]) -> [ChecklistItem] {
        toggleAll(items, isDone: false)
    }

    /// Counts the number of completed items
    ///
    /// - Parameter items: The checklist items
    /// - Returns: Count of items where isDone is true
    public static func countCompleted(_ items: [ChecklistItem]) -> Int {
        items.filter { $0.isDone }.count
    }

    /// Calculates completion percentage
    ///
    /// - Parameter items: The checklist items
    /// - Returns: Percentage of completed items (0.0 to 1.0), or 0 if empty
    public static func completionPercentage(_ items: [ChecklistItem]) -> Double {
        guard !items.isEmpty else { return 0 }
        return Double(countCompleted(items)) / Double(items.count)
    }

    /// Filters items by completion status
    ///
    /// - Parameters:
    ///   - items: The checklist items
    ///   - isDone: Filter for done (true) or undone (false) items
    /// - Returns: Filtered array of items
    public static func filter(_ items: [ChecklistItem], isDone: Bool) -> [ChecklistItem] {
        items.filter { $0.isDone == isDone }
    }

    /// Reorders an item within a checklist
    ///
    /// - Parameters:
    ///   - items: The checklist items
    ///   - from: Source index
    ///   - to: Destination index
    /// - Returns: New array with item moved, or original if indices invalid
    public static func reorder(_ items: [ChecklistItem], from: Int, to: Int) -> [ChecklistItem] {
        guard from >= 0, from < items.count,
              to >= 0, to < items.count,
              from != to else {
            return items
        }

        var result = items
        let item = result.remove(at: from)
        result.insert(item, at: to)
        return result
    }
}

// MARK: - ID Factories

/// Factory methods for creating typed IDs
public enum IDFactory {
    /// Creates a new BoardID with a random UUID
    public static func newBoardID() -> BoardID {
        BoardID()
    }

    /// Creates a BoardID from an existing UUID
    public static func boardID(from uuid: UUID) -> BoardID {
        BoardID(rawValue: uuid)
    }

    /// Creates a new ColumnID with a random UUID
    public static func newColumnID() -> ColumnID {
        ColumnID()
    }

    /// Creates a ColumnID from an existing UUID
    public static func columnID(from uuid: UUID) -> ColumnID {
        ColumnID(rawValue: uuid)
    }

    /// Creates a new CardID with a random UUID
    public static func newCardID() -> CardID {
        CardID()
    }

    /// Creates a CardID from an existing UUID
    public static func cardID(from uuid: UUID) -> CardID {
        CardID(rawValue: uuid)
    }

    /// Creates a new ListID with a random UUID
    public static func newListID() -> ListID {
        ListID()
    }

    /// Creates a ListID from an existing UUID
    public static func listID(from uuid: UUID) -> ListID {
        ListID(rawValue: uuid)
    }

    /// Creates a new RecipeID with a random UUID
    public static func newRecipeID() -> RecipeID {
        RecipeID()
    }

    /// Creates a RecipeID from an existing UUID
    public static func recipeID(from uuid: UUID) -> RecipeID {
        RecipeID(rawValue: uuid)
    }
}
