// App/UI/Search/CardSearchView.swift
// Card-centric search view with filtering options

import SwiftUI
import Domain
import PersistenceInterfaces

/// Main search view for finding cards with advanced filters
struct CardSearchView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @State private var searchResults: [CardSearchResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var searchText = ""
    @State private var hasRecipeFilter: Bool? = nil
    @State private var hasListFilter: Bool? = nil
    @State private var selectedTag: String? = nil
    @State private var availableTags: [String] = []
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Searching...")
                        .accessibilityLabel("Searching cards")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("Search Error", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await performSearch() }
                        }
                        .accessibilityLabel("Retry search")
                    }
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView {
                        Label("No Results", systemImage: "magnifyingglass")
                    } description: {
                        Text("No cards match your search criteria")
                    }
                } else if searchResults.isEmpty {
                    emptyStateView
                } else {
                    resultsView
                }
            }
            .navigationTitle("Search Cards")
            .searchable(text: $searchText, prompt: "Search cards...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle" + (hasActiveFilters ? ".fill" : ""))
                    }
                    .accessibilityLabel("Toggle filters")
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(
                    hasRecipeFilter: $hasRecipeFilter,
                    hasListFilter: $hasListFilter,
                    selectedTag: $selectedTag,
                    availableTags: availableTags,
                    onApply: {
                        Task { await performSearch() }
                    },
                    onClear: {
                        clearFilters()
                        Task { await performSearch() }
                    }
                )
            }
        }
        .task(id: searchText) {
            // Debounce search by adding a small delay
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            await performSearch()
        }
        .task {
            await loadAvailableTags()
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("Search Cards", systemImage: "magnifyingglass")
        } description: {
            Text("Search for cards by title, description, tags, or filters")
        }
    }

    private var resultsView: some View {
        List {
            ForEach(searchResults, id: \.card.id) { result in
                NavigationLink {
                    // Navigate to card detail (placeholder for now - will need to pass proper dependencies)
                    CardResultDetailView(result: result)
                } label: {
                    CardSearchResultRow(result: result)
                }
                .accessibilityLabel("Card: \(result.card.title), in \(result.board.title)")
            }
        }
    }

    // MARK: - Computed Properties

    private var hasActiveFilters: Bool {
        hasRecipeFilter != nil || hasListFilter != nil || selectedTag != nil
    }

    // MARK: - Actions

    private func performSearch() async {
        guard !searchText.isEmpty || hasActiveFilters else {
            searchResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let filter = CardFilter(
                text: searchText.isEmpty ? nil : searchText,
                hasRecipe: hasRecipeFilter,
                hasList: hasListFilter,
                tag: selectedTag
            )

            let results = try await dependencies.repositoryProvider.searchRepository.searchCards(filter: filter)
            searchResults = results
            isLoading = false
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func loadAvailableTags() async {
        do {
            // Get all boards to extract unique tags
            let boards = try await dependencies.repositoryProvider.boardsRepository.loadBoards()
            var tags = Set<String>()

            for board in boards {
                let columns = try await dependencies.repositoryProvider.boardsRepository.loadColumns(for: board.id)
                for column in columns {
                    let cards = try await dependencies.repositoryProvider.boardsRepository.loadCards(for: column.id)
                    for card in cards {
                        tags.formUnion(card.tags)
                    }
                }
            }

            availableTags = Array(tags).sorted()
        } catch {
            // Silently fail - tags are just a convenience
            availableTags = []
        }
    }

    private func clearFilters() {
        hasRecipeFilter = nil
        hasListFilter = nil
        selectedTag = nil
    }
}

// MARK: - Filter View

private struct FilterView: View {
    @Binding var hasRecipeFilter: Bool?
    @Binding var hasListFilter: Bool?
    @Binding var selectedTag: String?
    let availableTags: [String]
    let onApply: () -> Void
    let onClear: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Recipe Filter") {
                    Picker("Recipe", selection: $hasRecipeFilter) {
                        Text("Any").tag(nil as Bool?)
                        Text("Has Recipe").tag(true as Bool?)
                        Text("No Recipe").tag(false as Bool?)
                    }
                    .pickerStyle(.segmented)
                }

                Section("List Filter") {
                    Picker("List", selection: $hasListFilter) {
                        Text("Any").tag(nil as Bool?)
                        Text("Has List").tag(true as Bool?)
                        Text("No List").tag(false as Bool?)
                    }
                    .pickerStyle(.segmented)
                }

                if !availableTags.isEmpty {
                    Section("Tag Filter") {
                        Picker("Tag", selection: $selectedTag) {
                            Text("Any Tag").tag(nil as String?)
                            ForEach(availableTags, id: \.self) { tag in
                                Text(tag).tag(tag as String?)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button("Clear All") {
                        onClear()
                    }
                    .disabled(hasRecipeFilter == nil && hasListFilter == nil && selectedTag == nil)
                }
            }
        }
    }
}

// MARK: - Card Search Result Row

private struct CardSearchResultRow: View {
    let result: CardSearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(result.card.title)
                    .font(.headline)

                Spacer()

                // Badges for recipe and list
                HStack(spacing: 4) {
                    if result.hasRecipe {
                        Image(systemName: "book.closed.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .accessibilityLabel("Has recipe")
                    }

                    if result.hasList {
                        Image(systemName: "checklist")
                            .font(.caption)
                            .foregroundStyle(.green)
                            .accessibilityLabel("Has list")
                    }
                }
            }

            // Board and column context
            HStack {
                Image(systemName: "rectangle.stack")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(result.board.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(result.column.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Card details preview (if not empty)
            if !result.card.details.isEmpty {
                Text(result.card.details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Tags
            if !result.card.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(result.card.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Placeholder Card Detail View

private struct CardResultDetailView: View {
    let result: CardSearchResult

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Context breadcrumb
                HStack {
                    Text(result.board.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(result.column.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()

                VStack(alignment: .leading, spacing: 8) {
                    Text(result.card.title)
                        .font(.title)
                        .fontWeight(.bold)

                    if !result.card.details.isEmpty {
                        Text(result.card.details)
                            .font(.body)
                    }

                    if !result.card.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(result.card.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.blue.opacity(0.1))
                                        .foregroundStyle(.blue)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    if result.hasRecipe {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(.blue)
                            Text("This card has a recipe attached")
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    if result.hasList {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundStyle(.green)
                            Text("This card has a list attached")
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Search View") {
    let container = try! AppDependencyContainer.preview()
    return CardSearchView()
        .withDependencies(container)
}
