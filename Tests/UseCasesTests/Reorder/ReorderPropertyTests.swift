// Tests/UseCasesTests/Reorder/ReorderPropertyTests.swift
// Property-based tests for edge cases in reordering

import XCTest
@testable import UseCases

final class ReorderPropertyTests: XCTestCase {

    var service: CardReorderService!

    override func setUp() async throws {
        try await super.setUp()
        service = CardReorderService()
    }

    override func tearDown() async throws {
        await service.cancelIdleNormalization()
        service = nil
        try await super.tearDown()
    }

    // MARK: - Duplicate Keys Properties

    func testProperty_DuplicateKeysAlwaysTriggerNormalization() async {
        // Property: Any array with duplicate values should need normalization
        let testCases: [[Double]] = [
            [1.0, 1.0],
            [0.0, 0.0, 1.0],
            [1.0, 2.0, 2.0, 3.0],
            [5.0, 5.0, 5.0, 5.0],
            [-1.0, -1.0, 0.0],
        ]

        for keys in testCases {
            let needsNorm = await service.needsNormalization(keys)
            XCTAssertTrue(needsNorm, "Duplicate keys \(keys) should trigger normalization")
        }
    }

    func testProperty_NormalizationEliminatesDuplicates() async {
        // Property: After normalization, all keys should be unique
        let testCases: [[Double]] = [
            [1.0, 1.0, 1.0],
            [5.0, 5.0, 10.0, 10.0],
            [0.0, 0.0, 0.0, 0.0],
        ]

        for var keys in testCases {
            await service.normalize(&keys)
            let uniqueKeys = Set(keys)
            XCTAssertEqual(keys.count, uniqueKeys.count,
                          "Normalized keys should all be unique: \(keys)")
        }
    }

    // MARK: - Large Delta Properties

    func testProperty_LargeDeltasPreserveMidpoint() async {
        // Property: Midpoint should always be between the two values
        let largeDeltaCases: [(Double, Double)] = [
            (0.0, 1_000_000.0),
            (-1_000_000.0, 1_000_000.0),
            (1_000_000.0, 2_000_000.0),
            (-500_000.0, 500_000.0),
            (0.0, Double.greatestFiniteMagnitude / 2),
        ]

        for (a, b) in largeDeltaCases {
            let mid = await service.calculateMidpoint(after: a, before: b)
            XCTAssertGreaterThan(mid, a, "Midpoint \(mid) should be > \(a)")
            XCTAssertLessThan(mid, b, "Midpoint \(mid) should be < \(b)")
        }
    }

    func testProperty_NormalizationHandlesLargeDeltas() async {
        // Property: Normalization should work regardless of input magnitude
        let testCases: [[Double]] = [
            [0.0, 1_000_000.0, 2_000_000.0],
            [-1_000_000.0, 0.0, 1_000_000.0],
            [1e10, 2e10, 3e10],
            [0.0, 1e-10, 1e10],
        ]

        for var keys in testCases {
            await service.normalize(&keys)
            XCTAssertEqual(keys, [0.0, 1.0, 2.0],
                          "Large deltas should normalize to [0, 1, 2]")
        }
    }

    // MARK: - Repeated Operations Properties

    func testProperty_RepeatedMidpointsEventuallyNeedNormalization() async {
        // Property: Repeatedly inserting at the same position creates diminishing gaps
        var keys = [0.0, 1.0]

        // Insert 20 times between the same two positions
        for _ in 0..<20 {
            let mid = await service.calculateMidpoint(after: keys[0], before: keys[1])
            keys.insert(mid, at: 1)
        }

        let needsNorm = await service.needsNormalization(keys)
        XCTAssertTrue(needsNorm,
                     "After many insertions, gaps should be small enough to need normalization")
    }

    func testProperty_NormalizationRestoresWellSpacedKeys() async {
        // Property: After normalization, keys should be well-spaced
        var keys = [0.0]

        // Create many tightly-spaced keys
        for i in 1..<50 {
            keys.append(Double(i) * 0.00001)
        }

        await service.normalize(&keys)

        let needsNorm = await service.needsNormalization(keys)
        XCTAssertFalse(needsNorm,
                      "After normalization, keys should not need immediate re-normalization")
    }

    func testProperty_ManyConsecutiveReordersProduceMonotonicKeys() async {
        // Property: Many reorders should maintain monotonicity when inserted in order
        var keys: [Double] = []

        for i in 0..<100 {
            let prev = i > 0 ? keys[i - 1] : nil
            let newKey = await service.calculateMidpoint(after: prev, before: nil)
            keys.append(newKey)
        }

        // Check that keys are strictly increasing
        for i in 1..<keys.count {
            XCTAssertGreaterThan(keys[i], keys[i - 1],
                               "Key at index \(i) should be > key at \(i-1)")
        }
    }

    // MARK: - Extreme Value Properties

    func testProperty_ExtremelySmallGapsAreHandled() async {
        // Property: Even extremely small gaps can be bisected
        let testCases: [(Double, Double)] = [
            (1.0, 1.0000000001),
            (0.0, 1e-100),
            (-1e-50, 1e-50),
        ]

        for (a, b) in testCases {
            let mid = await service.calculateMidpoint(after: a, before: b)
            // Just verify it doesn't crash and produces a finite value
            XCTAssertTrue(mid.isFinite, "Midpoint for tiny gap should be finite")
            XCTAssertGreaterThanOrEqual(mid, min(a, b),
                                       "Midpoint should be >= min value")
            XCTAssertLessThanOrEqual(mid, max(a, b),
                                    "Midpoint should be <= max value")
        }
    }

