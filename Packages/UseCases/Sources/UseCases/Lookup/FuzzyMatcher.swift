// UseCases/Sources/UseCases/Lookup/FuzzyMatcher.swift
// Fuzzy string matching utilities for name lookup

import Foundation

/// Utilities for fuzzy string matching
public enum FuzzyMatcher {
    /// Calculate similarity score between two strings (0.0 - 1.0)
    /// Uses a combination of exact match, case-insensitive match, and substring matching
    ///
    /// - Parameters:
    ///   - query: The search query
    ///   - target: The target string to compare against
    /// - Returns: Similarity score from 0.0 (no match) to 1.0 (perfect match)
    public static func similarity(query: String, target: String) -> Double {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        let normalizedTarget = target.lowercased().trimmingCharacters(in: .whitespaces)

        // Exact match (case-insensitive)
        if normalizedQuery == normalizedTarget {
            return 1.0
        }

        // Empty query or target
        if normalizedQuery.isEmpty || normalizedTarget.isEmpty {
            return 0.0
        }

        // Prefix match
        if normalizedTarget.hasPrefix(normalizedQuery) {
            return 0.9
        }

        // Contains match
        if normalizedTarget.contains(normalizedQuery) {
            return 0.7
        }

        // Word-based matching (split on spaces and check if any word starts with query)
        let targetWords = normalizedTarget.split(separator: " ")
        for word in targetWords {
            if word.hasPrefix(normalizedQuery) {
                return 0.8
            }
            if word.contains(normalizedQuery) {
                return 0.6
            }
        }

        // Levenshtein distance for close matches
        let distance = levenshteinDistance(normalizedQuery, normalizedTarget)
        let maxLength = max(normalizedQuery.count, normalizedTarget.count)
        let similarity = 1.0 - (Double(distance) / Double(maxLength))

        // Only return if similarity is above threshold
        return similarity > 0.5 ? similarity * 0.5 : 0.0
    }

    /// Calculate Levenshtein distance between two strings
    /// - Parameters:
    ///   - s1: First string
    ///   - s2: Second string
    /// - Returns: The minimum number of single-character edits needed to transform s1 into s2
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let m = s1.count
        let n = s2.count

        if m == 0 { return n }
        if n == 0 { return m }

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        // Initialize first column and row
        for i in 0...m {
            matrix[i][0] = i
        }
        for j in 0...n {
            matrix[0][j] = j
        }

        // Calculate distances
        let s1Array = Array(s1)
        let s2Array = Array(s2)

        for i in 1...m {
            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,      // deletion
                    matrix[i][j - 1] + 1,      // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }

        return matrix[m][n]
    }

    /// Find best matches from a collection of items
    /// - Parameters:
    ///   - query: The search query
    ///   - items: Collection of items to search
    ///   - keyPath: Key path to the property to match against
    ///   - threshold: Minimum similarity score (default: 0.5)
    /// - Returns: Array of items sorted by similarity score (best match first)
    public static func findMatches<T>(
        query: String,
        in items: [T],
        by keyPath: KeyPath<T, String>,
        threshold: Double = 0.5
    ) -> [T] {
        let matches = items.map { item in
            (item: item, score: similarity(query: query, target: item[keyPath: keyPath]))
        }
        .filter { $0.score >= threshold }
        .sorted { $0.score > $1.score }

        return matches.map { $0.item }
    }
}
