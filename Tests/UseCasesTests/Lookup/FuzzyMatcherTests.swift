// Tests/UseCasesTests/Lookup/FuzzyMatcherTests.swift
// Unit tests for FuzzyMatcher

import XCTest
@testable import UseCases

final class FuzzyMatcherTests: XCTestCase {

    // MARK: - Exact Matches

    func testExactMatch() {
        let score = FuzzyMatcher.similarity(query: "Home", target: "Home")
        XCTAssertEqual(score, 1.0, accuracy: 0.01)
    }

    func testExactMatchCaseInsensitive() {
        let score = FuzzyMatcher.similarity(query: "home", target: "Home")
        XCTAssertEqual(score, 1.0, accuracy: 0.01)
    }

    func testExactMatchWithWhitespace() {
        let score = FuzzyMatcher.similarity(query: "  Home  ", target: "Home")
        XCTAssertEqual(score, 1.0, accuracy: 0.01)
    }

    // MARK: - Prefix Matches

    func testPrefixMatch() {
        let score = FuzzyMatcher.similarity(query: "Gro", target: "Groceries")
        XCTAssertEqual(score, 0.9, accuracy: 0.01)
    }

    func testPrefixMatchCaseInsensitive() {
        let score = FuzzyMatcher.similarity(query: "gro", target: "Groceries")
        XCTAssertEqual(score, 0.9, accuracy: 0.01)
    }

    // MARK: - Contains Matches

    func testContainsMatch() {
        let score = FuzzyMatcher.similarity(query: "ocer", target: "Groceries")
        XCTAssertEqual(score, 0.7, accuracy: 0.01)
    }

    func testWordStartMatch() {
        let score = FuzzyMatcher.similarity(query: "To", target: "To Do")
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }

    func testWordPrefixMatch() {
        let score = FuzzyMatcher.similarity(query: "Do", target: "To Do")
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }

    // MARK: - No Matches

    func testNoMatch() {
        let score = FuzzyMatcher.similarity(query: "xyz", target: "Home")
        XCTAssertLessThan(score, 0.5)
    }

    func testEmptyQuery() {
        let score = FuzzyMatcher.similarity(query: "", target: "Home")
        XCTAssertEqual(score, 0.0)
    }

    func testEmptyTarget() {
        let score = FuzzyMatcher.similarity(query: "Home", target: "")
        XCTAssertEqual(score, 0.0)
    }

    // MARK: - Levenshtein Distance

    func testCloseMatch() {
        let score = FuzzyMatcher.similarity(query: "Hme", target: "Home")
        XCTAssertGreaterThan(score, 0.0)
    }

    func testTypo() {
        let score = FuzzyMatcher.similarity(query: "Grocries", target: "Groceries")
        XCTAssertGreaterThan(score, 0.0)
    }

    // MARK: - Find Matches

    func testFindMatchesBasic() {
        struct Item {
            let name: String
        }

        let items = [
            Item(name: "Home"),
            Item(name: "Work"),
            Item(name: "Homework")
        ]

        let matches = FuzzyMatcher.findMatches(
            query: "Home",
            in: items,
            by: \.name
        )

        XCTAssertEqual(matches.count, 2) // "Home" and "Homework"
        XCTAssertEqual(matches[0].name, "Home") // Exact match first
    }

    func testFindMatchesWithThreshold() {
        struct Item {
            let name: String
        }

        let items = [
            Item(name: "Groceries"),
            Item(name: "To Do"),
            Item(name: "Shopping")
        ]

        let matches = FuzzyMatcher.findMatches(
            query: "Gro",
            in: items,
            by: \.name,
            threshold: 0.8
        )

        XCTAssertEqual(matches.count, 1)
        XCTAssertEqual(matches[0].name, "Groceries")
    }

    func testFindMatchesNoResults() {
        struct Item {
            let name: String
        }

        let items = [
            Item(name: "Home"),
            Item(name: "Work")
        ]

        let matches = FuzzyMatcher.findMatches(
            query: "xyz",
            in: items,
            by: \.name,
            threshold: 0.5
        )

        XCTAssertTrue(matches.isEmpty)
    }

    // MARK: - Real-World Scenarios

    func testGroceryListMatch() {
        let score = FuzzyMatcher.similarity(query: "groc", target: "Groceries")
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }

    func testToDoColumnMatch() {
        let score = FuzzyMatcher.similarity(query: "todo", target: "To Do")
        XCTAssertGreaterThanOrEqual(score, 0.6)
    }

    func testPartialBoardName() {
        let score = FuzzyMatcher.similarity(query: "hom", target: "Home")
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }

    func testMultiWordMatch() {
        let score = FuzzyMatcher.similarity(query: "Pay", target: "Pay Strata")
        XCTAssertGreaterThanOrEqual(score, 0.8)
    }
}
