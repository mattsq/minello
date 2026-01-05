// App/UI/Components/RecipeSectionView.swift
// Embedded recipe view for CardDetailView

import SwiftUI
import Domain

/// Collapsible recipe section for display within a card
struct RecipeSectionView: View {
    let recipe: Recipe?
    let onEdit: () -> Void
    let onDetach: () -> Void
    let onAttach: () -> Void

    @State private var isExpanded: Bool = true

    var body: some View {
        Section {
            if let recipe = recipe {
                // Recipe attached - show it
                VStack(alignment: .leading, spacing: 12) {
                    // Header with expand/collapse
                    Button {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .foregroundStyle(.blue)
                            Text(recipe.title)
                                .font(.headline)
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Recipe: \(recipe.title), \(isExpanded ? "expanded" : "collapsed")")

                    if isExpanded {
                        // Tags
                        if !recipe.tags.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(recipe.tags, id: \.self) { tag in
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.2))
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                        }

                        // Ingredients
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            if recipe.ingredients.isEmpty {
                                Text("No ingredients listed")
                                    .foregroundStyle(.secondary)
                                    .italic()
                                    .font(.caption)
                            } else {
                                ForEach(recipe.ingredients, id: \.id) { ingredient in
                                    HStack(spacing: 8) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 5))
                                            .foregroundStyle(.secondary)

                                        if let quantity = ingredient.quantity {
                                            Text(formatQuantity(quantity))
                                                .fontWeight(.medium)
                                                .font(.caption)
                                        }
                                        if let unit = ingredient.unit {
                                            Text(unit)
                                                .fontWeight(.medium)
                                                .font(.caption)
                                        }
                                        Text(ingredient.text)
                                            .font(.caption)
                                    }
                                }
                            }
                        }

                        // Method preview
                        if !recipe.methodMarkdown.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Method")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text(recipe.methodMarkdown)
                                    .font(.caption)
                                    .lineLimit(5)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        // Actions
                        HStack(spacing: 16) {
                            Button {
                                onEdit()
                            } label: {
                                Label("Edit Recipe", systemImage: "pencil")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)

                            Button(role: .destructive) {
                                onDetach()
                            } label: {
                                Label("Detach", systemImage: "link.badge.minus")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            } else {
                // No recipe attached - show attach button
                Button {
                    onAttach()
                } label: {
                    HStack {
                        Image(systemName: "book.closed")
                            .foregroundStyle(.secondary)
                        Text("Attach Recipe")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Attach recipe to this card")
            }
        } header: {
            if recipe == nil {
                Text("Recipe")
            }
        }
    }

    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", quantity)
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

// MARK: - Previews

#Preview("With Recipe") {
    let recipe = Recipe(
        cardID: CardID(),
        title: "Pasta Carbonara",
        ingredients: [
            ChecklistItem(text: "Pasta", isDone: false, quantity: 400, unit: "g"),
            ChecklistItem(text: "Eggs", isDone: false, quantity: 3, unit: nil),
            ChecklistItem(text: "Parmesan", isDone: false, quantity: 100, unit: "g")
        ],
        methodMarkdown: """
        1. Cook pasta according to package
        2. Beat eggs with cheese
        3. Mix hot pasta with egg mixture
        """,
        tags: ["Italian", "Quick"]
    )

    Form {
        RecipeSectionView(
            recipe: recipe,
            onEdit: {},
            onDetach: {},
            onAttach: {}
        )
    }
}

#Preview("Without Recipe") {
    Form {
        RecipeSectionView(
            recipe: nil,
            onEdit: {},
            onDetach: {},
            onAttach: {}
        )
    }
}
