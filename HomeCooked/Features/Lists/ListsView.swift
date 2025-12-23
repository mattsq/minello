import SwiftData
import SwiftUI

struct ListsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var lists: [PersonalList]

    @State private var selectedList: PersonalList?
    @State private var isCreatingList = false
    @State private var newListTitle = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(lists, id: \.id) { list in
                    NavigationLink(value: list) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(list.title)
                                .font(.headline)

                            if !list.items.isEmpty {
                                Text(
                                    "\(list.items.filter(\.isDone).count)/\(list.items.count) completed"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteLists)

                if isCreatingList {
                    HStack {
                        TextField("New list name", text: $newListTitle, onCommit: createList)
                            .textFieldStyle(.plain)

                        Button(action: createList) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                        .disabled(newListTitle.trimmingCharacters(in: .whitespaces).isEmpty)

                        Button(action: { isCreatingList = false
                            newListTitle = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Lists")
            .navigationDestination(for: PersonalList.self) { list in
                PersonalListDetailView(list: list)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isCreatingList = true }) {
                        Label("New List", systemImage: "plus")
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
        }
    }

    private func createList() {
        let trimmed = newListTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let newList = PersonalList(title: trimmed)
        modelContext.insert(newList)
        try? modelContext.save()

        newListTitle = ""
        isCreatingList = false
    }

    private func deleteLists(at offsets: IndexSet) {
        for index in offsets {
            let list = lists[index]
            modelContext.delete(list)
        }
        try? modelContext.save()
    }
}

struct PersonalListDetailView: View {
    @Bindable var list: PersonalList
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(spacing: 0) {
            ChecklistView(
                items: list.items,
                onAdd: { item in
                    item.personalList = list
                    list.items.append(item)
                    modelContext.insert(item)
                    try? modelContext.save()
                },
                onDelete: { item in
                    if let index = list.items.firstIndex(where: { $0.id == item.id }) {
                        list.items.remove(at: index)
                        modelContext.delete(item)
                        try? modelContext.save()
                    }
                },
                onMove: { indices, newOffset in
                    list.items.move(fromOffsets: indices, toOffset: newOffset)
                    try? modelContext.save()
                },
                onUpdate: { _ in
                    try? modelContext.save()
                }
            )
        }
        .navigationTitle(list.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                EditButton()
            }
        }
    }
}
