// SyncInterfaces/Sources/SyncInterfaces/SyncConflict.swift
// Conflict resolution for sync

import Domain
import Foundation

/// Represents a sync conflict between local and remote data
public enum SyncConflict: Equatable, Sendable {
    case board(local: Board, remote: Board)
    case column(local: Column, remote: Column)
    case card(local: Card, remote: Card)
    case list(local: PersonalList, remote: PersonalList)
    case recipe(local: Recipe, remote: Recipe)
}

/// Strategy for resolving sync conflicts
public enum ConflictResolutionStrategy: Sendable {
    /// Last-Write-Wins: choose the version with the most recent updatedAt
    case lastWriteWins
    /// Always prefer local version
    case preferLocal
    /// Always prefer remote version
    case preferRemote
}

/// Protocol for conflict resolution
public protocol ConflictResolver: Sendable {
    /// Resolve a conflict using the given strategy
    /// - Parameters:
    ///   - conflict: The conflict to resolve
    ///   - strategy: The resolution strategy to use
    /// - Returns: The resolved entity (as Any, caller must cast)
    func resolve(_ conflict: SyncConflict, strategy: ConflictResolutionStrategy) -> Any
}

/// Default implementation of Last-Write-Wins conflict resolution
public struct LWWConflictResolver: ConflictResolver {
    public init() {}

    public func resolve(_ conflict: SyncConflict, strategy: ConflictResolutionStrategy) -> Any {
        switch conflict {
        case let .board(local, remote):
            return resolveBoard(local: local, remote: remote, strategy: strategy)
        case let .column(local, remote):
            return resolveColumn(local: local, remote: remote, strategy: strategy)
        case let .card(local, remote):
            return resolveCard(local: local, remote: remote, strategy: strategy)
        case let .list(local, remote):
            return resolveList(local: local, remote: remote, strategy: strategy)
        case let .recipe(local, remote):
            return resolveRecipe(local: local, remote: remote, strategy: strategy)
        }
    }

    private func resolveBoard(local: Board, remote: Board, strategy: ConflictResolutionStrategy) -> Board {
        switch strategy {
        case .lastWriteWins:
            return local.updatedAt > remote.updatedAt ? local : remote
        case .preferLocal:
            return local
        case .preferRemote:
            return remote
        }
    }

    private func resolveColumn(local: Column, remote: Column, strategy: ConflictResolutionStrategy) -> Column {
        switch strategy {
        case .lastWriteWins:
            return local.updatedAt > remote.updatedAt ? local : remote
        case .preferLocal:
            return local
        case .preferRemote:
            return remote
        }
    }

    private func resolveCard(local: Card, remote: Card, strategy: ConflictResolutionStrategy) -> Card {
        switch strategy {
        case .lastWriteWins:
            return local.updatedAt > remote.updatedAt ? local : remote
        case .preferLocal:
            return local
        case .preferRemote:
            return remote
        }
    }

    private func resolveList(local: PersonalList, remote: PersonalList, strategy: ConflictResolutionStrategy) -> PersonalList {
        switch strategy {
        case .lastWriteWins:
            return local.updatedAt > remote.updatedAt ? local : remote
        case .preferLocal:
            return local
        case .preferRemote:
            return remote
        }
    }

    private func resolveRecipe(local: Recipe, remote: Recipe, strategy: ConflictResolutionStrategy) -> Recipe {
        switch strategy {
        case .lastWriteWins:
            return local.updatedAt > remote.updatedAt ? local : remote
        case .preferLocal:
            return local
        case .preferRemote:
            return remote
        }
    }
}
