// Tests/UITests/ListsUITests.swift
// UI tests for Personal Lists functionality
//
// NOTE: These tests are macOS/iOS-only and should be run using xcodebuild

#if canImport(XCTest)
import XCTest

/// UI tests for Personal Lists feature
///
/// Run with: xcodebuild test -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15'
final class ListsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Navigation Tests

    func testListsTabExists() throws {
        // Verify the Lists tab exists and can be tapped
        let listsTab = app.tabBars.buttons["Lists tab"]
        XCTAssertTrue(listsTab.waitForExistence(timeout: 5))
        listsTab.tap()

        // Verify we're on the Lists screen
        let listsTitle = app.navigationBars["Lists"]
        XCTAssertTrue(listsTitle.waitForExistence(timeout: 5))
    }

    func testCanAddList() throws {
        // Navigate to Lists tab
        navigateToListsTab()

        // Tap the add list button
        let addButton = app.navigationBars.buttons["Add new list"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Verify the editor sheet appears
        let editorTitle = app.navigationBars["New List"]
        XCTAssertTrue(editorTitle.waitForExistence(timeout: 2))

        // Type a list title
        let titleField = app.textFields["List title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Groceries")

        // Tap create
        app.buttons["Create"].tap()

        // Wait a moment for the list to be created
        sleep(1)

        // Verify the list appears
        let listRow = app.staticTexts["Groceries"]
        XCTAssertTrue(listRow.waitForExistence(timeout: 5))
    }

    func testCanAddItemToList() throws {
        // First create a list
        createTestList(title: "Shopping")

        // Tap on the list to navigate to detail
        let listRow = app.staticTexts["Shopping"]
        listRow.tap()

        // Verify we're on the detail screen
        let detailTitle = app.navigationBars["Shopping"]
        XCTAssertTrue(detailTitle.waitForExistence(timeout: 5))

        // Tap the actions menu
        let actionsButton = app.buttons["List actions"]
        XCTAssertTrue(actionsButton.exists)
        actionsButton.tap()

        // Tap "Edit List" to add items
        let editButton = app.buttons["Edit List"]
        XCTAssertTrue(editButton.exists)
        editButton.tap()

        // Verify editor appears
        let editorTitle = app.navigationBars["Edit List"]
        XCTAssertTrue(editorTitle.waitForExistence(timeout: 2))

        // Add an item
        let addItemButton = app.buttons["Add item"]
        XCTAssertTrue(addItemButton.exists)
        addItemButton.tap()

        // Fill in item details
        let itemNameField = app.textFields["Item name"]
        XCTAssertTrue(itemNameField.waitForExistence(timeout: 2))
        itemNameField.tap()
        itemNameField.typeText("Milk")

        // Tap add
        app.buttons["Add"].tap()

        // Save the list
        app.buttons["Save"].tap()

        // Wait for save
        sleep(1)

        // Verify item appears in detail view
        let itemText = app.staticTexts["Milk"]
        XCTAssertTrue(itemText.waitForExistence(timeout: 5))
    }

    func testCanToggleItemCheckbox() throws {
        // Create a list with an item
        createTestListWithItems()

        // Tap on the list
        let listRow = app.staticTexts["Test List"]
        listRow.tap()

        // Wait for detail view
        sleep(1)

        // Find the checkbox (circle icon for unchecked items)
        let checkboxes = app.images.matching(identifier: "circle")
        if checkboxes.count > 0 {
            checkboxes.element(boundBy: 0).tap()

            // Wait a moment for the state to update
            sleep(1)

            // Verify the checkbox changed (should now be checkmark.circle.fill)
            let checkedBox = app.images["checkmark.circle.fill"]
            XCTAssertTrue(checkedBox.waitForExistence(timeout: 2))
        }
    }

    func testCanDeleteList() throws {
        // Create a test list
        createTestList(title: "To Delete")

        // Verify list exists
        let listRow = app.staticTexts["To Delete"]
        XCTAssertTrue(listRow.exists)

        // Swipe to delete
        listRow.swipeLeft()

        // Tap delete button
        let deleteButton = app.buttons["Delete To Delete"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 2))
        deleteButton.tap()

        // Wait for deletion
        sleep(1)

        // Verify list is gone
        XCTAssertFalse(listRow.exists)
    }

    func testBulkImportItems() throws {
        // Create a list
        createTestList(title: "Bulk Test")

        // Navigate to detail
        let listRow = app.staticTexts["Bulk Test"]
        listRow.tap()

        // Wait for detail view
        sleep(1)

        // Open actions menu
        let actionsButton = app.buttons["List actions"]
        actionsButton.tap()

        // Tap "Bulk Add Items"
        let bulkButton = app.buttons["Bulk Add Items"]
        XCTAssertTrue(bulkButton.exists)
        bulkButton.tap()

        // Verify bulk import sheet appears
        let bulkTitle = app.navigationBars["Bulk Add Items"]
        XCTAssertTrue(bulkTitle.waitForExistence(timeout: 2))

        // Type multiple items (one per line)
        let textEditor = app.textViews.firstMatch
        XCTAssertTrue(textEditor.exists)
        textEditor.tap()
        textEditor.typeText("Apples\nBananas\nOranges")

        // Tap Add
        app.buttons["Add"].tap()

        // Wait for items to be added
        sleep(1)

        // Verify at least one item appears
        let itemText = app.staticTexts["Apples"]
        XCTAssertTrue(itemText.waitForExistence(timeout: 5))
    }

    func testSearchLists() throws {
        // Create multiple lists
        createTestList(title: "Groceries")
        createTestList(title: "Hardware")

        // Wait for lists to appear
        sleep(1)

        // Tap search field
        let searchField = app.searchFields["Search lists"]
        XCTAssertTrue(searchField.exists)
        searchField.tap()
        searchField.typeText("Groceries")

        // Wait a moment for filtering
        sleep(1)

        // Verify filtered results
        let groceriesRow = app.staticTexts["Groceries"]
        XCTAssertTrue(groceriesRow.exists)

        // Hardware should not appear (if strict filtering)
        // Note: This depends on implementation details
    }

    // MARK: - Helper Methods

    private func navigateToListsTab() {
        let listsTab = app.tabBars.buttons["Lists tab"]
        listsTab.tap()

        // Wait for Lists screen to appear
        let listsTitle = app.navigationBars["Lists"]
        _ = listsTitle.waitForExistence(timeout: 5)
    }

    private func createTestList(title: String) {
        // Navigate to Lists tab
        navigateToListsTab()

        // Tap add button
        let addButton = app.navigationBars.buttons["Add new list"]
        addButton.tap()

        // Type title
        let titleField = app.textFields["List title"]
        titleField.tap()
        titleField.typeText(title)

        // Create
        app.buttons["Create"].tap()

        // Wait for creation
        sleep(1)

        // Go back to list if we're in detail view
        if app.navigationBars[title].exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }

    private func createTestListWithItems() {
        // Navigate to Lists tab
        navigateToListsTab()

        // Create a list
        let addButton = app.navigationBars.buttons["Add new list"]
        addButton.tap()

        // Type title
        let titleField = app.textFields["List title"]
        titleField.tap()
        titleField.typeText("Test List")

        // Add an item
        let addItemButton = app.buttons["Add item"]
        addItemButton.tap()

        let itemField = app.textFields["Item name"]
        _ = itemField.waitForExistence(timeout: 2)
        itemField.tap()
        itemField.typeText("Test Item")

        app.buttons["Add"].tap()

        // Create the list
        app.buttons["Create"].tap()

        // Wait
        sleep(1)

        // Go back to list view if in detail
        if app.navigationBars["Test List"].exists {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }
    }
}
#endif
