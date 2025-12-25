// SyncCloudKit/Sources/SyncCloudKit/CloudKitSyncClient.swift
// CloudKit implementation of SyncClient

#if canImport(CloudKit)
import CloudKit
import Domain
import Foundation
import PersistenceInterfaces
import SyncInterfaces

/// CloudKit sync client with private database support and LWW conflict resolution
public actor CloudKitSyncClient: SyncClient {
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let customZoneName = "HomeCookedZone"
    private var customZoneID: CKRecordZone.ID!
    private let conflictResolver = LWWConflictResolver()

    private var _status: SyncStatus = .idle
    private weak var statusObserver: SyncStatusObserver?

    // Repository dependencies
    private let boardsRepo: BoardsRepository
    private let listsRepo: ListsRepository
    private let recipesRepo: RecipesRepository

    /// Initialize the CloudKit sync client
    /// - Parameters:
    ///   - containerIdentifier: CloudKit container identifier (default: default container)
    ///   - boardsRepo: Repository for boards
    ///   - listsRepo: Repository for lists
    ///   - recipesRepo: Repository for recipes
    public init(
        containerIdentifier: String? = nil,
        boardsRepo: BoardsRepository,
        listsRepo: ListsRepository,
        recipesRepo: RecipesRepository
    ) {
        if let identifier = containerIdentifier {
            self.container = CKContainer(identifier: identifier)
        } else {
            self.container = CKContainer.default()
        }
        privateDatabase = container.privateCloudDatabase
        self.boardsRepo = boardsRepo
        self.listsRepo = listsRepo
        self.recipesRepo = recipesRepo

        // Create custom zone ID
        customZoneID = CKRecordZone.ID(zoneName: customZoneName, ownerName: CKCurrentUserDefaultName)
    }

    public var status: SyncStatus {
        get async { _status }
    }

    /// Set a status observer to receive status updates
    public func setStatusObserver(_ observer: SyncStatusObserver?) {
        statusObserver = observer
    }

    private func updateStatus(_ newStatus: SyncStatus) {
        _status = newStatus
        if let observer = statusObserver {
            observer.syncStatusDidChange(newStatus)
        }
    }

    // MARK: - Availability

    public func checkAvailability() async -> Bool {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                updateStatus(.idle)
                return true
            case .noAccount, .restricted:
                updateStatus(.unavailable)
                return false
            case .couldNotDetermine, .temporarilyUnavailable:
                updateStatus(.unavailable)
                return false
            @unknown default:
                updateStatus(.unavailable)
                return false
            }
        } catch {
            updateStatus(.unavailable)
            return false
        }
    }

    // MARK: - Zone Management

    private func ensureCustomZoneExists() async throws {
        let zone = CKRecordZone(zoneID: customZoneID)
        do {
            _ = try await privateDatabase.save(zone)
        } catch let error as CKError {
            // Zone already exists is OK
            if error.code != .serverRecordChanged && error.code != .zoneNotFound {
                throw error
            }
        }
    }

    // MARK: - Sync

    public func sync() async -> SyncResult {
        guard await checkAvailability() else {
            return .failure(error: "iCloud account not available")
        }

        updateStatus(.syncing)

        do {
            try await ensureCustomZoneExists()

            // Fetch changes from CloudKit
            let (boards, columns, cards, lists, recipes) = try await fetchAllRecords()

            // Apply changes to local database with conflict resolution
            let (uploadCount, downloadCount, conflictCount) = try await applyChanges(
                boards: boards,
                columns: columns,
                cards: cards,
                lists: lists,
                recipes: recipes
            )

            updateStatus(.success(syncedAt: Date()))
            return .success(
                uploadedCount: uploadCount,
                downloadedCount: downloadCount,
                conflictsResolved: conflictCount
            )
        } catch {
            let errorMessage = (error as? CKError)?.localizedDescription ?? error.localizedDescription
            updateStatus(.failed(error: errorMessage))
            return .failure(error: errorMessage)
        }
    }

    private func fetchAllRecords() async throws -> (
        boards: [Board],
        columns: [Column],
        cards: [Card],
        lists: [PersonalList],
        recipes: [Recipe]
    ) {
        var boards: [Board] = []
        var columns: [Column] = []
        var cards: [Card] = []
        var lists: [PersonalList] = []
        var recipes: [Recipe] = []

        // Fetch all record types
        let recordTypes = [
            CloudKitRecordMapper.boardRecordType,
            CloudKitRecordMapper.columnRecordType,
            CloudKitRecordMapper.cardRecordType,
            CloudKitRecordMapper.listRecordType,
            CloudKitRecordMapper.recipeRecordType,
        ]

        for recordType in recordTypes {
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            let results = try await privateDatabase.records(matching: query, inZoneWith: customZoneID)

            for (_, result) in results.matchResults {
                switch result {
                case let .success(record):
                    try processRecord(record, boards: &boards, columns: &columns, cards: &cards, lists: &lists, recipes: &recipes)
                case let .failure(error):
                    print("Failed to fetch record: \(error)")
                }
            }
        }

        return (boards, columns, cards, lists, recipes)
    }

    private func processRecord(
        _ record: CKRecord,
        boards: inout [Board],
        columns: inout [Column],
        cards: inout [Card],
        lists: inout [PersonalList],
        recipes: inout [Recipe]
    ) throws {
        switch record.recordType {
        case CloudKitRecordMapper.boardRecordType:
            boards.append(try CloudKitRecordMapper.board(from: record))
        case CloudKitRecordMapper.columnRecordType:
            columns.append(try CloudKitRecordMapper.column(from: record))
        case CloudKitRecordMapper.cardRecordType:
            cards.append(try CloudKitRecordMapper.card(from: record))
        case CloudKitRecordMapper.listRecordType:
            lists.append(try CloudKitRecordMapper.personalList(from: record))
        case CloudKitRecordMapper.recipeRecordType:
            recipes.append(try CloudKitRecordMapper.recipe(from: record))
        default:
            break
        }
    }

    private func applyChanges(
        boards: [Board],
        columns: [Column],
        cards: [Card],
        lists: [PersonalList],
        recipes: [Recipe]
    ) async throws -> (uploadCount: Int, downloadCount: Int, conflictCount: Int) {
        var uploadCount = 0
        var downloadCount = 0
        var conflictCount = 0

        // Load local data
        let localBoards = try await boardsRepo.loadBoards()
        let localLists = try await listsRepo.loadLists()
        let localRecipes = try await recipesRepo.loadRecipes()

        // Resolve conflicts for boards
        var boardsToSave: [Board] = []
        for remoteBoard in boards {
            if let localBoard = localBoards.first(where: { $0.id == remoteBoard.id }) {
                // Conflict - use LWW
                let conflict = SyncConflict.board(local: localBoard, remote: remoteBoard)
                let resolved = conflictResolver.resolve(conflict, strategy: .lastWriteWins) as! Board
                if resolved.updatedAt != localBoard.updatedAt {
                    boardsToSave.append(resolved)
                    conflictCount += 1
                }
            } else {
                // New remote board
                boardsToSave.append(remoteBoard)
                downloadCount += 1
            }
        }

        // Save resolved boards
        for board in boardsToSave {
            try await boardsRepo.createBoard(board)
        }

        // Upload local boards not in remote
        for localBoard in localBoards {
            if !boards.contains(where: { $0.id == localBoard.id }) {
                try await uploadBoard(localBoard)
                uploadCount += 1
            }
        }

        // Resolve conflicts for lists
        var listsToSave: [PersonalList] = []
        for remoteList in lists {
            if let localList = localLists.first(where: { $0.id == remoteList.id }) {
                let conflict = SyncConflict.list(local: localList, remote: remoteList)
                let resolved = conflictResolver.resolve(conflict, strategy: .lastWriteWins) as! PersonalList
                if resolved.updatedAt != localList.updatedAt {
                    listsToSave.append(resolved)
                    conflictCount += 1
                }
            } else {
                listsToSave.append(remoteList)
                downloadCount += 1
            }
        }

        for list in listsToSave {
            try await listsRepo.updateList(list)
        }

        // Upload local lists not in remote
        for localList in localLists {
            if !lists.contains(where: { $0.id == localList.id }) {
                try await uploadList(localList)
                uploadCount += 1
            }
        }

        // Resolve conflicts for recipes
        var recipesToSave: [Recipe] = []
        for remoteRecipe in recipes {
            if let localRecipe = localRecipes.first(where: { $0.id == remoteRecipe.id }) {
                let conflict = SyncConflict.recipe(local: localRecipe, remote: remoteRecipe)
                let resolved = conflictResolver.resolve(conflict, strategy: .lastWriteWins) as! Recipe
                if resolved.updatedAt != localRecipe.updatedAt {
                    recipesToSave.append(resolved)
                    conflictCount += 1
                }
            } else {
                recipesToSave.append(remoteRecipe)
                downloadCount += 1
            }
        }

        for recipe in recipesToSave {
            try await recipesRepo.updateRecipe(recipe)
        }

        // Upload local recipes not in remote
        for localRecipe in localRecipes {
            if !recipes.contains(where: { $0.id == localRecipe.id }) {
                try await uploadRecipe(localRecipe)
                uploadCount += 1
            }
        }

        // Save columns and cards
        if !columns.isEmpty {
            try await boardsRepo.saveColumns(columns)
            downloadCount += columns.count
        }
        if !cards.isEmpty {
            try await boardsRepo.saveCards(cards)
            downloadCount += cards.count
        }

        return (uploadCount, downloadCount, conflictCount)
    }

    // MARK: - Upload Operations

    public func uploadBoard(_ board: Board) async throws {
        let record = CloudKitRecordMapper.record(from: board, zoneID: customZoneID)
        _ = try await privateDatabase.save(record)
    }

    public func uploadList(_ list: PersonalList) async throws {
        let record = CloudKitRecordMapper.record(from: list, zoneID: customZoneID)
        _ = try await privateDatabase.save(record)
    }

    public func uploadRecipe(_ recipe: Recipe) async throws {
        let record = CloudKitRecordMapper.record(from: recipe, zoneID: customZoneID)
        _ = try await privateDatabase.save(record)
    }

    // MARK: - Delete Operations

    public func deleteBoard(_ boardID: BoardID) async throws {
        let recordID = CKRecord.ID(recordName: boardID.rawValue.uuidString, zoneID: customZoneID)
        _ = try await privateDatabase.deleteRecord(withID: recordID)
    }

    public func deleteList(_ listID: ListID) async throws {
        let recordID = CKRecord.ID(recordName: listID.rawValue.uuidString, zoneID: customZoneID)
        _ = try await privateDatabase.deleteRecord(withID: recordID)
    }

    public func deleteRecipe(_ recipeID: RecipeID) async throws {
        let recordID = CKRecord.ID(recordName: recipeID.rawValue.uuidString, zoneID: customZoneID)
        _ = try await privateDatabase.deleteRecord(withID: recordID)
    }
}
#endif
