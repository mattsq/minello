// App/UI/Recipes/RecipeEditorView.swift
// Editor view for creating and editing recipes

import SwiftUI
import Domain

/// Editor view for creating or editing a recipe
struct RecipeEditorView: View {
    enum Mode {
        case create(cardID: CardID)
        case edit(Recipe)

        var title: String {
            switch self {
            case .create: return "New Recipe"
            case .edit: return "Edit Recipe"
            }
        }

        var saveButtonTitle: String {
            switch self {
            case .create: return "Create"
            case .edit: return "Save"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss

    let mode: Mode
    let onSave: (Recipe) -> Void

    @State private var title: String
    @State private var ingredients: [ChecklistItem]
    @State private var methodMarkdown: String
    @State private var tags: [String]
    @State private var tagInput: String = ""
    @State private var showingAddIngredient = false

    init(mode: Mode, onSave: @escaping (Recipe) -> Void) {
        self.mode = mode
        self.onSave = onSave

        switch mode {
        case .create:
            _title = State(initialValue: "")
            _ingredients = State(initialValue: [])
            _methodMarkdown = State(initialValue: "")
            _tags = State(initialValue: [])
        case .edit(let recipe):
            _title = State(initialValue: recipe.title)
            _ingredients = State(initialValue: recipe.ingredients)
            _methodMarkdown = State(initialValue: recipe.methodMarkdown)
            _tags = State(initialValue: recipe.tags)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                // Basic Info Section
                Section("Basic Information") {
                    TextField("Recipe Title", text: $title)
                        .accessibilityLabel("Recipe title")

                    tagsEditor
                }

                // Ingredients Section
                Section {
                    if ingredients.isEmpty {
                        Text("No ingredients added")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(ingredients.indices, id: \.self) { index in
                            IngredientEditorRow(
                                ingredient: $ingredients[index],
                                onDelete: {
                                    ingredients.remove(at: index)
                                }
                            )
                        }
                    }

                    Button {
                        showingAddIngredient = true
                    } label: {
                        Label("Add Ingredient", systemImage: "plus.circle.fill")
                    }
                    .accessibilityLabel("Add ingredient")
                } header: {
                    Text("Ingredients")
                }

                // Method Section
                Section("Method") {
                    TextEditor(text: $methodMarkdown)
                        .frame(minHeight: 200)
                        .accessibilityLabel("Recipe method")
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(mode.saveButtonTitle) {
                        saveRecipe()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showingAddIngredient) {
                AddIngredientSheet { ingredient in
                    ingredients.append(ingredient)
                }
            }
        }
    }

    // MARK: - View Components

    private var tagsEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagPill(tag: tag) {
                            tags.removeAll { $0 == tag }
                        }
                    }
                }
            }

            HStack {
                TextField("Add tag", text: $tagInput)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityLabel("Tag input")
                    .onSubmit {
                        addTag()
                    }

                Button {
                    addTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                }
                .disabled(tagInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .accessibilityLabel("Add tag")
            }
        }
    }

    // MARK: - Computed Properties

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagInput = ""
    }

    private func saveRecipe() {
        let recipe: Recipe
        switch mode {
        case .create(let cardID):
            recipe = Recipe(
                cardID: cardID,
                title: title.trimmingCharacters(in: .whitespaces),
                ingredients: ingredients,
                methodMarkdown: methodMarkdown,
                tags: tags
            )
        case .edit(let existing):
            recipe = Recipe(
                id: existing.id,
                cardID: existing.cardID,
                title: title.trimmingCharacters(in: .whitespaces),
                ingredients: ingredients,
                methodMarkdown: methodMarkdown,
                tags: tags,
                createdAt: existing.createdAt,
                updatedAt: Date()
            )
        }

        onSave(recipe)
        dismiss()
    }
}

// MARK: - Ingredient Editor Row

private struct IngredientEditorRow: View {
    @Binding var ingredient: ChecklistItem
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.text)
                    .font(.body)

                HStack(spacing: 8) {
                    if let quantity = ingredient.quantity {
                        Text(formatQuantity(quantity))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if let unit = ingredient.unit {
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
            .accessibilityLabel("Remove ingredient")
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

// MARK: - Add Ingredient Sheet

private struct AddIngredientSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onAdd: (ChecklistItem) -> Void

    @State private var text: String = ""
    @State private var quantity: String = ""
    @State private var unit: String = ""
    @State private var note: String = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case text, quantity, unit, note
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ingredient Details") {
                    TextField("Name", text: $text)
                        .focused($focusedField, equals: .text)
                        .accessibilityLabel("Ingredient name")

                    HStack {
                        TextField("Quantity", text: $quantity)
                            .focused($focusedField, equals: .quantity)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("Quantity")

                        TextField("Unit", text: $unit)
                            .focused($focusedField, equals: .unit)
                            .accessibilityLabel("Unit")
                    }

                    TextField("Note (optional)", text: $note)
                        .focused($focusedField, equals: .note)
                        .accessibilityLabel("Note")
                }
            }
            .navigationTitle("Add Ingredient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addIngredient()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                focusedField = .text
            }
        }
    }

    private func addIngredient() {
        let trimmedText = text.trimmingCharacters(in: .whitespaces)
        guard !trimmedText.isEmpty else { return }

        let parsedQuantity = Double(quantity.trimmingCharacters(in: .whitespaces))
        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)
        let trimmedNote = note.trimmingCharacters(in: .whitespaces)

        let ingredient = ChecklistItem(
            text: trimmedText,
            isDone: false,
            quantity: parsedQuantity,
            unit: trimmedUnit.isEmpty ? nil : trimmedUnit,
            note: trimmedNote.isEmpty ? nil : trimmedNote
        )

        onAdd(ingredient)
        dismiss()
    }
}

// MARK: - Tag Pill

private struct TagPill: View {
    let tag: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.subheadline)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
            .accessibilityLabel("Remove \(tag) tag")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.accentColor.opacity(0.2))
        .foregroundStyle(.primary)
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0

        let proposalWidth = proposal.replacingUnspecifiedDimensions().width

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > proposalWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            maxWidth = max(maxWidth, currentX - spacing)
        }

        return (
            size: CGSize(width: maxWidth, height: currentY + lineHeight),
            positions: positions
        )
    }
}

// MARK: - Previews

#Preview("Create Recipe") {
    RecipeEditorView(mode: .create(cardID: CardID())) { recipe in
        print("Created recipe: \(recipe.title)")
    }
}

#Preview("Edit Recipe") {
    let recipe = Recipe(cardID: CardID(), 
        title: "Spaghetti Carbonara",
        ingredients: [
            ChecklistItem(text: "Spaghetti", quantity: 400, unit: "g"),
            ChecklistItem(text: "Eggs", quantity: 4),
            ChecklistItem(text: "Parmesan", quantity: 100, unit: "g")
        ],
        methodMarkdown: "1. Boil pasta\n2. Fry bacon\n3. Mix eggs and cheese\n4. Combine",
        tags: ["Italian", "Pasta", "Quick"]
    )

    RecipeEditorView(mode: .edit(recipe)) { updatedRecipe in
        print("Updated recipe: \(updatedRecipe.title)")
    }
}