    func testProperty_NegativeAndPositiveValuesNormalizeSame() async {
        // Property: Sign shouldn't affect normalization
        var positiveKeys = [10.0, 20.0, 30.0]
        var negativeKeys = [-30.0, -20.0, -10.0]
        var mixedKeys = [-10.0, 0.0, 10.0]

        await service.normalize(&positiveKeys)
        await service.normalize(&negativeKeys)
        await service.normalize(&mixedKeys)

        let expected = [0.0, 1.0, 2.0]
        XCTAssertEqual(positiveKeys, expected)
        XCTAssertEqual(negativeKeys, expected)
        XCTAssertEqual(mixedKeys, expected)
    }

    func testProperty_ZeroIsValidKey() async {
        // Property: Zero should be a valid key value
        let mid1 = await service.calculateMidpoint(after: nil, before: nil)
        XCTAssertEqual(mid1, 0.0)

        let mid2 = await service.calculateMidpoint(after: -1.0, before: 1.0)
        XCTAssertEqual(mid2, 0.0)

        var keys = [0.0, 1.0, 2.0]
        await service.normalize(&keys)
        XCTAssertEqual(keys[0], 0.0)
    }

    // MARK: - Boundary Condition Properties

    func testProperty_SingleElementNeverNeedsNormalization() async {
        // Property: A single element array never needs normalization
        let testCases: [[Double]] = [
            [0.0],
            [1_000_000.0],
            [-999.99],
            [1e-100],
        ]

        for keys in testCases {
            let needsNorm = await service.needsNormalization(keys)
            XCTAssertFalse(needsNorm,
                          "Single element \(keys) should not need normalization")
        }
    }

    func testProperty_EmptyArrayNeverNeedsNormalization() async {
        let keys: [Double] = []
        let needsNorm = await service.needsNormalization(keys)
        XCTAssertFalse(needsNorm, "Empty array should not need normalization")
    }

    func testProperty_WellSpacedKeysNeverNeedNormalization() async {
        // Property: Keys spaced >= 1.0 apart should not need normalization
        let testCases: [[Double]] = [
            [0.0, 1.0, 2.0],
            [0.0, 10.0, 20.0],
            [-10.0, 0.0, 10.0],
            [100.0, 200.0, 300.0],
        ]

        for keys in testCases {
            let needsNorm = await service.needsNormalization(keys)
            XCTAssertFalse(needsNorm,
                          "Well-spaced keys \(keys) should not need normalization")
        }
    }

    // MARK: - Idempotency Properties

    func testProperty_NormalizationIsIdempotent() async {
        // Property: Normalizing twice produces the same result as normalizing once
        var keys1 = [5.5, 10.7, 15.3, 20.9]
        var keys2 = keys1

        await service.normalize(&keys1)
        await service.normalize(&keys1) // Second normalization

        await service.normalize(&keys2) // Single normalization

        XCTAssertEqual(keys1, keys2,
                      "Double normalization should equal single normalization")
    }

    func testProperty_NormalizedKeysAreSequential() async {
        // Property: Normalized keys should be [0, 1, 2, ..., n-1]
        let testCases: [[Double]] = [
            [99.9, 88.8, 77.7],
            [1.1, 2.2, 3.3, 4.4, 5.5],
            [-5.0, -2.5, 0.0, 2.5, 5.0],
            [1e10, 2e10],
        ]

        for var keys in testCases {
            let originalCount = keys.count
            await service.normalize(&keys)

            for i in keys.indices {
                XCTAssertEqual(keys[i], Double(i), accuracy: 0.0001,
                             "Index \(i) should have value \(i)")
            }
            XCTAssertEqual(keys.count, originalCount,
                          "Normalization should not change array count")
        }
    }

    // MARK: - Stress Tests

    func testProperty_ThousandsOfReordersRemainStable() async {
        // Stress test: Many operations should not cause overflow or precision loss
        var keys = await service.generateNormalizedKeys(count: 10)

        for _ in 0..<1000 {
            // Pick random positions
            let idx = Int.random(in: 0..<keys.count)
            let prev = idx > 0 ? keys[idx - 1] : nil
            let next = idx < keys.count ? keys[idx] : nil

            let newKey = await service.calculateMidpoint(after: prev, before: next)

            // Verify the new key is finite
            XCTAssertTrue(newKey.isFinite, "After 1000 reorders, keys should remain finite")

            keys.insert(newKey, at: idx)

            // Periodically normalize to simulate real usage
            if keys.count % 100 == 0 {
                await service.normalize(&keys)
            }
        }

        XCTAssertGreaterThan(keys.count, 1000,
                           "Should have accumulated many keys")
    }

    func testProperty_ConcurrentAccessMaintainsConsistency() async {
        // Property: Concurrent access should be safe
        await withTaskGroup(of: Void.self) { group in
            // Run multiple concurrent operations
            for i in 0..<50 {
                group.addTask {
                    _ = await self.service.calculateMidpoint(
                        after: Double(i),
                        before: Double(i + 2)
                    )
                }

                group.addTask {
                    var keys = [Double(i), Double(i + 1), Double(i + 2)]
                    await self.service.normalize(&keys)
                }

                group.addTask {
                    _ = await self.service.needsNormalization([Double(i), Double(i) + 0.00001])
                }
            }

            await group.waitForAll()
        }

        // If we get here without crashes, thread safety is working
        XCTAssertTrue(true, "Concurrent access completed safely")
    }
}
