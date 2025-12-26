// Tests/DomainTests/HelpersTests.swift
// Tests for domain helper utilities

import XCTest
@testable import Domain

final class HelpersTests: XCTestCase {
    // MARK: - TagHelpers Tests

    func testTagSanitizeBasic() {
        let result = TagHelpers.sanitize("MyTag")
        XCTAssertEqual(result, "mytag")
    }

    func testTagSanitizeTrimsWhitespace() {
        let result = TagHelpers.sanitize("  MyTag  ")
        XCTAssertEqual(result, "mytag")
    }

    func testTagSanitizeRemovesSpaces() {
        let result = TagHelpers.sanitize("My Tag")
        XCTAssertEqual(result, "mytag")
    }

    func testTagSanitizeAllowsHyphens() {
        let result = TagHelpers.sanitize("my-tag")
        XCTAssertEqual(result, "my-tag")
    }

    func testTagSanitizeAllowsUnderscores() {
        let result = TagHelpers.sanitize("my_tag")
        XCTAssertEqual(result, "my_tag")
    }

    func testTagSanitizeRemovesSpecialChars() {
        let result = TagHelpers.sanitize("my@tag!")
        XCTAssertEqual(result, "mytag")
    }

    func testTagSanitizeReturnsNilForEmpty() {
        let result = TagHelpers.sanitize("")
        XCTAssertNil(result)
    }

    func testTagSanitizeReturnsNilForWhitespaceOnly() {
        let result = TagHelpers.sanitize("   ")
        XCTAssertNil(result)
    }

    func testTagSanitizeReturnsNilForSpecialCharsOnly() {
        let result = TagHelpers.sanitize("!@#$%")
        XCTAssertNil(result)
    }

