// Tests/UseCasesTests/Reorder/CardReorderServiceTests.swift
// Unit tests for CardReorderService

import XCTest
@testable import UseCases

final class CardReorderServiceTests: XCTestCase {

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

    // MARK: - Midpoint Calculation Tests

    func testMidpoint_BetweenTwoCards() async {
        let result = await service.calculateMidpoint(after: 1.0, before: 3.0)
        XCTAssertEqual(result, 2.0, accuracy: 0.0001)
    }

    func testMidpoint_AfterLastCard() async {
        let result = await service.calculateMidpoint(after: 5.0, before: nil)
        XCTAssertEqual(result, 6.0, accuracy: 0.0001)
    }

    func testMidpoint_BeforeFirstCard() async {
        let result = await service.calculateMidpoint(after: nil, before: 3.0)
        XCTAssertEqual(result, 2.0, accuracy: 0.0001)
    }

    func testMidpoint_EmptyList() async {
        let result = await service.calculateMidpoint(after: nil, before: nil)
        XCTAssertEqual(result, 0.0, accuracy: 0.0001)
    }

    func testMidpoint_BetweenCloseValues() async {
        let result = await service.calculateMidpoint(after: 1.0, before: 1.001)
        XCTAssertEqual(result, 1.0005, accuracy: 0.00001)
    }

    func testMidpoint_BetweenNegativeValues() async {
        let result = await service.calculateMidpoint(after: -5.0, before: -3.0)
        XCTAssertEqual(result, -4.0, accuracy: 0.0001)
    }

    func testMidpoint_BetweenLargeValues() async {
        let result = await service.calculateMidpoint(after: 1_000_000.0, before: 1_000_002.0)
        XCTAssertEqual(result, 1_000_001.0, accuracy: 0.1)
    }

    // MARK: - Normalization Tests

    func testNormalize_SimpleSequence() async {
        var keys = [1.0, 2.0, 3.0, 4.0]
        await service.normalize(&keys)
        XCTAssertEqual(keys, [0.0, 1.0, 2.0, 3.0])
    }

    func testNormalize_FractionalKeys() async {
        var keys = [0.5, 1.5, 2.75, 3.125]
        await service.normalize(&keys)
        XCTAssertEqual(keys, [0.0, 1.0, 2.0, 3.0])
    }

    func testNormalize_UnsortedKeys() async {
        var keys = [5.0, 2.0, 8.0, 1.0]
        await service.normalize(&keys)
        // Normalization normalizes in place, not sorted
        XCTAssertEqual(keys, [0.0, 1.0, 2.0, 3.0])
    }

    func testNormalize_EmptyArray() async {
        var keys: [Double] = []
        await service.normalize(&keys)
        XCTAssertEqual(keys, [])
    }

    func testNormalize_SingleElement() async {
        var keys = [42.0]
        await service.normalize(&keys)
        XCTAssertEqual(keys, [0.0])
    }

    func testNormalize_NegativeValues() async {
        var keys = [-5.0, -2.0, -1.0]
        await service.normalize(&keys)
        XCTAssertEqual(keys, [0.0, 1.0, 2.0])
    }

    func testNormalize_LargeValues() async {
        var keys = [1_000_000.0, 2_000_000.0, 3_000_000.0]
        await service.normalize(&keys)
        XCTAssertEqual(keys, [0.0, 1.0, 2.0])
    }

    // MARK: - Normalization Detection Tests

    func testNeedsNormalization_WhenKeysAreTooClose() async {
        let keys = [0.0, 0.00005, 1.0]
        let result = await service.needsNormalization(keys)
        XCTAssertTrue(result)
    }

    func testNeedsNormalization_WhenKeysAreWellSpaced() async {
        let keys = [0.0, 1.0, 2.0, 3.0]
        let result = await service.needsNormalization(keys)
        XCTAssertFalse(result)
    }

    func testNeedsNormalization_EmptyArray() async {
        let keys: [Double] = []
        let result = await service.needsNormalization(keys)
        XCTAssertFalse(result)
    }

    func testNeedsNormalization_SingleElement() async {
        let keys = [1.0]
        let result = await service.needsNormalization(keys)
        XCTAssertFalse(result)
    }

    func testNeedsNormalization_DuplicateKeys() async {
        let keys = [1.0, 1.0, 2.0]
        let result = await service.needsNormalization(keys)
        XCTAssertTrue(result)
    }

