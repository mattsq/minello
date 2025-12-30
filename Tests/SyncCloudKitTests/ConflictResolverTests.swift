// Tests/SyncCloudKitTests/ConflictResolverTests.swift
// Unit tests for conflict resolution

import Domain
import Foundation
import SyncInterfaces
import XCTest

final class ConflictResolverTests: XCTestCase {
    var resolver: LWWConflictResolver!

    override func setUp() {
        super.setUp()
        resolver = LWWConflictResolver()
    }

    // MARK: - Board Conflict Tests

    func testBoardConflictLastWriteWins_LocalNewer() {
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)

        let localBoard = Board(
            id: BoardID(),
            title: "Local Board",
            createdAt: earlier,
            updatedAt: now
        )

        let remoteBoard = Board(
            id: localBoard.id,
            title: "Remote Board",
            createdAt: earlier,
            updatedAt: earlier
        )

        let conflict = SyncConflict.board(local: localBoard, remote: remoteBoard)
        let resolved = resolver.resolve(conflict, strategy: .lastWriteWins) as! Board

        XCTAssertEqual(resolved.title, "Local Board", "Should choose local board as it's newer")
        XCTAssertEqual(resolved.updatedAt, now)
    }

    func testBoardConflictLastWriteWins_RemoteNewer() {
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)

        let localBoard = Board(
            id: BoardID(),
            title: "Local Board",
            createdAt: earlier,
            updatedAt: earlier
        )

        let remoteBoard = Board(
            id: localBoard.id,
            title: "Remote Board",
            createdAt: earlier,
            updatedAt: now
        )

        let conflict = SyncConflict.board(local: localBoard, remote: remoteBoard)
        let resolved = resolver.resolve(conflict, strategy: .lastWriteWins) as! Board

        XCTAssertEqual(resolved.title, "Remote Board", "Should choose remote board as it's newer")
        XCTAssertEqual(resolved.updatedAt, now)
    }

    func testBoardConflictPreferLocal() {
        let localBoard = Board(id: BoardID(), title: "Local Board")
        let remoteBoard = Board(id: localBoard.id, title: "Remote Board")

        let conflict = SyncConflict.board(local: localBoard, remote: remoteBoard)
        let resolved = resolver.resolve(conflict, strategy: .preferLocal) as! Board

        XCTAssertEqual(resolved.title, "Local Board")
    }

    func testBoardConflictPreferRemote() {
        let localBoard = Board(id: BoardID(), title: "Local Board")
        let remoteBoard = Board(id: localBoard.id, title: "Remote Board")

        let conflict = SyncConflict.board(local: localBoard, remote: remoteBoard)
        let resolved = resolver.resolve(conflict, strategy: .preferRemote) as! Board

        XCTAssertEqual(resolved.title, "Remote Board")
    }

    // MARK: - Card Conflict Tests

    func testCardConflictLastWriteWins() {
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)
        let columnID = ColumnID()

        let localCard = Card(
            id: CardID(),
            column: columnID,
            title: "Local Card",
            updatedAt: now
        )

        let remoteCard = Card(
            id: localCard.id,
            column: columnID,
            title: "Remote Card",
            updatedAt: earlier
        )

        let conflict = SyncConflict.card(local: localCard, remote: remoteCard)
        let resolved = resolver.resolve(conflict, strategy: .lastWriteWins) as! Card

        XCTAssertEqual(resolved.title, "Local Card", "Should choose local card as it's newer")
    }

    // MARK: - List Conflict Tests

    func testListConflictLastWriteWins() {
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)

        let localList = PersonalList(
            id: ListID(),
            cardID: CardID(),
            title: "Local List",
            items: [ChecklistItem(text: "Local item")],
            updatedAt: earlier
        )

        let remoteList = PersonalList(
            id: localList.id,
            cardID: localList.cardID,
            title: "Remote List",
            items: [ChecklistItem(text: "Remote item")],
            updatedAt: now
        )

        let conflict = SyncConflict.list(local: localList, remote: remoteList)
        let resolved = resolver.resolve(conflict, strategy: .lastWriteWins) as! PersonalList

        XCTAssertEqual(resolved.title, "Remote List", "Should choose remote list as it's newer")
        XCTAssertEqual(resolved.items.first?.text, "Remote item")
    }

    // MARK: - Recipe Conflict Tests

    func testRecipeConflictLastWriteWins() {
        let now = Date()
        let earlier = now.addingTimeInterval(-3600)

        let localRecipe = Recipe(
            id: RecipeID(),
            cardID: CardID(),
            title: "Local Recipe",
            methodMarkdown: "Local method",
            updatedAt: now
        )

        let remoteRecipe = Recipe(
            id: localRecipe.id,
            cardID: localRecipe.cardID,
            title: "Remote Recipe",
            methodMarkdown: "Remote method",
            updatedAt: earlier
        )

        let conflict = SyncConflict.recipe(local: localRecipe, remote: remoteRecipe)
        let resolved = resolver.resolve(conflict, strategy: .lastWriteWins) as! Recipe

        XCTAssertEqual(resolved.title, "Local Recipe", "Should choose local recipe as it's newer")
        XCTAssertEqual(resolved.methodMarkdown, "Local method")
    }

    // MARK: - Edge Cases

    func testConflictWithIdenticalTimestamps() {
        let now = Date()
        let localBoard = Board(id: BoardID(), title: "Local", updatedAt: now)
        let remoteBoard = Board(id: localBoard.id, title: "Remote", updatedAt: now)

        let conflict = SyncConflict.board(local: localBoard, remote: remoteBoard)
        let resolved = resolver.resolve(conflict, strategy: .lastWriteWins) as! Board

        // With identical timestamps, LWW should still return a consistent result
        // (In this implementation, it will return remote when timestamps are equal)
        XCTAssertNotNil(resolved)
        XCTAssertTrue(resolved.title == "Local" || resolved.title == "Remote")
    }
}
