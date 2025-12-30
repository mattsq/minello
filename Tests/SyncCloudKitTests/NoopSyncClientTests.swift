// Tests/SyncCloudKitTests/NoopSyncClientTests.swift
// Unit tests for no-op sync client

import Domain
import Foundation
import SyncInterfaces
import SyncNoop
import XCTest

final class NoopSyncClientTests: XCTestCase {
    var client: NoopSyncClient!

    override func setUp() async throws {
        try await super.setUp()
        client = NoopSyncClient()
    }

    func testStatusIsUnavailable() async {
        let status = await client.status
        XCTAssertEqual(status, .unavailable)
    }

    func testCheckAvailabilityReturnsFalse() async {
        let isAvailable = await client.checkAvailability()
        XCTAssertFalse(isAvailable)
    }

    func testSyncReturnsSuccess() async {
        let result = await client.sync()

        if case let .success(uploaded, downloaded, conflicts) = result {
            XCTAssertEqual(uploaded, 0)
            XCTAssertEqual(downloaded, 0)
            XCTAssertEqual(conflicts, 0)
        } else {
            XCTFail("Expected success result")
        }
    }

    func testUploadOperationsDoNotThrow() async throws {
        let board = Board(id: BoardID(), title: "Test Board")
        let list = PersonalList(id: ListID(), cardID: CardID(), title: "Test List")
        let recipe = Recipe(id: RecipeID(), cardID: CardID(), title: "Test Recipe")

        try await client.uploadBoard(board)
        try await client.uploadList(list)
        try await client.uploadRecipe(recipe)

        // No assertions needed - just verifying no-op operations don't throw
    }

    func testDeleteOperationsDoNotThrow() async throws {
        try await client.deleteBoard(BoardID())
        try await client.deleteList(ListID())
        try await client.deleteRecipe(RecipeID())

        // No assertions needed - just verifying no-op operations don't throw
    }
}
