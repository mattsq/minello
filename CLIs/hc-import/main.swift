// CLIs/hc-import/main.swift
// Trello import CLI tool

import Foundation
import ImportExport
import PersistenceGRDB

// MARK: - Command Line Parsing

struct CommandLineArgs {
    let trelloFile: String
    let databasePath: String
    let deduplicate: Bool

    static func parse() -> CommandLineArgs? {
        let args = CommandLine.arguments

        // Minimum: hc-import <file>
        guard args.count >= 2 else {
            return nil
        }

        let trelloFile = args[1]

        // Parse optional flags
        var databasePath = "homecooked.db" // default
        var deduplicate = true

        var i = 2
        while i < args.count {
            let arg = args[i]

            switch arg {
            case "--db":
                guard i + 1 < args.count else {
                    print("Error: --db requires a path argument")
                    return nil
                }
                databasePath = args[i + 1]
                i += 2

            case "--no-dedupe":
                deduplicate = false
                i += 1

            default:
                print("Warning: Unknown argument '\(arg)'")
                i += 1
            }
        }

        return CommandLineArgs(
            trelloFile: trelloFile,
            databasePath: databasePath,
            deduplicate: deduplicate
        )
    }
}

func printUsage() {
    print("""
    Usage: hc-import <trello.json> [OPTIONS]

    Import a Trello board export into HomeCooked.

    Arguments:
      <trello.json>    Path to Trello JSON export file

    Options:
      --db <path>      Database file path (default: homecooked.db)
      --no-dedupe      Disable duplicate detection

    Examples:
      hc-import board.json
      hc-import board.json --db /tmp/test.db
      hc-import board.json --db /tmp/test.db --no-dedupe
    """)
}

// MARK: - Main

func main() async -> Int32 {
    guard let args = CommandLineArgs.parse() else {
        printUsage()
        return 1
    }

    // Verify input file exists
    let fileURL = URL(fileURLWithPath: args.trelloFile)
    guard FileManager.default.fileExists(atPath: args.trelloFile) else {
        print("Error: File not found: \(args.trelloFile)")
        return 1
    }

    do {
        // Initialize GRDB repository
        print("Opening database: \(args.databasePath)")
        let repository = try GRDBBoardsRepository.onDisk(at: args.databasePath)

        // Create importer
        let importer = TrelloImporter(repository: repository)

        // Import file
        print("Importing: \(args.trelloFile)")
        if args.deduplicate {
            print("Deduplication: enabled")
        } else {
            print("Deduplication: disabled")
        }

        let result = try await importer.importFile(fileURL, deduplicate: args.deduplicate)

        // Print summary
        print("")
        print(result.summary)

        if result.skipped > 0 {
            print("\nNote: \(result.skipped) board(s) skipped (already exists)")
        }

        print("\nImport completed successfully!")
        return 0

    } catch let error as DecodingError {
        print("Error: Invalid Trello JSON format")
        print("Details: \(error)")
        return 1

    } catch {
        print("Error: \(error)")
        return 1
    }
}

// Entry point
let exitCode = await main()
exit(exitCode)
