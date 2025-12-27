import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BoardsListView()
                .tabItem {
                    Label("Boards", systemImage: "rectangle.stack")
                }
                .accessibilityLabel("Boards tab")

            ListsPlaceholderView()
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

// MARK: - Placeholder Views

private struct ListsPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView {
                Label("Lists", systemImage: "checklist")
            } description: {
                Text("Personal lists coming soon")
            }
            .navigationTitle("Lists")
        }
    }
}


// MARK: - Previews

#Preview {
    let container = try! AppDependencyContainer.preview()
    return ContentView()
        .withDependencies(container)
}
