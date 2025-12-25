// App/UI/CardDetail/CardDetailView.swift
// Detailed view for a single card with checklist

import SwiftUI
import Domain

/// Detail view for a card showing all its information and checklist
struct CardDetailView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer
    @Environment(\.dismiss) private var dismiss

    let card: Card

    @State private var editedCard: Card
    @State private var isEditing = false
    @State private var errorMessage: String?
    @State private var showingAddItem = false
    @State private var newItemText = ""

    init(card: Card) {
        self.card = card
        self._editedCard = State(initialValue: card)
    }

    var body: some View {
        Form {
            // Title section
            Section {
                if isEditing {
                    TextField("Title", text: $editedCard.title, axis: .vertical)
                        .font(.title2)
                        .accessibilityLabel("Card title")
                } else {
                    Text(editedCard.title)
                        .font(.title2)
                        .accessibilityAddTraits(.isHeader)
                }
            }

            // Details section
            Section("Details") {
                if isEditing {
                    TextField("Details", text: $editedCard.details, axis: .vertical)
                        .lineLimit(5...10)
                        .accessibilityLabel("Card details")
                } else if !editedCard.details.isEmpty {
                    Text(editedCard.details)
                } else {
                    Text("No details")
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            // Due date section
            Section("Due Date") {
                if isEditing {
                    DatePicker(
                        "Due Date",
                        selection: Binding(
                            get: { editedCard.due ?? Date() },
                            set: { editedCard.due = $0 }
                        ),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .accessibilityLabel("Due date")

                    if editedCard.due != nil {
                        Button("Clear Due Date", role: .destructive) {
                            editedCard.due = nil
                        }
                    }
                } else if let due = editedCard.due {
                    HStack {
                        Text(due, style: .date)
                        Text("at")
                            .foregroundStyle(.secondary)
                        Text(due, style: .time)
                    }
                    .foregroundStyle(due < Date() ? .red : .primary)
                } else {
                    Text("No due date")
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            // Tags section
            Section("Tags") {
                if isEditing {
                    TagEditorView(tags: $editedCard.tags)
                } else if !editedCard.tags.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(editedCard.tags, id: \.self) { tag in
                            TagPill(tag: tag)
                        }
                    }
                } else {
                    Text("No tags")
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            // Checklist section
            Section {
                checklistHeader
                checklistItems
            } header: {
                Text("Checklist")
            }

            // Metadata
            Section("Information") {
                LabeledContent("Created", value: editedCard.createdAt, format: .dateTime)
                LabeledContent("Updated", value: editedCard.updatedAt, format: .dateTime)
            }
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if isEditing {
                    Button("Done") {
                        Task { await saveCard() }
                    }
                    .accessibilityLabel("Save changes")
                } else {
                    Button("Edit") {
                        isEditing = true
                    }
                    .accessibilityLabel("Edit card")
                }
            }

            ToolbarItem(placement: .cancellationAction) {
                if isEditing {
                    Button("Cancel") {
                        editedCard = card
                        isEditing = false
                    }
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }

    private var checklistHeader: some View {
        HStack {
            let total = editedCard.checklist.count
            let done = editedCard.checklist.filter(\.isDone).count

            if total > 0 {
                ProgressView(value: Double(done), total: Double(total))
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("\(done) of \(total) items completed")

                Text("\(done)/\(total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button {
                showingAddItem = true
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .accessibilityLabel("Add checklist item")
            .alert("New Item", isPresented: $showingAddItem) {
                TextField("Item text", text: $newItemText)
                    .accessibilityLabel("Item text")
                Button("Cancel", role: .cancel) {
                    newItemText = ""
                }
                Button("Add") {
                    addChecklistItem()
                }
                .disabled(newItemText.trimmingCharacters(in: .whitespaces).isEmpty)
            } message: {
                Text("Enter text for the new checklist item")
            }
        }
    }

    private var checklistItems: some View {
        ForEach(editedCard.checklist.indices, id: \.self) { index in
            ChecklistItemRow(
                item: $editedCard.checklist[index],
                onDelete: {
                    editedCard.checklist.remove(at: index)
                    if !isEditing {
                        Task { await saveCard() }
                    }
                },
                onToggle: {
                    if !isEditing {
                        Task { await saveCard() }
                    }
                }
            )
        }
    }

    // MARK: - Actions

    private func saveCard() async {
        var updatedCard = editedCard
        updatedCard.updatedAt = Date()

        do {
            try await dependencies.repositoryProvider.boardsRepository.updateCard(updatedCard)
            editedCard = updatedCard
            isEditing = false
        } catch {
            errorMessage = "Failed to save card: \(error.localizedDescription)"
        }
    }

    private func addChecklistItem() {
        let text = newItemText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        let item = ChecklistItem(text: text)
        editedCard.checklist.append(item)
        newItemText = ""

        if !isEditing {
            Task { await saveCard() }
        }
    }
}

// MARK: - Checklist Item Row

private struct ChecklistItemRow: View {
    @Binding var item: ChecklistItem
    let onDelete: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                item.isDone.toggle()
                onToggle()
            } label: {
                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(item.isDone ? .green : .secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(item.isDone ? "Mark as incomplete" : "Mark as complete")

            VStack(alignment: .leading, spacing: 2) {
                Text(item.text)
                    .strikethrough(item.isDone)
                    .foregroundStyle(item.isDone ? .secondary : .primary)

                if let quantity = item.quantity, let unit = item.unit {
                    Text("\(quantity, specifier: "%.1f") \(unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let note = item.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                }
            }

            Spacer()

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .foregroundStyle(.red)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel("Delete item")
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tag Editor

private struct TagEditorView: View {
    @Binding var tags: [String]
    @State private var newTag = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    HStack(spacing: 4) {
                        Text(tag)
                            .font(.caption)
                        Button {
                            tags.removeAll { $0 == tag }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption2)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel("Remove \(tag)")
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                }
            }

            HStack {
                TextField("Add tag", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        addTag()
                    }

                Button {
                    addTag()
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(newTag.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    private func addTag() {
        let tag = newTag.trimmingCharacters(in: .whitespaces).lowercased()
        guard !tag.isEmpty, !tags.contains(tag) else { return }
        tags.append(tag)
        newTag = ""
    }
}

// MARK: - Tag Pill

private struct TagPill: View {
    let tag: String

    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(12)
    }
}

// MARK: - Flow Layout

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowLayoutResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowLayoutResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowLayoutResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Previews

#Preview {
    let card = Card(
        column: ColumnID(),
        title: "Fix leaky faucet",
        details: "The bathroom sink is leaking. Need to replace the washer.",
        due: Date().addingTimeInterval(86400),
        tags: ["urgent", "home"],
        checklist: [
            ChecklistItem(text: "Buy washer", isDone: true),
            ChecklistItem(text: "Turn off water", isDone: false),
            ChecklistItem(text: "Replace washer", isDone: false)
        ],
        sortKey: 0
    )

    let container = try! AppDependencyContainer.preview()

    return NavigationStack {
        CardDetailView(card: card)
            .withDependencies(container)
    }
}
