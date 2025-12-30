// Tests/ImportExportTests/BackupRoundTripTests.swift
// Round-trip tests for backup/restore functionality

import Domain
import Foundation
import ImportExport
import PersistenceInterfaces
import XCTest

// MARK: - Tests

final class BackupRoundTripTests: XCTestCase {
    var repository: InMemoryBoardsRepository!

    override func setUp() async throws {
        repository = InMemoryBoardsRepository()
    }

    // MARK: - Basic Round-Trip Tests

    func testExportEmptyDatabase() async throws {
        let exporter = BackupExporter(boardsRepository: repository)
        let backup = try await exporter.export()

        XCTAssertEqual(backup.version, 1)
        XCTAssertEqual(backup.boards.count, 0)
        XCTAssertEqual(backup.lists.count, 0)
        XCTAssertEqual(backup.recipes.count, 0)
    }

    func testRoundTripSingleBoard() async throws {
        // Create test data
        let board = Board(
            title: "Test Board",
            createdAt: Date(),
            updatedAt: Date()
        )
        try await repository.createBoard(board)

        let column = Column(
            board: board.id,
            title: "To Do",
            index: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        try await repository.createColumn(column)

        let card = Card(
            column: column.id,
            title: "Test Task",
            details: "Test details",
            sortKey: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        try await repository.createCard(card)

        // Export
        let exporter = BackupExporter(boardsRepository: repository)
        let backup = try await exporter.export()

        // Verify export
        XCTAssertEqual(backup.version, 1)
        XCTAssertEqual(backup.boards.count, 1)
        XCTAssertEqual(backup.boards[0].board.id, board.id)
        XCTAssertEqual(backup.boards[0].board.title, "Test Board")
        XCTAssertEqual(backup.boards[0].columns.count, 1)
        XCTAssertEqual(backup.boards[0].columns[0].column.id, column.id)
        XCTAssertEqual(backup.boards[0].columns[0].cards.count, 1)
        XCTAssertEqual(backup.boards[0].columns[0].cards[0].id, card.id)

        // Create new repository and restore
        let newRepository = InMemoryBoardsRepository()
        let restorer = BackupRestorer(boardsRepository: newRepository)
        let result = try await restorer.restore(backup, mode: .merge)

        // Verify restore result
        XCTAssertEqual(result.boardsRestored, 1)
        XCTAssertEqual(result.columnsRestored, 1)
        XCTAssertEqual(result.cardsRestored, 1)
        XCTAssertEqual(result.skipped, 0)

        // Verify restored data
        let restoredBoards = try await newRepository.loadBoards()
        XCTAssertEqual(restoredBoards.count, 1)
        XCTAssertEqual(restoredBoards[0].id, board.id)
        XCTAssertEqual(restoredBoards[0].title, board.title)

        let restoredColumns = try await newRepository.loadColumns(for: board.id)
        XCTAssertEqual(restoredColumns.count, 1)
        XCTAssertEqual(restoredColumns[0].id, column.id)
        XCTAssertEqual(restoredColumns[0].title, column.title)

        let restoredCards = try await newRepository.loadCards(for: column.id)
        XCTAssertEqual(restoredCards.count, 1)
        XCTAssertEqual(restoredCards[0].id, card.id)
        XCTAssertEqual(restoredCards[0].title, card.title)
        XCTAssertEqual(restoredCards[0].details, card.details)
    }

    func testRoundTripMultipleBoardsAndCards() async throws {
        // Create multiple boards
        let board1 = Board(title: "Board 1")
        let board2 = Board(title: "Board 2")
        try await repository.createBoard(board1)
        try await repository.createBoard(board2)

        // Create columns
        let column1 = Column(board: board1.id, title: "Column 1", index: 0)
        let column2 = Column(board: board1.id, title: "Column 2", index: 1)
        let column3 = Column(board: board2.id, title: "Column 3", index: 0)
        try await repository.createColumn(column1)
        try await repository.createColumn(column2)
        try await repository.createColumn(column3)

        // Create cards
        let card1 = Card(column: column1.id, title: "Card 1", sortKey: 0)
        let card2 = Card(column: column1.id, title: "Card 2", sortKey: 1)
        let card3 = Card(column: column2.id, title: "Card 3", sortKey: 0)
        let card4 = Card(column: column3.id, title: "Card 4", sortKey: 0)
        try await repository.createCard(card1)
        try await repository.createCard(card2)
        try await repository.createCard(card3)
        try await repository.createCard(card4)

        // Export and restore
        let exporter = BackupExporter(boardsRepository: repository)
        let backup = try await exporter.export()

        let newRepository = InMemoryBoardsRepository()
        let restorer = BackupRestorer(boardsRepository: newRepository)
        let result = try await restorer.restore(backup, mode: .merge)

        // Verify counts
        XCTAssertEqual(result.boardsRestored, 2)
        XCTAssertEqual(result.columnsRestored, 3)
        XCTAssertEqual(result.cardsRestored, 4)

        // Verify data
        let restoredBoards = try await newRepository.loadBoards()
        XCTAssertEqual(restoredBoards.count, 2)
    }

    // MARK: - Merge Mode Tests

    func testMergeSkipsExistingBoards() async throws {
        // Create initial board
        let board = Board(title: "Existing Board")
        try await repository.createBoard(board)

        // Export
        let exporter = BackupExporter(boardsRepository: repository)
        let backup = try await exporter.export()

        // Restore to same repository (merge mode should skip)
        let restorer = BackupRestorer(boardsRepository: repository)
        let result = try await restorer.restore(backup, mode: .merge)

        XCTAssertEqual(result.boardsRestored, 0)
        XCTAssertEqual(result.skipped, 1)

        // Verify only one board exists
        let boards = try await repository.loadBoards()
        XCTAssertEqual(boards.count, 1)
    }

    // MARK: - Overwrite Mode Tests

    func testOverwriteUpdatesExistingBoards() async throws {
        // Create initial board
        let board = Board(title: "Original Title")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "Original Column", index: 0)
        try await repository.createColumn(column)

        // Export
        let exporter = BackupExporter(boardsRepository: repository)
        let backup = try await exporter.export()

        // Modify the backup data
        var modifiedBoard = backup.boards[0].board
        modifiedBoard.title = "Updated Title"

        var modifiedColumn = backup.boards[0].columns[0].column
        modifiedColumn.title = "Updated Column"

        let modifiedBackup = BackupExport(
            version: 1,
            exportedAt: Date(),
            boards: [BoardExport(
                board: modifiedBoard,
                columns: [ColumnExport(column: modifiedColumn, cards: [])]
            )],
            lists: [],
            recipes: []
        )

        // Restore with overwrite mode
        let restorer = BackupRestorer(boardsRepository: repository)
        let result = try await restorer.restore(modifiedBackup, mode: .overwrite)

        XCTAssertEqual(result.boardsRestored, 1)
        XCTAssertEqual(result.columnsRestored, 1)
        XCTAssertEqual(result.skipped, 0)

        // Verify data was updated
        let updatedBoard = try await repository.loadBoard(board.id)
        XCTAssertEqual(updatedBoard.title, "Updated Title")

        let updatedColumn = try await repository.loadColumn(column.id)
        XCTAssertEqual(updatedColumn.title, "Updated Column")
    }

    // MARK: - JSON Encoding/Decoding Tests

    func testJSONRoundTrip() async throws {
        // Create test data
        let board = Board(title: "JSON Test Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "JSON Column", index: 0)
        try await repository.createColumn(column)

        let card = Card(
            column: column.id,
            title: "JSON Card",
            details: "JSON Details",
            tags: ["tag1", "tag2"],
            sortKey: 0
        )
        try await repository.createCard(card)

        // Export to JSON
        let exporter = BackupExporter(boardsRepository: repository)
        let jsonData = try await exporter.exportToData(pretty: true)

        // Verify JSON is valid
        XCTAssertGreaterThan(jsonData.count, 0)

        // Decode JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedBackup = try decoder.decode(BackupExport.self, from: jsonData)

        // Verify decoded data
        XCTAssertEqual(decodedBackup.version, 1)
        XCTAssertEqual(decodedBackup.boards.count, 1)
        XCTAssertEqual(decodedBackup.boards[0].board.title, "JSON Test Board")
        XCTAssertEqual(decodedBackup.boards[0].columns[0].cards[0].tags, ["tag1", "tag2"])

        // Restore from JSON
        let newRepository = InMemoryBoardsRepository()
        let restorer = BackupRestorer(boardsRepository: newRepository)
        let result = try await restorer.restoreFromData(jsonData, mode: .merge)

        XCTAssertEqual(result.boardsRestored, 1)
        XCTAssertEqual(result.columnsRestored, 1)
        XCTAssertEqual(result.cardsRestored, 1)
    }

    // MARK: - Checklist Tests

    func testRoundTripWithChecklist() async throws {
        let board = Board(title: "Checklist Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "Checklist Column", index: 0)
        try await repository.createColumn(column)

        let checklistItems = [
            ChecklistItem(text: "Item 1", isDone: false),
            ChecklistItem(text: "Item 2", isDone: true, quantity: 2.5, unit: "kg"),
            ChecklistItem(text: "Item 3", isDone: false, note: "Important note")
        ]

        let card = Card(
            column: column.id,
            title: "Card with Checklist",
            checklist: checklistItems,
            sortKey: 0
        )
        try await repository.createCard(card)

        // Export and restore
        let exporter = BackupExporter(boardsRepository: repository)
        let backup = try await exporter.export()

        let newRepository = InMemoryBoardsRepository()
        let restorer = BackupRestorer(boardsRepository: newRepository)
        try await restorer.restore(backup, mode: .merge)

        // Verify checklist items
        let restoredCards = try await newRepository.loadCards(for: column.id)
        XCTAssertEqual(restoredCards.count, 1)
        XCTAssertEqual(restoredCards[0].checklist.count, 3)
        XCTAssertEqual(restoredCards[0].checklist[0].text, "Item 1")
        XCTAssertEqual(restoredCards[0].checklist[1].quantity, 2.5)
        XCTAssertEqual(restoredCards[0].checklist[1].unit, "kg")
        XCTAssertEqual(restoredCards[0].checklist[2].note, "Important note")
    }

    // MARK: - Date and Due Date Tests

    func testRoundTripWithDueDates() async throws {
        let board = Board(title: "Due Date Board")
        try await repository.createBoard(board)

        let column = Column(board: board.id, title: "Due Date Column", index: 0)
        try await repository.createColumn(column)

        let dueDate = Date(timeIntervalSince1970: 1609459200) // 2021-01-01 00:00:00 UTC
        let card = Card(
            column: column.id,
            title: "Card with Due Date",
            due: dueDate,
            sortKey: 0
        )
        try await repository.createCard(card)

        // Export to JSON and restore
        let exporter = BackupExporter(boardsRepository: repository)
        let jsonData = try await exporter.exportToData()

        let newRepository = InMemoryBoardsRepository()
        let restorer = BackupRestorer(boardsRepository: newRepository)
        try await restorer.restoreFromData(jsonData, mode: .merge)

        // Verify due date is preserved
        let restoredCards = try await newRepository.loadCards(for: column.id)
        XCTAssertEqual(restoredCards.count, 1)
        XCTAssertNotNil(restoredCards[0].due)

        // Allow small delta for floating point comparison
        let timeDelta = abs(restoredCards[0].due!.timeIntervalSince1970 - dueDate.timeIntervalSince1970)
        XCTAssertLessThan(timeDelta, 1.0)
    }

    // MARK: - Error Handling Tests

    func testRestoreRejectsUnsupportedVersion() async throws {
        let invalidBackup = BackupExport(
            version: 999,
            exportedAt: Date(),
            boards: [],
            lists: [],
            recipes: []
        )

        let restorer = BackupRestorer(boardsRepository: repository)

        do {
            _ = try await restorer.restore(invalidBackup, mode: .merge)
            XCTFail("Should have thrown unsupportedVersion error")
        } catch let error as BackupError {
            switch error {
            case .unsupportedVersion(let version):
                XCTAssertEqual(version, 999)
            default:
                XCTFail("Wrong error type")
            }
        }
    }
}
