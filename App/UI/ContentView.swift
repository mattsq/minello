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

            ListsView()
                .tabItem {
                    Label("Lists", systemImage: "checklist")
                }
                .accessibilityLabel("Lists tab")

            RecipesListView()
                .tabItem {
                    Label("Recipes", systemImage: "book.closed")
                }
                .accessibilityLabel("Recipes tab")
        }
    }
}

// MARK: - Previews

#Preview {
    let container = try! AppDependencyContainer.preview()
    return ContentView()
        .withDependencies(container)
}
