// Tests/UITests/HomeCookedUITests.swift
// Smoke UI tests for the HomeCooked app
//
// NOTE: These tests are macOS/iOS-only and should be run using xcodebuild

#if canImport(XCTest)
import XCTest

/// Smoke UI tests verifying basic app functionality
///
/// Run with: xcodebuild test -scheme HomeCooked -destination 'platform=iOS Simulator,name=iPhone 15'
final class HomeCookedUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Smoke Tests

    func testAppLaunches() throws {
        // Verify the app launches without crashing
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testBoardsListAppears() throws {
        // Verify the boards list navigation title appears
        let boardsTitle = app.navigationBars["Boards"]
        XCTAssertTrue(boardsTitle.waitForExistence(timeout: 5))
    }

    func testCanAddBoard() throws {
        // Find and tap the add board button
        let addButton = app.navigationBars.buttons["Add new board"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        // Verify the alert appears
        let alert = app.alerts["New Board"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Type a board title
        let titleField = alert.textFields["Board title"]
        XCTAssertTrue(titleField.exists)
        titleField.tap()
        titleField.typeText("Test Board")

        // Tap create
        alert.buttons["Create"].tap()

        // Wait a moment for the board to be created
        sleep(1)

        // Verify the board appears in the list
        let boardRow = app.staticTexts["Test Board"]
        XCTAssertTrue(boardRow.waitForExistence(timeout: 5))
    }

    func testCanNavigateToBoard() throws {
        // First create a board
        testCanAddBoard()

        // Tap on the board to navigate
        let boardRow = app.staticTexts["Test Board"]
        boardRow.tap()

        // Verify we navigated to the board detail
        let boardDetailTitle = app.navigationBars["Test Board"]
        XCTAssertTrue(boardDetailTitle.waitForExistence(timeout: 5))
    }

    func testCanAddColumn() throws {
        // Navigate to a board
        testCanNavigateToBoard()

        // Tap the add column button
        let addButton = app.navigationBars.buttons["Add new column"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()

        // Verify the alert appears
        let alert = app.alerts["New Column"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Type a column title
        let titleField = alert.textFields["Column title"]
        titleField.tap()
        titleField.typeText("To Do")

        // Tap create
        alert.buttons["Create"].tap()

        // Wait for the column to appear
        sleep(1)

        // Verify the column appears
        let columnHeader = app.staticTexts["To Do"]
        XCTAssertTrue(columnHeader.waitForExistence(timeout: 5))
    }

    func testCanAddCard() throws {
        // Navigate to a board with a column
        testCanAddColumn()

        // Find and tap the add card button in the column
        let addCardButton = app.buttons["Add card to To Do"]
        XCTAssertTrue(addCardButton.exists)
        addCardButton.tap()

        // Verify the alert appears
        let alert = app.alerts["New Card"]
        XCTAssertTrue(alert.waitForExistence(timeout: 2))

        // Type a card title
        let titleField = alert.textFields["Card title"]
        titleField.tap()
        titleField.typeText("Test Task")

        // Tap create
        alert.buttons["Create"].tap()

        // Wait for the card to appear
        sleep(1)

        // Verify the card appears
        let cardRow = app.staticTexts["Test Task"]
        XCTAssertTrue(cardRow.waitForExistence(timeout: 5))
    }

    func testCanViewCardDetail() throws {
        // Create a card first
        testCanAddCard()

        // Tap on the card
        let cardRow = app.staticTexts["Test Task"]
        cardRow.tap()

        // Verify we navigated to card detail
        let cardDetailTitle = app.navigationBars["Card Details"]
        XCTAssertTrue(cardDetailTitle.waitForExistence(timeout: 5))

        // Verify the checklist section exists
        let checklistHeader = app.staticTexts["Checklist"]
        XCTAssertTrue(checklistHeader.exists)
    }

    // MARK: - Accessibility Tests

    func testAccessibilityLabels() throws {
        // Verify key accessibility labels are present
        let addBoardButton = app.navigationBars.buttons["Add new board"]
        XCTAssertTrue(addBoardButton.waitForExistence(timeout: 5))
        XCTAssertNotNil(addBoardButton.label)
    }
}
#endif
