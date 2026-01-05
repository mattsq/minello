import SwiftUI
import Domain

struct ContentView: View {
    var body: some View {
        TabView {
            BoardsListView()
                .tabItem {
                    Label("Boards", systemImage: "rectangle.stack")
                }
                .accessibilityLabel("Boards tab")

            CardSearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .accessibilityLabel("Search tab")
        }
    }
}

// MARK: - Previews

#Preview {
    let container = try! AppDependencyContainer.preview()
    return ContentView()
        .withDependencies(container)
}