    func testNeedsNormalization_UnsortedInput() async {
        let keys = [3.0, 0.00005, 0.0]
        let result = await service.needsNormalization(keys)
        XCTAssertTrue(result)
    }

    // MARK: - Convenience Method Tests

    func testCalculateSortKey_SameAsMidpoint() async {
        let midpoint = await service.calculateMidpoint(after: 1.0, before: 3.0)
        let sortKey = await service.calculateSortKey(previousKey: 1.0, nextKey: 3.0)
        XCTAssertEqual(midpoint, sortKey)
    }

    func testGenerateNormalizedKeys_ProducesSequentialKeys() async {
        let keys = await service.generateNormalizedKeys(count: 5)
        XCTAssertEqual(keys, [0.0, 1.0, 2.0, 3.0, 4.0])
    }

    func testGenerateNormalizedKeys_EmptyCount() async {
        let keys = await service.generateNormalizedKeys(count: 0)
        XCTAssertEqual(keys, [])
    }

    func testGenerateNormalizedKeys_SingleKey() async {
        let keys = await service.generateNormalizedKeys(count: 1)
        XCTAssertEqual(keys, [0.0])
    }

    // MARK: - Configuration Tests

    func testConfiguration_DefaultValues() async {
        let config = CardReorderService.Configuration()
        XCTAssertEqual(config.normalizationThreshold, 0.0001, accuracy: 0.00001)
        XCTAssertEqual(config.idleNormalizationDelay, 2.0, accuracy: 0.1)
    }

    func testConfiguration_CustomValues() async {
        let config = CardReorderService.Configuration(
            normalizationThreshold: 0.001,
            idleNormalizationDelay: 5.0
        )
        XCTAssertEqual(config.normalizationThreshold, 0.001, accuracy: 0.0001)
        XCTAssertEqual(config.idleNormalizationDelay, 5.0, accuracy: 0.1)
    }

    // MARK: - Idle Normalization Tests

    func testScheduleIdleNormalization_ExecutesAfterDelay() async {
        let config = CardReorderService.Configuration(idleNormalizationDelay: 0.1)
        let testService = CardReorderService(configuration: config)

        let expectation = XCTestExpectation(description: "Normalization action called")

        await testService.scheduleIdleNormalization {
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 0.5)
        await testService.cancelIdleNormalization()
    }

    func testScheduleIdleNormalization_CancelsPreviousTask() async {
        let config = CardReorderService.Configuration(idleNormalizationDelay: 0.2)
        let testService = CardReorderService(configuration: config)

        let firstExpectation = XCTestExpectation(description: "First action called")
        firstExpectation.isInverted = true

        await testService.scheduleIdleNormalization {
            firstExpectation.fulfill()
        }

        // Schedule another immediately, which should cancel the first
        let secondExpectation = XCTestExpectation(description: "Second action called")

        await testService.scheduleIdleNormalization {
            secondExpectation.fulfill()
        }

        await fulfillment(of: [firstExpectation, secondExpectation], timeout: 0.5)
        await testService.cancelIdleNormalization()
    }

    func testCancelIdleNormalization_PreventsExecution() async {
        let config = CardReorderService.Configuration(idleNormalizationDelay: 0.1)
        let testService = CardReorderService(configuration: config)

        let expectation = XCTestExpectation(description: "Action called")
        expectation.isInverted = true

        await testService.scheduleIdleNormalization {
            expectation.fulfill()
        }

        await testService.cancelIdleNormalization()

        await fulfillment(of: [expectation], timeout: 0.3)
    }

    // MARK: - Thread Safety Tests

    func testConcurrentMidpointCalculations() async {
        await withTaskGroup(of: Double.self) { group in
            for i in 0..<100 {
                group.addTask {
                    await self.service.calculateMidpoint(after: Double(i), before: Double(i + 2))
                }
            }

            var results: [Double] = []
            for await result in group {
                results.append(result)
            }

            XCTAssertEqual(results.count, 100)
        }
    }

    func testConcurrentNormalizations() async {
        await withTaskGroup(of: [Double].self) { group in
            for _ in 0..<10 {
                group.addTask {
                    var keys = [1.5, 2.7, 3.9, 4.1]
                    await self.service.normalize(&keys)
                    return keys
                }
            }

            for await result in group {
                XCTAssertEqual(result, [0.0, 1.0, 2.0, 3.0])
            }
        }
    }
}
