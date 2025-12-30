// Tests/ImportExportTests/TrelloImporterTests.swift
// Unit tests for Trello importer

import Domain
import ImportExport
import PersistenceInterfaces
import XCTest

final class TrelloImporterTests: XCTestCase {
    // MARK: - Decoding Tests

    func testDecodeMinimalTrelloExport() throws {
        let json = """
        {
          "id": "board123",
          "name": "Test Board",
          "lists": [
            {
              "id": "list1",
              "name": "To Do",
              "pos": 1000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Task 1",
              "idList": "list1",
              "pos": 100
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()

        XCTAssertNoThrow(try decoder.decode(TrelloExport.self, from: data))
    }

    func testDecodeFullTrelloExport() throws {
        let fixtureURL = fixtureURL(for: "trello_full.json")
        let data = try Data(contentsOf: fixtureURL)
        let decoder = JSONDecoder()

        let export = try decoder.decode(TrelloExport.self, from: data)

        XCTAssertEqual(export.name, "Full Feature Board")
        XCTAssertEqual(export.lists.count, 3)
        XCTAssertEqual(export.cards.count, 5)
    }

    // MARK: - Mapping Tests

    func testMapBasicBoard() throws {
        let json = """
        {
          "id": "board1",
          "name": "My Board",
          "lists": [
            {
              "id": "list1",
              "name": "To Do",
              "pos": 1000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Task",
              "idList": "list1",
              "pos": 100
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let export = try JSONDecoder().decode(TrelloExport.self, from: data)

        let (board, columns, cards) = TrelloMapper.map(export)

        XCTAssertEqual(board.title, "My Board")
        XCTAssertEqual(columns.count, 1)
        XCTAssertEqual(cards.count, 1)

        XCTAssertEqual(columns[0].title, "To Do")
        XCTAssertEqual(columns[0].board, board.id)

        XCTAssertEqual(cards[0].title, "Task")
        XCTAssertEqual(cards[0].column, columns[0].id)
    }

    func testMapBoardWithLabels() throws {
        let json = """
        {
          "id": "board1",
          "name": "Tagged Board",
          "lists": [
            {
              "id": "list1",
              "name": "Tasks",
              "pos": 1000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Tagged Card",
              "idList": "list1",
              "pos": 100,
              "labels": [
                {
                  "id": "label1",
                  "name": "bug",
                  "color": "red"
                },
                {
                  "id": "label2",
                  "name": "urgent",
                  "color": "orange"
                }
              ]
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let export = try JSONDecoder().decode(TrelloExport.self, from: data)
        let (_, _, cards) = TrelloMapper.map(export)

        XCTAssertEqual(cards[0].tags.count, 2)
        XCTAssertTrue(cards[0].tags.contains("bug"))
        XCTAssertTrue(cards[0].tags.contains("urgent"))
    }

    func testMapBoardWithChecklists() throws {
        let json = """
        {
          "id": "board1",
          "name": "Board with Checklists",
          "lists": [
            {
              "id": "list1",
              "name": "Tasks",
              "pos": 1000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Card with Checklist",
              "idList": "list1",
              "pos": 100,
              "checklists": [
                {
                  "id": "cl1",
                  "name": "Todo",
                  "checkItems": [
                    {
                      "id": "item1",
                      "name": "Done item",
                      "state": "complete",
                      "pos": 100
                    },
                    {
                      "id": "item2",
                      "name": "Pending item",
                      "state": "incomplete",
                      "pos": 200
                    }
                  ]
                }
              ]
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let export = try JSONDecoder().decode(TrelloExport.self, from: data)
        let (_, _, cards) = TrelloMapper.map(export)

        XCTAssertEqual(cards[0].checklist.count, 2)
        XCTAssertEqual(cards[0].checklist[0].text, "Done item")
        XCTAssertTrue(cards[0].checklist[0].isDone)
        XCTAssertEqual(cards[0].checklist[1].text, "Pending item")
        XCTAssertFalse(cards[0].checklist[1].isDone)
    }

    func testMapFiltersClosedLists() throws {
        let json = """
        {
          "id": "board1",
          "name": "Board",
          "lists": [
            {
              "id": "list1",
              "name": "Open List",
              "closed": false,
              "pos": 1000
            },
            {
              "id": "list2",
              "name": "Closed List",
              "closed": true,
              "pos": 2000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Card in open list",
              "idList": "list1",
              "pos": 100
            },
            {
              "id": "card2",
              "name": "Card in closed list",
              "idList": "list2",
              "pos": 100
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let export = try JSONDecoder().decode(TrelloExport.self, from: data)
        let (_, columns, cards) = TrelloMapper.map(export)

        // Should only have 1 column (closed list filtered out)
        XCTAssertEqual(columns.count, 1)
        XCTAssertEqual(columns[0].title, "Open List")

        // Should only have 1 card (card in closed list filtered out)
        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards[0].title, "Card in open list")
    }

    func testMapFiltersClosedCards() throws {
        let json = """
        {
          "id": "board1",
          "name": "Board",
          "lists": [
            {
              "id": "list1",
              "name": "List",
              "pos": 1000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Open Card",
              "idList": "list1",
              "pos": 100,
              "closed": false
            },
            {
              "id": "card2",
              "name": "Closed Card",
              "idList": "list1",
              "pos": 200,
              "closed": true
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let export = try JSONDecoder().decode(TrelloExport.self, from: data)
        let (_, _, cards) = TrelloMapper.map(export)

        XCTAssertEqual(cards.count, 1)
        XCTAssertEqual(cards[0].title, "Open Card")
    }

    func testMapSortsByPosition() throws {
        let json = """
        {
          "id": "board1",
          "name": "Board",
          "lists": [
            {
              "id": "list1",
              "name": "List C",
              "pos": 3000
            },
            {
              "id": "list2",
              "name": "List A",
              "pos": 1000
            },
            {
              "id": "list3",
              "name": "List B",
              "pos": 2000
            }
          ],
          "cards": [
            {
              "id": "card1",
              "name": "Card 3",
              "idList": "list2",
              "pos": 300
            },
            {
              "id": "card2",
              "name": "Card 1",
              "idList": "list2",
              "pos": 100
            },
            {
              "id": "card3",
              "name": "Card 2",
              "idList": "list2",
              "pos": 200
            }
          ]
        }
        """

        let data = json.data(using: .utf8)!
        let export = try JSONDecoder().decode(TrelloExport.self, from: data)
        let (_, columns, cards) = TrelloMapper.map(export)

        // Lists should be sorted by position
        XCTAssertEqual(columns[0].title, "List A")
        XCTAssertEqual(columns[1].title, "List B")
        XCTAssertEqual(columns[2].title, "List C")

        // Cards should be sorted by position (reflected in sortKey)
        XCTAssertEqual(cards[0].title, "Card 1")
        XCTAssertEqual(cards[0].sortKey, 0)
        XCTAssertEqual(cards[1].title, "Card 2")
        XCTAssertEqual(cards[1].sortKey, 1)
        XCTAssertEqual(cards[2].title, "Card 3")
        XCTAssertEqual(cards[2].sortKey, 2)
    }

    // MARK: - Import Tests

    func testImportBasicBoard() async throws {
        let repository = MockBoardsRepository()
        let importer = TrelloImporter(repository: repository)

        let fixtureURL = fixtureURL(for: "trello_minimal.json")
        let result = try await importer.importFile(fixtureURL, deduplicate: false)

        XCTAssertEqual(result.boardsImported, 1)
        XCTAssertEqual(result.columnsImported, 3)
        XCTAssertEqual(result.cardsImported, 3)
        XCTAssertEqual(result.skipped, 0)

        // Verify repository calls
        let boards = await repository.boards
        let columns = await repository.columns
        let cards = await repository.cards

        XCTAssertEqual(boards.count, 1)
        XCTAssertEqual(columns.count, 3)
        XCTAssertEqual(cards.count, 3)

        XCTAssertEqual(boards[0].title, "Minimal Test Board")
    }

    func testImportFullBoard() async throws {
        let repository = MockBoardsRepository()
        let importer = TrelloImporter(repository: repository)

        let fixtureURL = fixtureURL(for: "trello_full.json")
        let result = try await importer.importFile(fixtureURL, deduplicate: false)

        XCTAssertEqual(result.boardsImported, 1)
        // Should only import 2 columns (one is closed)
        XCTAssertEqual(result.columnsImported, 2)
        // Should only import 3 cards (one is closed, one is in closed list - filtered out)
        XCTAssertEqual(result.cardsImported, 3)
    }

    func testDeduplicationSkipsDuplicate() async throws {
        let repository = MockBoardsRepository()
        let importer = TrelloImporter(repository: repository)

        // Create existing board with same name
        let existingBoard = Board(title: "Minimal Test Board")
        try await repository.createBoard(existingBoard)

        let fixtureURL = fixtureURL(for: "trello_minimal.json")
        let result = try await importer.importFile(fixtureURL, deduplicate: true)

        XCTAssertEqual(result.boardsImported, 0)
        XCTAssertEqual(result.columnsImported, 0)
        XCTAssertEqual(result.cardsImported, 0)
        XCTAssertEqual(result.skipped, 1)

        // Should still only have 1 board
        let boards = await repository.boards
        XCTAssertEqual(boards.count, 1)
    }

    func testDeduplicationIsCaseInsensitive() async throws {
        let repository = MockBoardsRepository()
        let importer = TrelloImporter(repository: repository)

        // Create existing board with different casing
        let existingBoard = Board(title: "MINIMAL TEST BOARD")
        try await repository.createBoard(existingBoard)

        let fixtureURL = fixtureURL(for: "trello_minimal.json")
        let result = try await importer.importFile(fixtureURL, deduplicate: true)

        XCTAssertEqual(result.skipped, 1)
        let boards = await repository.boards
        XCTAssertEqual(boards.count, 1)
    }

    func testImportWithoutDeduplication() async throws {
        let repository = MockBoardsRepository()
        let importer = TrelloImporter(repository: repository)

        // Create existing board with same name
        let existingBoard = Board(title: "Minimal Test Board")
        try await repository.createBoard(existingBoard)

        let fixtureURL = fixtureURL(for: "trello_minimal.json")
        let result = try await importer.importFile(fixtureURL, deduplicate: false)

        XCTAssertEqual(result.boardsImported, 1)
        XCTAssertEqual(result.skipped, 0)

        // Should now have 2 boards
        let boards = await repository.boards
        XCTAssertEqual(boards.count, 2)
    }

    // MARK: - Helpers

    private func fixtureURL(for filename: String) -> URL {
        // Try to find fixture file relative to test bundle
        let currentFile = URL(fileURLWithPath: #file)
        let testsDir = currentFile.deletingLastPathComponent().deletingLastPathComponent()
        let fixturesDir = testsDir.appendingPathComponent("Fixtures")
        return fixturesDir.appendingPathComponent(filename)
    }
}

// MARK: - Mock Repository

private actor MockBoardsRepository: BoardsRepository {
    var boards: [Board] = []
    var columns: [Column] = []
    var cards: [Card] = []

    func createBoard(_ board: Board) async throws {
        boards.append(board)
    }

    func loadBoards() async throws -> [Board] {
        return boards
    }

    func loadBoard(_ id: BoardID) async throws -> Board {
        guard let board = boards.first(where: { $0.id == id }) else {
            throw PersistenceError.notFound("Board with ID \(id)")
        }
        return board
    }

    func updateBoard(_ board: Board) async throws {
        guard let index = boards.firstIndex(where: { $0.id == board.id }) else {
            throw PersistenceError.notFound("Board with ID \(board.id)")
        }
        boards[index] = board
    }

    func deleteBoard(_ id: BoardID) async throws {
        boards.removeAll { $0.id == id }
    }

    func createColumn(_ column: Column) async throws {
        columns.append(column)
    }

    func loadColumns(for boardID: BoardID) async throws -> [Column] {
        return columns.filter { $0.board == boardID }
    }

    func loadColumn(_ id: ColumnID) async throws -> Column {
        guard let column = columns.first(where: { $0.id == id }) else {
            throw PersistenceError.notFound("Column with ID \(id)")
        }
        return column
    }

    func updateColumn(_ column: Column) async throws {
        guard let index = columns.firstIndex(where: { $0.id == column.id }) else {
            throw PersistenceError.notFound("Column with ID \(column.id)")
        }
        columns[index] = column
    }

    func saveColumns(_ cols: [Column]) async throws {
        for column in cols {
            if columns.contains(where: { $0.id == column.id }) {
                try await updateColumn(column)
            } else {
                columns.append(column)
            }
        }
    }

    func deleteColumn(_ id: ColumnID) async throws {
        columns.removeAll { $0.id == id }
    }

    func createCard(_ card: Card) async throws {
        cards.append(card)
    }

    func loadCards(for columnID: ColumnID) async throws -> [Card] {
        return cards.filter { $0.column == columnID }
    }

    func loadCard(_ id: CardID) async throws -> Card {
        guard let card = cards.first(where: { $0.id == id }) else {
            throw PersistenceError.notFound("Card with ID \(id)")
        }
        return card
    }

    func updateCard(_ card: Card) async throws {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else {
            throw PersistenceError.notFound("Card with ID \(card.id)")
        }
        cards[index] = card
    }

    func saveCards(_ newCards: [Card]) async throws {
        for card in newCards {
            if cards.contains(where: { $0.id == card.id }) {
                try await updateCard(card)
            } else {
                cards.append(card)
            }
        }
    }

    func deleteCard(_ id: CardID) async throws {
        cards.removeAll { $0.id == id }
    }

    func searchCards(query: String) async throws -> [Card] {
        return cards.filter {
            $0.title.localizedCaseInsensitiveContains(query) ||
            $0.details.localizedCaseInsensitiveContains(query)
        }
    }

    func findCards(byTag tag: String) async throws -> [Card] {
        return cards.filter { $0.tags.contains(tag) }
    }

    func findCards(dueBetween from: Date, and to: Date) async throws -> [Card] {
        return cards.filter {
            guard let due = $0.due else { return false }
            return due >= from && due <= to
        }
    }

    func loadCardWithRecipe(_ cardID: CardID) async throws -> (Card, Recipe?) {
        let card = try await loadCard(cardID)
        return (card, nil)
    }

    func loadCardWithList(_ cardID: CardID) async throws -> (Card, PersonalList?) {
        let card = try await loadCard(cardID)
        return (card, nil)
    }

    func findCardsWithRecipes(boardID: BoardID?) async throws -> [Card] {
        return []
    }

    func findCardsWithLists(boardID: BoardID?) async throws -> [Card] {
        return []
    }
}
