// App/DI/RepositoryProvider.swift
// Protocol for providing repositories to the app

import Foundation
import PersistenceInterfaces

/// Protocol that defines how repositories are provided to the app
/// This allows swapping between GRDB and SwiftData implementations
@MainActor
protocol RepositoryProvider {
    /// The boards repository instance
    var boardsRepository: BoardsRepository { get }

    /// The lists repository instance
    var listsRepository: ListsRepository { get }
}
