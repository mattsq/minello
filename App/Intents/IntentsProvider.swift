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
                "Add item to card in \(.applicationName)",
                "Add to card list in \(.applicationName)"
            ],
            shortTitle: "Add to Card List",
            systemImageName: "checklist"
        )
        AppShortcut(
            intent: AddCardIntent(),
            phrases: [
                "Add \(.applicationName) card",
                "Create card in \(.applicationName)",
                "Add task to \(.applicationName) board"
            ],
            shortTitle: "Add Card",
            systemImageName: "rectangle.on.rectangle"
        )
        AppShortcut(
            intent: AddRecipeIntent(),
            phrases: [
                "Add recipe to \(.applicationName) card",
                "Create recipe in \(.applicationName)",
                "Add \(.applicationName) recipe to card"
            ],
            shortTitle: "Add Recipe",
            systemImageName: "book.closed"
        )
    }
}
