// App/Intents/IntentsProvider.swift
// App Intents provider for Shortcuts integration

import AppIntents

/// App Shortcuts provider that registers all available intents
@available(iOS 16.0, macOS 13.0, *)
struct HomeCookedShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddListItemIntent(),
            phrases: [
                "Add \(.applicationName) item to list",
                "Add item to \(.applicationName) list",
                "Add to my list in \(.applicationName)",
                "Add \(\.$itemName) to \(\.$listName)"
            ],
            shortTitle: "Add to List",
            systemImageName: "checklist"
        )

        AppShortcut(
            intent: AddCardIntent(),
            phrases: [
                "Add \(.applicationName) card",
                "Create card in \(.applicationName)",
                "Add task to \(.applicationName) board",
                "Add \(\.$cardTitle) to \(\.$boardName)"
            ],
            shortTitle: "Add Card",
            systemImageName: "rectangle.on.rectangle"
        )
    }
}
