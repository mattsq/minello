import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text("HomeCooked")
                .navigationTitle("Boards")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(try! ModelContainerFactory.createInMemory())
}
