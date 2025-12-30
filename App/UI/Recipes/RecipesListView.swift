// App/UI/Recipes/RecipesListView.swift
// Main view showing list of all recipes

import SwiftUI
import Domain

/// Main view displaying all recipes with navigation
struct RecipesListView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @State private var recipes: [Recipe] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAddRecipe = false
    @State private var searchText = ""
    @State private var selectedTag: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading recipes...")
                        .accessibilityLabel("Loading recipes")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("Error Loading Recipes", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await loadRecipes() }
                        }
                        .accessibilityLabel("Retry loading recipes")
                    }
                } else if filteredRecipes.isEmpty {
                    emptyStateView
                } else {
                    recipesList
                }
            }
            .navigationTitle("Recipes")
            .searchable(text: $searchText, prompt: "Search recipes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddRecipe = true
                    } label: {
                        Label("Add Recipe", systemImage: "plus")
                    }
                    .accessibilityLabel("Add new recipe")
                }
            }
            .sheet(isPresented: $showingAddRecipe) {
                RecipeEditorView(mode: .create) { recipe in
                    Task {
                        await createRecipe(recipe)
                    }
                }
            }
        }
        .task {
            await loadRecipes()
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label(searchText.isEmpty ? "No Recipes" : "No Results", systemImage: "book.closed")
        } description: {
            Text(searchText.isEmpty ? "Create your first recipe to get started" : "No recipes match your search")
        } actions: {
            if searchText.isEmpty {
                Button("Add Recipe") {
                    showingAddRecipe = true
                }
                .accessibilityLabel("Add new recipe")
            }
        }
    }

    private var recipesList: some View {
        List {
            if !availableTags.isEmpty {
                tagFilterSection
            }

            ForEach(filteredRecipes, id: \.id) { recipe in
                NavigationLink(value: recipe) {
                    RecipeRow(recipe: recipe)
                }
                .accessibilityLabel("Recipe: \(recipe.title)")
            }
            .onDelete(perform: deleteRecipes)
        }
        .navigationDestination(for: Recipe.self) { recipe in
            RecipeDetailView(recipe: recipe, onUpdate: { updatedRecipe in
                Task { await updateRecipe(updatedRecipe) }
            }, onDelete: {
                Task { await deleteRecipe(recipe.id) }
            })
        }
        .refreshable {
            await loadRecipes()
        }
    }

    private var tagFilterSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    TagChip(title: "All", isSelected: selectedTag == nil) {
                        selectedTag = nil
                    }

                    ForEach(availableTags, id: \.self) { tag in
                        TagChip(title: tag, isSelected: selectedTag == tag) {
                            selectedTag = tag
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Computed Properties

    private var filteredRecipes: [Recipe] {
        var filtered = recipes

        // Filter by selected tag
        if let tag = selectedTag {
            filtered = filtered.filter { $0.tags.contains(tag) }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { recipe in
                recipe.title.localizedCaseInsensitiveContains(searchText) ||
                recipe.tags.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                recipe.methodMarkdown.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered.sorted { $0.title < $1.title }
    }

    private var availableTags: [String] {
        let allTags = recipes.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }

    // MARK: - Actions

    private func loadRecipes() async {
        isLoading = true
        errorMessage = nil

        do {
            let loadedRecipes = try await dependencies.repositoryProvider.recipesRepository.loadRecipes()
            recipes = loadedRecipes
            isLoading = false
        } catch {
            errorMessage = "Failed to load recipes: \(error.localizedDescription)"
            isLoading = false
        }
    }

    private func createRecipe(_ recipe: Recipe) async {
        do {
            try await dependencies.repositoryProvider.recipesRepository.createRecipe(recipe)
            await loadRecipes()
        } catch {
            errorMessage = "Failed to create recipe: \(error.localizedDescription)"
        }
    }

    private func updateRecipe(_ recipe: Recipe) async {
        do {
            try await dependencies.repositoryProvider.recipesRepository.updateRecipe(recipe)
            await loadRecipes()
        } catch {
            errorMessage = "Failed to update recipe: \(error.localizedDescription)"
        }
    }

    private func deleteRecipe(_ id: RecipeID) async {
        do {
            try await dependencies.repositoryProvider.recipesRepository.deleteRecipe(id)
            await loadRecipes()
        } catch {
            errorMessage = "Failed to delete recipe: \(error.localizedDescription)"
        }
    }

    private func deleteRecipes(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let recipe = filteredRecipes[index]
                await deleteRecipe(recipe.id)
            }
        }
    }
}

// MARK: - Recipe Row

private struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(recipe.title)
                .font(.headline)

            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundStyle(.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack {
                Label("\(recipe.ingredients.count)", systemImage: "list.bullet")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(recipe.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tag Chip

private struct TagChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .accessibilityLabel("\(title) tag\(isSelected ? ", selected" : "")")
    }
}

// MARK: - Previews

#Preview("With Recipes") {
    let container = try! AppDependencyContainer.preview()

    // Add sample recipes
    Task { @MainActor in
        let repo = container.repositoryProvider.recipesRepository
        try? await repo.createRecipe(Recipe(cardID: CardID(), 
            title: "Spaghetti Carbonara",
            ingredients: [
                ChecklistItem(text: "Spaghetti", quantity: 400, unit: "g"),
                ChecklistItem(text: "Eggs", quantity: 4),
                ChecklistItem(text: "Parmesan", quantity: 100, unit: "g"),
                ChecklistItem(text: "Bacon", quantity: 200, unit: "g")
            ],
            methodMarkdown: "1. Boil pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine",
            tags: ["Italian", "Pasta", "Quick"]
        ))
        try? await repo.createRecipe(Recipe(cardID: CardID(), 
            title: "Chicken Tikka Masala",
            ingredients: [
                ChecklistItem(text: "Chicken breast", quantity: 500, unit: "g"),
                ChecklistItem(text: "Yogurt", quantity: 200, unit: "ml"),
                ChecklistItem(text: "Tomato sauce", quantity: 400, unit: "ml")
            ],
            methodMarkdown: "1. Marinate chicken\n2. Grill chicken\n3. Make sauce\n4. Combine",
            tags: ["Indian", "Curry", "Spicy"]
        ))
    }

    RecipesListView()
        .withDependencies(container)
}

#Preview("Empty State") {
    let container = try! AppDependencyContainer.preview()
    RecipesListView()
        .withDependencies(container)
}
