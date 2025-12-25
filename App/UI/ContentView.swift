import SwiftUI

struct ContentView: View {
    var body: some View {
        BoardsListView()
    }
}

#Preview {
    let container = try! AppDependencyContainer.preview()
    return ContentView()
        .withDependencies(container)
}
