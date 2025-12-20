import SwiftUI
import SwiftData

@main
struct HomeCookedApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainerFactory.create()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
