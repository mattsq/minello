// App/UI/Lists/ListsView.swift
// Main view showing all personal lists

import SwiftUI
import Domain

/// Main view displaying all personal lists with navigation
struct ListsView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @State private var lists: [PersonalList] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAddList = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading lists...")
                        .accessibilityLabel("Loading lists")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("Error Loading Lists", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await loadLists() }
                        }
                        .accessibilityLabel("Retry loading lists")
                    }
                } else if filteredLists.isEmpty {
                    emptyStateView
                } else {
                    listsView
                }
            }
            .navigationTitle("Lists")
            .searchable(text: $searchText, prompt: "Search lists")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddList = true
                    } label: {
                        Label("Add List", systemImage: "plus")
                    }
                    .accessibilityLabel("Add new list")
                }
            }
            .sheet(isPresented: $showingAddList) {
                ListEditorView(mode: .create) { list in
                    Task {
                        await createList(list)
                    }
                }
            }
        }
        .task {
            await loadLists()
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(searchText.isEmpty ? "No Lists" : "No Results", systemImage: "checklist")
        } description: {
            Text(searchText.isEmpty ? "Create your first list to get started" : "No lists match your search")
        } actions: {
            if searchText.isEmpty {
                Button("Add List") {
                    showingAddList = true
                }
                .accessibilityLabel("Add new list")
            }
        }
    }

    private var listsView: some View {
        List {
            ForEach(filteredLists, id: \.id) { list in
                NavigationLink(value: list) {
                    ListRow(list: list)
                }
                .accessibilityLabel("List: \(list.title)")
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task { await deleteList(list.id) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .accessibilityLabel("Delete \(list.title)")
                }
            }
        }
        .navigationDestination(for: PersonalList.self) { list in
            ListDetailView(list: list, onUpdate: { updatedList in
                Task { await updateList(updatedList) }
            }, onDelete: {
                Task { await deleteList(list.id) }
            })
        }
        .refreshable {
            await loadLists()
        }
    }

    // MARK: - Computed Properties

    private var filteredLists: [PersonalList] {
        var filtered = lists

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { list in
                list.title.localizedCaseInsensitiveContains(searchText) ||
                list.items.contains { $0.text.localizedCaseInsensitiveContains(searchText) }
            }
        }

        return filtered.sorted { $0.title < $1.title }
    }

    // MARK: - Actions

    private func loadLists() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedLists = try await dependencies.repositoryProvider.listsRepository.loadLists()
            lists = loadedLists
            isLoading = false
        } catch {
            errorMessage = "Failed to load lists: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func createList(_ list: PersonalList) async {
        do {
            try await dependencies.repositoryProvider.listsRepository.createList(list)
            await loadLists()
        } catch {
            errorMessage = "Failed to create list: \(error.localizedDescription)"
        }
    }

    private func updateList(_ list: PersonalList) async {
        do {
            try await dependencies.repositoryProvider.listsRepository.updateList(list)
            await loadLists()
        } catch {
            errorMessage = "Failed to update list: \(error.localizedDescription)"
        }
    }

    private func deleteList(_ id: ListID) async {
        do {
            try await dependencies.repositoryProvider.listsRepository.deleteList(id)
            await loadLists()
        } catch {
            errorMessage = "Failed to delete list: \(error.localizedDescription)"
        }
    }
}

// MARK: - List Row

private struct ListRow: View {
    let list: PersonalList

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(list.title)
                .font(.headline)

            HStack {
                Label("\(list.items.count)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if incompleteCount > 0 {
                    Label("\(incompleteCount) unchecked", systemImage: "circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(list.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var incompleteCount: Int {
        list.items.filter { !$0.isDone }.count
    }
}

// MARK: - Previews

#Preview("With Lists") {
    let container = try! AppDependencyContainer.preview()

    // Add sample lists
    Task { @MainActor in
        let repo = container.repositoryProvider.listsRepository
        try? await repo.createList(PersonalList(cardID: CardID(), 
            title: "Groceries",
            items: [
                ChecklistItem(text: "Milk", isDone: false, quantity: 2, unit: "L"),
                ChecklistItem(text: "Bread", isDone: true, quantity: 1),
                ChecklistItem(text: "Eggs", isDone: false, quantity: 12),
                ChecklistItem(text: "Coffee", isDone: false, quantity: 500, unit: "g")
            ]
        ))
        try? await repo.createList(PersonalList(cardID: CardID(), 
            title: "Packing List",
            items: [
                ChecklistItem(text: "Passport", isDone: true),
                ChecklistItem(text: "Tickets", isDone: true),
                ChecklistItem(text: "Sunscreen", isDone: false),
                ChecklistItem(text: "Hat", isDone: false)
            ]
        ))
        try? await repo.createList(PersonalList(cardID: CardID(), 
            title: "Hardware Store",
            items: [
                ChecklistItem(text: "Screws", isDone: false, quantity: 50),
                ChecklistItem(text: "Paint", isDone: false, quantity: 2, unit: "L", note: "White matte"),
                ChecklistItem(text: "Sandpaper", isDone: false)
            ]
        ))
    }

    ListsView()
        .withDependencies(container)
}

#Preview("Empty State") {
    let container = try! AppDependencyContainer.preview()
    ListsView()
        .withDependencies(container)
}
