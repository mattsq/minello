// App/Intents/AddListItemIntent.swift
// App Intent for adding items to personal lists

import AppIntents
import Domain
import PersistenceInterfaces
import UseCases

/// App Intent for adding an item to a personal list
/// Example: "Add milk to Groceries"
@available(iOS 17.0, macOS 14.0, *)
struct AddListItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Item to List"
    static let description = IntentDescription("Add an item to a personal list like Groceries or Packing")

    @Parameter(title: "Item Name")
    var itemName: String

    @Parameter(title: "List Name")
    var listName: String

    @Parameter(title: "Quantity", default: nil)
    var quantity: Double?

    @Parameter(title: "Unit", default: nil)
    var unit: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$itemName) to \(\.$listName)") {
            \.$quantity
            \.$unit
        }
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Get repository provider from the app
        guard let provider = await getRepositoryProvider() else {
            throw IntentError.repositoryNotAvailable
        }

        let listsRepo = provider.listsRepository

        // Load all lists
        let allLists = try await listsRepo.loadLists()

        // Find the best matching list using fuzzy lookup
        guard let targetList = EntityLookup.findBestList(
            query: listName,
            in: allLists,
            threshold: 0.5
        ) else {
            throw IntentError.listNotFound(listName)
        }

        // Create the new checklist item
        let newItem = ChecklistItem(
            text: itemName,
            isDone: false,
            quantity: quantity,
            unit: unit
        )

        // Update the list with the new item
        var updatedList = targetList
        updatedList.items.append(newItem)
        updatedList.updatedAt = Date()

        try await listsRepo.updateList(updatedList)

        // Return success message
        let quantityText = quantity.map { q in
            let unitText = unit.map { " \($0)" } ?? ""
            return "\(q)\(unitText) "
        } ?? ""

        return .result(
            dialog: "Added \(quantityText)\(itemName) to \(targetList.title)"
        )
    }

    @MainActor
    private func getRepositoryProvider() async -> RepositoryProvider? {
        // Access the repository provider from the app's dependency container
        // This assumes AppDependencyContainer is set up as a singleton or accessible
        return AppDependencyContainer.shared.repositoryProvider
    }
}

/// Errors that can occur during intent execution
enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case repositoryNotAvailable
    case listNotFound(String)
    case boardNotFound(String)
    case columnNotFound(String, String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .repositoryNotAvailable:
            return "Repository is not available"
        case .listNotFound(let name):
            return "Could not find a list matching '\(name)'"
        case .boardNotFound(let name):
            return "Could not find a board matching '\(name)'"
        case .columnNotFound(let columnName, let boardName):
            return "Could not find column '\(columnName)' in board '\(boardName)'"
        }
    }
}
