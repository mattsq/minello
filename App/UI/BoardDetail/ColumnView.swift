// App/UI/BoardDetail/ColumnView.swift
// View for displaying a single column with its cards

import SwiftUI
import Domain

/// View displaying a column and its cards
struct ColumnView: View {
    @EnvironmentObject private var dependencies: AppDependencyContainer

    let column: Column
    let cards: [Card]
    let onRefresh: () async -> Void

    @State private var showingAddCard = false
    @State private var newCardTitle = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Column header
            columnHeader

            Divider()

            // Cards list
            if cards.isEmpty {
                emptyState
            } else {
                cardsList
            }

            Divider()

            // Add card button
            addCardButton
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }

    private var columnHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(column.title)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                Text("\(cards.count) card\(cards.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.title)
                .foregroundStyle(.secondary)
            Text("No cards")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .accessibilityLabel("No cards in this column")
    }

    private var cardsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(cards, id: \.id) { card in
                    NavigationLink(value: card) {
                        CardRowView(card: card)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Card: \(card.title)")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .navigationDestination(for: Card.self) { card in
            CardDetailView(card: card)
        }
    }

    private var addCardButton: some View {
        Button {
            showingAddCard = true
        } label: {
            Label("Add Card", systemImage: "plus.circle.fill")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .accessibilityLabel("Add card to \(column.title)")
        .alert("New Card", isPresented: $showingAddCard) {
            TextField("Card Title", text: $newCardTitle)
                .accessibilityLabel("Card title")
            Button("Cancel", role: .cancel) {
                newCardTitle = ""
            }
            Button("Create") {
                Task { await createCard() }
            }
            .disabled(newCardTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        } message: {
            Text("Enter a title for your new card")
        }
    }

    // MARK: - Actions

    private func createCard() async {
        let title = newCardTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }

        // Calculate next sort key
        let nextSortKey = cards.map(\.sortKey).max().map { $0 + 1 } ?? 0

        let card = Card(
            column: column.id,
            title: title,
            sortKey: nextSortKey
        )
        newCardTitle = ""

        do {
            try await dependencies.repositoryProvider.boardsRepository.createCard(card)
            await onRefresh()
        } catch {
            errorMessage = "Failed to create card: \(error.localizedDescription)"
        }
    }
}

// MARK: - Card Row View

private struct CardRowView: View {
    let card: Card

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(card.title)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)

            HStack(spacing: 12) {
                if !card.tags.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption2)
                        Text(card.tags.first!)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.secondary)
                }

                if !card.checklist.isEmpty {
                    let doneCount = card.checklist.filter(\.isDone).count
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                        Text("\(doneCount)/\(card.checklist.count)")
                            .font(.caption)
                    }
                    .foregroundStyle(doneCount == card.checklist.count ? .green : .secondary)
                }

                if let due = card.due {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(due, style: .date)
                            .font(.caption)
                    }
                    .foregroundStyle(due < Date() ? .red : .secondary)
                }

                Spacer()
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

// MARK: - Previews

#Preview {
    let column = Column(
        board: BoardID(),
        title: "To Do",
        index: 0
    )

    let cards = [
        Card(column: column.id, title: "Fix leaky faucet", tags: ["urgent"], sortKey: 0),
        Card(
            column: column.id,
            title: "Paint bedroom",
            checklist: [
                ChecklistItem(text: "Buy paint", isDone: true),
                ChecklistItem(text: "Prepare walls", isDone: false)
            ],
            sortKey: 1
        ),
        Card(column: column.id, title: "Install shelves", due: Date().addingTimeInterval(-86400), sortKey: 2)
    ]

    let container = try! AppDependencyContainer.preview()

    return NavigationStack {
        ColumnView(column: column, cards: cards, onRefresh: {})
            .frame(width: 300)
            .padding()
            .withDependencies(container)
    }
}

#Preview("Empty Column") {
    let column = Column(
        board: BoardID(),
        title: "Done",
        index: 2
    )

    let container = try! AppDependencyContainer.preview()

    return NavigationStack {
        ColumnView(column: column, cards: [], onRefresh: {})
            .frame(width: 300)
            .padding()
            .withDependencies(container)
    }
}
