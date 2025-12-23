import SwiftData
import SwiftUI

struct ChecklistItemEditor: View {
    @Bindable var item: ChecklistItem
    var onSave: (ChecklistItem) -> Void
    var onCancel: () -> Void

    @State private var text: String
    @State private var isDone: Bool
    @State private var quantityText: String
    @State private var unit: String
    @State private var note: String

    @FocusState private var focusedField: Field?

    enum Field {
        case text
        case quantity
        case unit
        case note
    }

    init(
        item: ChecklistItem,
        onSave: @escaping (ChecklistItem) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.item = item
        self.onSave = onSave
        self.onCancel = onCancel

        _text = State(initialValue: item.text)
        _isDone = State(initialValue: item.isDone)
        _quantityText = State(
            initialValue: item.quantity.map { String(format: "%.1f", $0) } ?? ""
        )
        _unit = State(initialValue: item.unit ?? "")
        _note = State(initialValue: item.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Button(action: { isDone.toggle() }) {
                            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(isDone ? .green : .gray)
                                .imageScale(.large)
                        }
                        .buttonStyle(.plain)

                        TextField("Item text", text: $text)
                            .focused($focusedField, equals: .text)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .quantity
                            }
                    }
                }

                Section("Quantity & Unit") {
                    HStack {
                        TextField("Quantity", text: $quantityText)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .quantity)
                            .frame(maxWidth: 100)

                        TextField("Unit (e.g., kg, liters)", text: $unit)
                            .focused($focusedField, equals: .unit)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .note
                            }
                    }
                }

                Section("Note") {
                    TextField("Additional notes", text: $note, axis: .vertical)
                        .focused($focusedField, equals: .note)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
            .onAppear {
                focusedField = .text
            }
        }
    }

    private func save() {
        item.text = text.trimmingCharacters(in: .whitespaces)
        item.isDone = isDone

        if let quantity = Double(quantityText.trimmingCharacters(in: .whitespaces)) {
            item.quantity = quantity
        } else {
            item.quantity = nil
        }

        let trimmedUnit = unit.trimmingCharacters(in: .whitespaces)
        item.unit = trimmedUnit.isEmpty ? nil : trimmedUnit

        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
        item.note = trimmedNote.isEmpty ? nil : trimmedNote

        onSave(item)
    }
}
