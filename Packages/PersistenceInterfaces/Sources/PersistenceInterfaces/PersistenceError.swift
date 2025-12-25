// PersistenceInterfaces/Sources/PersistenceInterfaces/PersistenceError.swift
// Error types for persistence operations

import Foundation

/// Errors that can occur during persistence operations
public enum PersistenceError: Error, Equatable {
    /// Entity not found
    case notFound(String)

    /// Invalid data or state
    case invalidData(String)

    /// Database constraint violation (e.g., foreign key, unique)
    case constraintViolation(String)

    /// Database connection or access error
    case databaseError(String)

    /// Concurrency conflict (optimistic locking)
    case concurrencyConflict(String)

    /// Generic operation failure
    case operationFailed(String)
}

extension PersistenceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notFound(let message):
            return "Not found: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .constraintViolation(let message):
            return "Constraint violation: \(message)"
        case .databaseError(let message):
            return "Database error: \(message)"
        case .concurrencyConflict(let message):
            return "Concurrency conflict: \(message)"
        case .operationFailed(let message):
            return "Operation failed: \(message)"
        }
    }
}
