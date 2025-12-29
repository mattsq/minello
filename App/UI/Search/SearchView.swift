// App/UI/Search/SearchView.swift
// Unified search view across all entity types

import SwiftUI
import Domain

/// View for searching across boards, cards, lists, and recipes
struct SearchView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @State private var searchText = ""
    @State private var results: [SearchResult] = []
    @State private var recentSearches: [String] = []
    @State private var selectedFilters: Set<EntityType> = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                if !selectedFilters.isEmpty {
                    filterChipsView
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                // Content
                Group {
                    if searchText.isEmpty {
                        recentSearchesView
                    } else if isSearching {
                        ProgressView("Searching...")
                            .accessibilityLabel("Searching")
                    } else if let error = errorMessage {
                        errorView(error)
                    } else if results.isEmpty {
                        emptyResultsView
                    } else {
                        resultsListView
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search boards, cards, lists, recipes..."
            )
            .onChange(of: searchText) { oldValue, newValue in
                Task { await performSearch(query: newValue) }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Label(
                            selectedFilters.isEmpty ? "Filter" : "Filters (\(selectedFilters.count))",
                            systemImage: selectedFilters.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"
                        )
                    }
                    .accessibilityLabel(selectedFilters.isEmpty ? "Show filters" : "Filters active, \(selectedFilters.count) selected")
                }
            }
            .sheet(isPresented: $showingFilters) {
                filtersSheet
            }
        }
        .task {
            await loadRecentSearches()
        }
    }

    // MARK: - Filter Chips View

    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(selectedFilters), id: \.self) { filter in
                    HStack(spacing: 4) {
                        Text(filter.rawValue)
                            .font(.caption)
                        Button {
                            selectedFilters.remove(filter)
                            Task { await performSearch(query: searchText) }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                        }
                        .accessibilityLabel("Remove \(filter.rawValue) filter")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(16)
                }
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Recent Searches View

    private var recentSearchesView: some View {
        Group {
            if recentSearches.isEmpty {
                ContentUnavailableView {
                    Label("No Recent Searches", systemImage: "magnifyingglass")
                } description: {
                    Text("Your recent searches will appear here")
                }
            } else {
                List {
                    Section("Recent Searches") {
                        ForEach(recentSearches, id: \.self) { query in
                            Button {
                                searchText = query
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text(query)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                            .accessibilityLabel("Recent search: \(query)")
                        }
                    }

                    Section {
                        Button(role: .destructive) {
                            Task { await clearRecentSearches() }
                        } label: {
                            Label("Clear Recent Searches", systemImage: "trash")
                        }
                        .accessibilityLabel("Clear all recent searches")
                    }
                }
            }
        }
    }

    // MARK: - Results List View

    private var resultsListView: some View {
        List {
            // Group results by entity type
            ForEach(EntityType.allCases, id: \.self) { entityType in
                let filtered = results.filter { $0.entityType == entityType }
                if !filtered.isEmpty {
                    Section(entityType.rawValue + "s") {
                        ForEach(filtered, id: \.hashValue) { result in
                            resultRow(result)
                        }
                    }
                }
            }
        }
        .accessibilityLabel("\(results.count) results found")
    }

    @ViewBuilder
    private func resultRow(_ result: SearchResult) -> some View {
        switch result {
        case .board(let board):
            NavigationLink {
                BoardDetailView(boardID: board.id)
            } label: {
                HStack {
                    Image(systemName: "rectangle.stack")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text(board.title)
                            .font(.headline)
                        Text("\(board.columns.count) columns")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .accessibilityLabel("Board: \(board.title), \(board.columns.count) columns")

        case .card(let card):
            NavigationLink {
                CardDetailView(cardID: card.id)
            } label: {
                HStack {
                    Image(systemName: "doc.text")
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text(card.title)
                            .font(.headline)
                        if !card.details.isEmpty {
                            Text(card.details)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .accessibilityLabel("Card: \(card.title)")

        case .list(let list):
            NavigationLink {
                ListDetailView(listID: list.id)
            } label: {
                HStack {
                    Image(systemName: "checklist")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text(list.title)
                            .font(.headline)
                        Text("\(list.items.count) items")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .accessibilityLabel("List: \(list.title), \(list.items.count) items")

        case .recipe(let recipe):
            NavigationLink {
                RecipeDetailView(recipeID: recipe.id)
            } label: {
                HStack {
                    Image(systemName: "book")
                        .foregroundColor(.purple)
                    VStack(alignment: .leading) {
                        Text(recipe.title)
                            .font(.headline)
                        if !recipe.tags.isEmpty {
                            Text(recipe.tags.joined(separator: ", "))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .accessibilityLabel("Recipe: \(recipe.title)")
        }
    }

    // MARK: - Empty Results View

    private var emptyResultsView: some View {
        ContentUnavailableView {
            Label("No Results", systemImage: "magnifyingglass")
        } description: {
            Text("No results found for \"\(searchText)\"")
        } actions: {
            Button("Clear Filters") {
                selectedFilters.removeAll()
                Task { await performSearch(query: searchText) }
            }
            .accessibilityLabel("Clear all filters")
        }
    }

    // MARK: - Error View

    private func errorView(_ error: String) -> some View {
        ContentUnavailableView {
            Label("Search Error", systemImage: "exclamationmark.triangle")
        } description: {
            Text(error)
        } actions: {
            Button("Retry") {
                Task { await performSearch(query: searchText) }
            }
            .accessibilityLabel("Retry search")
        }
    }

    // MARK: - Filters Sheet

    private var filtersSheet: some View {
        NavigationStack {
            List {
                Section("Filter by Type") {
                    ForEach(EntityType.allCases, id: \.self) { entityType in
                        Toggle(isOn: Binding(
                            get: { selectedFilters.contains(entityType) },
                            set: { isSelected in
                                if isSelected {
                                    selectedFilters.insert(entityType)
                                } else {
                                    selectedFilters.remove(entityType)
                                }
                            }
                        )) {
                            Label(entityType.rawValue + "s", systemImage: iconName(for: entityType))
                        }
                        .accessibilityLabel("\(entityType.rawValue) filter")
                    }
                }

                Section {
                    Button("Clear All Filters") {
                        selectedFilters.removeAll()
                    }
                    .disabled(selectedFilters.isEmpty)
                    .accessibilityLabel("Clear all filters")
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showingFilters = false
                        Task { await performSearch(query: searchText) }
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Helper Methods

    private func iconName(for entityType: EntityType) -> String {
        switch entityType {
        case .board: return "rectangle.stack"
        case .card: return "doc.text"
        case .list: return "checklist"
        case .recipe: return "book"
        }
    }

    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            results = []
            errorMessage = nil
            return
        }

        isSearching = true
        errorMessage = nil

        do {
            let filters: Set<EntityType>? = selectedFilters.isEmpty ? nil : selectedFilters
            results = try await dependencies.searchRepository.search(query: query, filters: filters)
            isSearching = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isSearching = false
        }
    }

    private func loadRecentSearches() async {
        do {
            recentSearches = try await dependencies.searchRepository.loadRecentSearches(limit: 10)
        } catch {
            // Silently fail - recent searches are not critical
        }
    }

    private func clearRecentSearches() async {
        do {
            try await dependencies.searchRepository.clearRecentSearches()
            recentSearches = []
        } catch {
            errorMessage = "Failed to clear recent searches: \(error.localizedDescription)"
        }
    }
}

#Preview {
    SearchView()
        .environmentObject(AppDependencyContainer.preview)
}