    func testTagSanitizeArray() {
        let tags = ["MyTag", "  Another  ", "special!", "duplicate", "DUPLICATE"]
        let result = TagHelpers.sanitize(tags)

        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result.contains("mytag"))
        XCTAssertTrue(result.contains("another"))
        XCTAssertTrue(result.contains("special"))
        XCTAssertTrue(result.contains("duplicate"))
    }

    func testTagSanitizeArrayRemovesDuplicates() {
        let tags = ["tag", "TAG", "Tag"]
        let result = TagHelpers.sanitize(tags)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], "tag")
    }

    func testTagSanitizeArrayFiltersInvalid() {
        let tags = ["valid", "", "   ", "!@#"]
        let result = TagHelpers.sanitize(tags)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], "valid")
    }

    func testTagSanitizeArrayPreservesOrder() {
        let tags = ["zebra", "apple", "mango"]
        let result = TagHelpers.sanitize(tags)

        XCTAssertEqual(result, ["zebra", "apple", "mango"])
    }

    // MARK: - ChecklistHelpers Tests

    func testChecklistToggle() {
        let item = ChecklistItem(text: "Task", isDone: false)
        let toggled = ChecklistHelpers.toggle(item)

        XCTAssertTrue(toggled.isDone)
        XCTAssertEqual(toggled.text, item.text)
        XCTAssertEqual(toggled.id, item.id)
    }

    func testChecklistToggleTwice() {
        let item = ChecklistItem(text: "Task", isDone: false)
        let toggled = ChecklistHelpers.toggle(item)
        let toggledBack = ChecklistHelpers.toggle(toggled)

        XCTAssertFalse(toggledBack.isDone)
    }

    func testChecklistToggleAll() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: false),
            ChecklistItem(text: "Task 2", isDone: true),
            ChecklistItem(text: "Task 3", isDone: false),
        ]

        let result = ChecklistHelpers.toggleAll(items, isDone: true)

        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result.allSatisfy { $0.isDone })
    }

    func testChecklistMarkAllDone() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: false),
            ChecklistItem(text: "Task 2", isDone: false),
        ]

        let result = ChecklistHelpers.markAllDone(items)

        XCTAssertTrue(result.allSatisfy { $0.isDone })
    }

    func testChecklistMarkAllUndone() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: true),
            ChecklistItem(text: "Task 2", isDone: true),
        ]

        let result = ChecklistHelpers.markAllUndone(items)

        XCTAssertTrue(result.allSatisfy { !$0.isDone })
    }

    func testChecklistCountCompleted() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: true),
            ChecklistItem(text: "Task 2", isDone: false),
            ChecklistItem(text: "Task 3", isDone: true),
        ]

        let count = ChecklistHelpers.countCompleted(items)

        XCTAssertEqual(count, 2)
    }

    func testChecklistCountCompletedEmpty() {
        let count = ChecklistHelpers.countCompleted([])
        XCTAssertEqual(count, 0)
    }

    func testChecklistCompletionPercentage() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: true),
            ChecklistItem(text: "Task 2", isDone: false),
            ChecklistItem(text: "Task 3", isDone: true),
            ChecklistItem(text: "Task 4", isDone: true),
        ]

        let percentage = ChecklistHelpers.completionPercentage(items)

        XCTAssertEqual(percentage, 0.75, accuracy: 0.001)
    }

    func testChecklistCompletionPercentageEmpty() {
        let percentage = ChecklistHelpers.completionPercentage([])
        XCTAssertEqual(percentage, 0.0)
    }

    func testChecklistCompletionPercentageAllDone() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: true),
            ChecklistItem(text: "Task 2", isDone: true),
        ]

        let percentage = ChecklistHelpers.completionPercentage(items)

        XCTAssertEqual(percentage, 1.0)
    }

    func testChecklistFilterDone() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: true),
            ChecklistItem(text: "Task 2", isDone: false),
            ChecklistItem(text: "Task 3", isDone: true),
        ]

        let result = ChecklistHelpers.filter(items, isDone: true)

        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.isDone })
    }

    func testChecklistFilterUndone() {
        let items = [
            ChecklistItem(text: "Task 1", isDone: true),
            ChecklistItem(text: "Task 2", isDone: false),
            ChecklistItem(text: "Task 3", isDone: true),
        ]

        let result = ChecklistHelpers.filter(items, isDone: false)

        XCTAssertEqual(result.count, 1)
        XCTAssertFalse(result[0].isDone)
    }

    func testChecklistReorderBasic() {
        let items = [
            ChecklistItem(text: "Task 1"),
            ChecklistItem(text: "Task 2"),
            ChecklistItem(text: "Task 3"),
        ]

        let result = ChecklistHelpers.reorder(items, from: 0, to: 2)

        XCTAssertEqual(result[0].text, "Task 2")
        XCTAssertEqual(result[1].text, "Task 3")
        XCTAssertEqual(result[2].text, "Task 1")
    }

    func testChecklistReorderBackward() {
        let items = [
            ChecklistItem(text: "Task 1"),
            ChecklistItem(text: "Task 2"),
            ChecklistItem(text: "Task 3"),
        ]

        let result = ChecklistHelpers.reorder(items, from: 2, to: 0)

        XCTAssertEqual(result[0].text, "Task 3")
        XCTAssertEqual(result[1].text, "Task 1")
        XCTAssertEqual(result[2].text, "Task 2")
    }

    func testChecklistReorderSameIndex() {
        let items = [
            ChecklistItem(text: "Task 1"),
            ChecklistItem(text: "Task 2"),
        ]

        let result = ChecklistHelpers.reorder(items, from: 1, to: 1)

        XCTAssertEqual(result, items)
    }

    func testChecklistReorderInvalidFromIndex() {
        let items = [ChecklistItem(text: "Task 1")]
        let result = ChecklistHelpers.reorder(items, from: 5, to: 0)

        XCTAssertEqual(result, items)
    }

    func testChecklistReorderInvalidToIndex() {
        let items = [ChecklistItem(text: "Task 1")]
        let result = ChecklistHelpers.reorder(items, from: 0, to: 5)

        XCTAssertEqual(result, items)
    }

    func testChecklistReorderNegativeIndex() {
        let items = [ChecklistItem(text: "Task 1")]
        let result = ChecklistHelpers.reorder(items, from: -1, to: 0)

        XCTAssertEqual(result, items)
    }

    // MARK: - IDFactory Tests

    func testNewBoardID() {
        let id = IDFactory.newBoardID()
        XCTAssertNotNil(id.rawValue)
    }

    func testBoardIDFromUUID() {
        let uuid = UUID()
        let id = IDFactory.boardID(from: uuid)
        XCTAssertEqual(id.rawValue, uuid)
    }

    func testNewColumnID() {
        let id = IDFactory.newColumnID()
        XCTAssertNotNil(id.rawValue)
    }

    func testColumnIDFromUUID() {
        let uuid = UUID()
        let id = IDFactory.columnID(from: uuid)
        XCTAssertEqual(id.rawValue, uuid)
    }

    func testNewCardID() {
        let id = IDFactory.newCardID()
        XCTAssertNotNil(id.rawValue)
    }

    func testCardIDFromUUID() {
        let uuid = UUID()
        let id = IDFactory.cardID(from: uuid)
        XCTAssertEqual(id.rawValue, uuid)
    }

    func testNewListID() {
        let id = IDFactory.newListID()
        XCTAssertNotNil(id.rawValue)
    }

    func testListIDFromUUID() {
        let uuid = UUID()
        let id = IDFactory.listID(from: uuid)
        XCTAssertEqual(id.rawValue, uuid)
    }

    func testNewRecipeID() {
        let id = IDFactory.newRecipeID()
        XCTAssertNotNil(id.rawValue)
    }

    func testRecipeIDFromUUID() {
        let uuid = UUID()
        let id = IDFactory.recipeID(from: uuid)
        XCTAssertEqual(id.rawValue, uuid)
    }

    func testIDFactoryCreatesUniqueIDs() {
        let id1 = IDFactory.newBoardID()
        let id2 = IDFactory.newBoardID()
        XCTAssertNotEqual(id1, id2)
    }
}
