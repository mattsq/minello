// App/UI/Recipes/RecipeDetailView.swift
// Detail view for displaying and editing a recipe

import SwiftUI
import Domain

/// View for displaying recipe details with ingredients and method
struct RecipeDetailView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe
    let onUpdate: (Recipe) -> Void
    let onDelete: () -> Void

    @State private var showingEditor = false
    @State private var showingDeleteConfirmation = false
    @State private var showingAddToListSheet = false
    @State private var selectedList: PersonalList?
    @State private var availableLists: [PersonalList] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with title and tags
                headerSection

                // Ingredients section
                ingredientsSection

                // Method section
                methodSection
            }
            .padding()
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditor = true
                    } label: {
                        Label("Edit Recipe", systemImage: "pencil")
                    }

                    Button {
                        Task { await loadListsAndShowSheet() }
                    } label: {
                        Label("Add to Shopping List", systemImage: "cart.badge.plus")
                    }

                    Divider()

                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete Recipe", systemImage: "trash")
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
                .accessibilityLabel("Recipe actions")
            }
        }
        .sheet(isPresented: $showingEditor) {
            RecipeEditorView(mode: .edit(recipe)) { updatedRecipe in
                onUpdate(updatedRecipe)
                showingEditor = false
            }
        }
        .sheet(isPresented: $showingAddToListSheet) {
            AddToListSheet(
                recipe: recipe,
                lists: availableLists,
                onAddToList: { list in
                    Task { await addIngredientsToList(list) }
                }
            )
        }
        .alert("Delete Recipe", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(recipe.title)'? This action cannot be undone.")
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !recipe.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recipe.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.2))
                                .foregroundStyle(.primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack {
                Label("\(recipe.ingredients.count) ingredients", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Updated \(recipe.updatedAt, style: .relative)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.title2)
                .fontWeight(.bold)

            if recipe.ingredients.isEmpty {
                Text("No ingredients listed")
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(recipe.ingredients, id: \.id) { ingredient in
                        IngredientRow(ingredient: ingredient)
                    }
                }
            }
        }
    }

    private var methodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Method")
                .font(.title2)
                .fontWeight(.bold)

            if recipe.methodMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("No method provided")
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                Text(recipe.methodMarkdown)
                    .textSelection(.enabled)
            }
        }
    }

    // MARK: - Actions

    private func loadListsAndShowSheet() async {
        do {
            let lists = try await dependencies.repositoryProvider.listsRepository.loadLists()
            availableLists = lists
            showingAddToListSheet = true
        } catch {
            // Show error - for now just print
            print("Failed to load lists: \(error)")
        }
    }

    private func addIngredientsToList(_ list: PersonalList) async {
        do {
            var updatedList = list
            // Add recipe ingredients to the list
            let newItems = recipe.ingredients.map { ingredient in
                ChecklistItem(
                    text: ingredient.text,
                    isDone: false,
                    quantity: ingredient.quantity,
                    unit: ingredient.unit,
                    note: "From \(recipe.title)"
                )
            }
            updatedList.items.append(contentsOf: newItems)
            updatedList.updatedAt = Date()

            try await dependencies.repositoryProvider.listsRepository.updateList(updatedList)
            showingAddToListSheet = false
        } catch {
            print("Failed to add ingredients to list: \(error)")
        }
    }
}

// MARK: - Ingredient Row

private struct IngredientRow: View {
    let ingredient: ChecklistItem

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    if let quantity = ingredient.quantity {
                        Text(formatQuantity(quantity))
                            .fontWeight(.medium)
                    }
                    if let unit = ingredient.unit {
                        Text(unit)
                            .fontWeight(.medium)
                    }
                    Text(ingredient.text)
                }

                if let note = ingredient.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

// MARK: - Add to List Sheet

private struct AddToListSheet: View {
    @Environment(\.dismiss) private var dismiss

    let recipe: Recipe
    let lists: [PersonalList]
    let onAddToList: (PersonalList) -> Void

    var body: some View {
        NavigationStack {
            Group {
                if lists.isEmpty {
                    ContentUnavailableView {
                        Label("No Lists", systemImage: "checklist")
                    } description: {
                        Text("Create a shopping list first to add ingredients")
                    }
                } else {
                    List {
                        ForEach(lists, id: \.id) { list in
                            Button {
                                onAddToList(list)
                                dismiss()
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.title)
                                        .font(.headline)
                                    Text("\(list.items.count) items")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let container = try! AppDependencyContainer.preview()

    let recipe = Recipe(
        title: "Spaghetti Carbonara",
        ingredients: [
            ChecklistItem(text: "Spaghetti", isDone: false, quantity: 400, unit: "g"),
            ChecklistItem(text: "Eggs", isDone: false, quantity: 4, unit: nil),
            ChecklistItem(text: "Parmesan", isDone: false, quantity: 100, unit: "g", note: "Freshly grated"),
            ChecklistItem(text: "Bacon", isDone: false, quantity: 200, unit: "g")
        ],
        methodMarkdown: """
        # Instructions

        1. Bring a large pot of salted water to boil
        2. Cook spaghetti according to package directions
        3. Meanwhile, fry bacon until crispy
        4. Beat eggs with grated Parmesan cheese
        5. Drain pasta, reserving 1 cup pasta water
        6. Toss hot pasta with bacon and egg mixture
        7. Add pasta water as needed for creaminess
        8. Serve immediately with extra Parmesan
        """,
        tags: ["Italian", "Pasta", "Quick"]
    )

    return NavigationStack {
        RecipeDetailView(
            recipe: recipe,
            onUpdate: { _ in },
            onDelete: {}
        )
    }
    .withDependencies(container)
}
