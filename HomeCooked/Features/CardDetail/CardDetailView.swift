import SwiftData
import SwiftUI

struct CardDetailView: View {
    @Bindable var card: Card
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Details") {
                    TextField("Title", text: $card.title)
                        .font(.headline)

                    TextField("Description", text: $card.details, axis: .vertical)
                        .lineLimit(3...10)

                    if let due = card.due {
                        LabeledContent("Due") {
                            Text(due, style: .date)
                        }
                    }

                    if !card.tags.isEmpty {
                        LabeledContent("Tags") {
                            Text(card.tags.joined(separator: ", "))
                        }
                    }
                }

                Section("Checklist") {
                    ChecklistView(
                        items: card.checklist,
                        onAdd: { item in
                            item.card = card
                            card.checklist.append(item)
                            modelContext.insert(item)
                            try? modelContext.save()
                        },
                        onDelete: { item in
                            if let index = card.checklist.firstIndex(where: { $0.id == item.id }) {
                                card.checklist.remove(at: index)
                                modelContext.delete(item)
                                try? modelContext.save()
                            }
                        },
                        onMove: { indices, newOffset in
                            card.checklist.move(fromOffsets: indices, toOffset: newOffset)
                            try? modelContext.save()
                        },
                        onUpdate: { _ in
                            try? modelContext.save()
                        }
                    )
                    .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        card.updatedAt = Date()
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
