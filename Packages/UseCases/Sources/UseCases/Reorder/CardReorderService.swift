// UseCases/Sources/UseCases/Reorder/CardReorderService.swift
// Service for managing card reordering with midpoint calculation and normalization

import Foundation
import Domain

/// Service for managing card reordering operations
///
/// This service provides thread-safe reordering operations using fractional sort keys.
/// It calculates midpoints between cards and provides background normalization to
/// prevent precision issues from repeated reordering.
public actor CardReorderService {

    /// Configuration for the reorder service
    public struct Configuration: Sendable {
        /// Threshold for triggering normalization (when keys are too close)
        public let normalizationThreshold: Double

        /// Debounce interval for idle normalization (in seconds)
        public let idleNormalizationDelay: TimeInterval

        public init(
            normalizationThreshold: Double = 0.0001,
            idleNormalizationDelay: TimeInterval = 2.0
        ) {
            self.normalizationThreshold = normalizationThreshold
            self.idleNormalizationDelay = idleNormalizationDelay
        }
    }

    private let configuration: Configuration
    private var normalizationTask: Task<Void, Never>?

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    // MARK: - Public API

    /// Calculate the midpoint between two sort keys
    ///
    /// - Parameters:
    ///   - after: The sort key of the card after which to insert (nil if inserting at start)
    ///   - before: The sort key of the card before which to insert (nil if inserting at end)
    /// - Returns: The calculated midpoint sort key
    public func calculateMidpoint(after: Double?, before: Double?) -> Double {
        switch (after, before) {
        case let (.some(x), .some(y)):
            // Between two cards: average of the two keys
            return (x + y) / 2
        case let (.some(x), .none):
            // After last card: add 1
            return x + 1
        case let (.none, .some(y)):
            // Before first card: subtract 1
            return y - 1
        default:
            // Empty list: start at 0
            return 0
        }
    }

    /// Normalize a set of sort keys to sequential integers
    ///
    /// This prevents precision issues from repeated midpoint calculations.
    ///
    /// - Parameter keys: Array of sort keys to normalize (modified in place)
    /// - Returns: The normalized array of sort keys
    public func normalize(_ keys: inout [Double]) {
        for i in keys.indices {
            keys[i] = Double(i)
        }
    }

    /// Check if normalization is needed based on minimum key spacing
    ///
    /// - Parameter keys: Array of sort keys to check
    /// - Returns: True if any adjacent keys are closer than the normalization threshold
    public func needsNormalization(_ keys: [Double]) -> Bool {
        guard keys.count > 1 else { return false }

        let sorted = keys.sorted()
        for i in 0..<(sorted.count - 1) {
            let gap = sorted[i + 1] - sorted[i]
            if gap < configuration.normalizationThreshold {
                return true
            }
        }
        return false
    }

    /// Schedule idle normalization
    ///
    /// This debounced operation runs after a period of inactivity.
    /// The actual persistence of normalized keys is handled by the caller.
    ///
    /// - Parameter action: Closure to execute when normalization should occur
    public func scheduleIdleNormalization(action: @escaping @Sendable () async -> Void) {
        // Cancel any pending normalization
        normalizationTask?.cancel()

        // Schedule new normalization after idle delay
        normalizationTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(configuration.idleNormalizationDelay * 1_000_000_000))

            guard !Task.isCancelled else { return }
            await action()
        }
    }

    /// Cancel any pending idle normalization
    public func cancelIdleNormalization() {
        normalizationTask?.cancel()
        normalizationTask = nil
    }

    // MARK: - Convenience Methods

    /// Calculate a new sort key for moving a card between two positions
    ///
    /// - Parameters:
    ///   - previousKey: The sort key of the card before the new position (nil if moving to start)
    ///   - nextKey: The sort key of the card after the new position (nil if moving to end)
    /// - Returns: The new sort key for the moved card
    public func calculateSortKey(previousKey: Double?, nextKey: Double?) -> Double {
        calculateMidpoint(after: previousKey, before: nextKey)
    }

    /// Generate normalized sort keys for a collection of items
    ///
    /// - Parameter count: Number of items to generate keys for
    /// - Returns: Array of normalized sort keys [0.0, 1.0, 2.0, ...]
    public func generateNormalizedKeys(count: Int) -> [Double] {
        (0..<count).map { Double($0) }
    }
}

// MARK: - Sendable Conformance

extension CardReorderService: Sendable {}
