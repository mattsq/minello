import SwiftUI

@main
struct HomeCookedApp: App {
    @StateObject private var dependencies: AppDependencyContainer

    init() {
        // Initialize dependency container
        // Use default GRDB-based repositories
        do {
            let container = try AppDependencyContainer.default()
            _dependencies = StateObject(wrappedValue: container)
            // Set shared instance for App Intents
            Task { @MainActor in
                AppDependencyContainer.shared = container
            }
        } catch {
            // If initialization fails, use an in-memory database for development
            print("Warning: Failed to initialize default database: \(error)")
            print("Using in-memory database instead")
            do {
                let container = try AppDependencyContainer.preview()
                _dependencies = StateObject(wrappedValue: container)
                // Set shared instance for App Intents
                Task { @MainActor in
                    AppDependencyContainer.shared = container
                }
            } catch {
                fatalError("Failed to initialize app dependencies: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .withDependencies(dependencies)
        }
    }
}
