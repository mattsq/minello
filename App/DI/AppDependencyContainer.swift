// App/DI/AppDependencyContainer.swift
// Main dependency injection container for the app

import Foundation
import SwiftUI
import PersistenceInterfaces

/// Main dependency container for the app
/// Use as an environment object to access repositories throughout the view hierarchy
@MainActor
final class AppDependencyContainer: ObservableObject {
    let repositoryProvider: RepositoryProvider

    init(repositoryProvider: RepositoryProvider) {
        self.repositoryProvider = repositoryProvider
    }

    /// Default container using GRDB with a file-based database
    static func `default`() throws -> AppDependencyContainer {
        let fileURL = try defaultDatabaseURL()
        let provider = try GRDBRepositoryProvider(databaseURL: fileURL)
        return AppDependencyContainer(repositoryProvider: provider)
    }

    /// Container for SwiftUI previews using in-memory database
    static func preview() throws -> AppDependencyContainer {
        let provider = try GRDBRepositoryProvider.inMemory()
        return AppDependencyContainer(repositoryProvider: provider)
    }

    // MARK: - Helper Methods

    private static func defaultDatabaseURL() throws -> URL {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let appDir = appSupport.appendingPathComponent("HomeCooked", isDirectory: true)
        try fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)

        return appDir.appendingPathComponent("homecooked.db")
    }
}

// MARK: - Environment Key

private struct AppDependencyContainerKey: EnvironmentKey {
    static let defaultValue: AppDependencyContainer? = nil
}

extension EnvironmentValues {
    var dependencies: AppDependencyContainer? {
        get { self[AppDependencyContainerKey.self] }
        set { self[AppDependencyContainerKey.self] = newValue }
    }
}

extension View {
    /// Inject dependencies into the view hierarchy
    func withDependencies(_ container: AppDependencyContainer) -> some View {
        self.environmentObject(container)
            .environment(\.dependencies, container)
    }
}
