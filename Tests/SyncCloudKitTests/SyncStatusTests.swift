// Tests/SyncCloudKitTests/SyncStatusTests.swift
// Unit tests for sync status handling

import Foundation
import SyncInterfaces
import XCTest

final class SyncStatusTests: XCTestCase {
    func testSyncStatusEquality() {
        XCTAssertEqual(SyncStatus.idle, SyncStatus.idle)
        XCTAssertEqual(SyncStatus.syncing, SyncStatus.syncing)
        XCTAssertEqual(SyncStatus.unavailable, SyncStatus.unavailable)

        let date1 = Date()
        XCTAssertEqual(SyncStatus.success(syncedAt: date1), SyncStatus.success(syncedAt: date1))
        XCTAssertEqual(SyncStatus.failed(error: "test"), SyncStatus.failed(error: "test"))
    }

    func testSyncStatusInequality() {
        XCTAssertNotEqual(SyncStatus.idle, SyncStatus.syncing)
        XCTAssertNotEqual(SyncStatus.idle, SyncStatus.unavailable)

        let date1 = Date()
        let date2 = date1.addingTimeInterval(100)
        XCTAssertNotEqual(SyncStatus.success(syncedAt: date1), SyncStatus.success(syncedAt: date2))
        XCTAssertNotEqual(SyncStatus.failed(error: "error1"), SyncStatus.failed(error: "error2"))
    }

    func testSyncResultEquality() {
        XCTAssertEqual(
            SyncResult.success(uploadedCount: 1, downloadedCount: 2, conflictsResolved: 3),
            SyncResult.success(uploadedCount: 1, downloadedCount: 2, conflictsResolved: 3)
        )
        XCTAssertEqual(SyncResult.failure(error: "test"), SyncResult.failure(error: "test"))
    }

    func testSyncResultInequality() {
        XCTAssertNotEqual(
            SyncResult.success(uploadedCount: 1, downloadedCount: 2, conflictsResolved: 3),
            SyncResult.success(uploadedCount: 2, downloadedCount: 2, conflictsResolved: 3)
        )
        XCTAssertNotEqual(SyncResult.failure(error: "error1"), SyncResult.failure(error: "error2"))
    }
}
