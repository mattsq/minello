// CLIs/hc-backup/main.swift
// Backup/restore CLI for HomeCooked data

import Foundation
import ImportExport
import PersistenceGRDB

// MARK: - CLI Implementation

struct CLI {
    static func run() async {
        let args = Array(CommandLine.arguments.dropFirst())

        guard args.count >= 1 else {
            printUsage()
            exit(1)
        }

        let command = args[0]

        switch command {
        case "export":
            await handleExport(args: Array(args.dropFirst()))
        case "restore":
            await handleRestore(args: Array(args.dropFirst()))
        case "help", "--help", "-h":
            printUsage()
            exit(0)
        default:
            print("Error: Unknown command '\(command)'")
            printUsage()
            exit(1)
        }
    }

    private static func handleExport(args: [String]) async {
        var dbPath: String?
        var outputPath: String?
        var compact = false

        var i = 0
        while i < args.count {
            switch args[i] {
            case "--db":
                guard i + 1 < args.count else {
                    print("Error: --db requires a path")
                    exit(1)
                }
                dbPath = args[i + 1]
                i += 2
            case "--output", "-o":
                guard i + 1 < args.count else {
                    print("Error: --output requires a path")
                    exit(1)
                }
                outputPath = args[i + 1]
                i += 2
            case "--compact":
                compact = true
                i += 1
            default:
                print("Error: Unknown option '\(args[i])'")
                exit(1)
            }
        }

        guard let dbPath = dbPath else {
            print("Error: --db is required")
            printUsage()
            exit(1)
        }

        guard let outputPath = outputPath else {
            print("Error: --output is required")
            printUsage()
            exit(1)
        }

        do {
            print("Exporting from \(dbPath)...")

            let repository = try GRDBBoardsRepository.onDisk(at: dbPath)
            let exporter = BackupExporter(boardsRepository: repository)

            let outputURL = URL(fileURLWithPath: outputPath)
            let result = try await exporter.exportToFile(outputURL, pretty: !compact)

            print("✓ Export complete!")
            print(result.summary)
        } catch {
            print("Error: Export failed: \(error)")
            exit(1)
        }
    }

    private static func handleRestore(args: [String]) async {
        var dbPath: String?
        var inputPath: String?
        var mode: RestoreMode = .merge

        var i = 0
        while i < args.count {
            switch args[i] {
            case "--db":
                guard i + 1 < args.count else {
                    print("Error: --db requires a path")
                    exit(1)
                }
                dbPath = args[i + 1]
                i += 2
            case "--input", "-i":
                guard i + 1 < args.count else {
                    print("Error: --input requires a path")
                    exit(1)
                }
                inputPath = args[i + 1]
                i += 2
            case "--mode":
                guard i + 1 < args.count else {
                    print("Error: --mode requires 'merge' or 'overwrite'")
                    exit(1)
                }
                switch args[i + 1] {
                case "merge":
                    mode = .merge
                case "overwrite":
                    mode = .overwrite
                default:
                    print("Error: --mode must be 'merge' or 'overwrite'")
                    exit(1)
                }
                i += 2
            default:
                print("Error: Unknown option '\(args[i])'")
                exit(1)
            }
        }

        guard let dbPath = dbPath else {
            print("Error: --db is required")
            printUsage()
            exit(1)
        }

        guard let inputPath = inputPath else {
            print("Error: --input is required")
            printUsage()
            exit(1)
        }

        do {
            print("Restoring to \(dbPath) (mode: \(mode))...")

            let repository = try GRDBBoardsRepository.onDisk(at: dbPath)
            let restorer = BackupRestorer(boardsRepository: repository)

            let inputURL = URL(fileURLWithPath: inputPath)
            let result = try await restorer.restoreFromFile(inputURL, mode: mode)

            print("✓ Restore complete!")
            print(result.summary)
        } catch {
            print("Error: Restore failed: \(error)")
            exit(1)
        }
    }

    private static func printUsage() {
        print("""
        hc-backup - Backup and restore HomeCooked data

        USAGE:
            hc-backup export --db <path> --output <path> [--compact]
            hc-backup restore --db <path> --input <path> [--mode <merge|overwrite>]

        COMMANDS:
            export      Export data to JSON backup file
            restore     Restore data from JSON backup file

        OPTIONS (export):
            --db <path>         Path to SQLite database
            --output <path>     Path to output JSON file
            --compact           Minimize JSON output (default: pretty-printed)

        OPTIONS (restore):
            --db <path>         Path to SQLite database
            --input <path>      Path to input JSON file
            --mode <mode>       Restore mode: 'merge' (skip existing) or 'overwrite' (update existing)
                                Default: merge

        EXAMPLES:
            # Export database to backup file
            hc-backup export --db ./data.db --output ./backup.json

            # Restore from backup (merge mode - skip existing items)
            hc-backup restore --db ./data.db --input ./backup.json --mode merge

            # Restore from backup (overwrite mode - update existing items)
            hc-backup restore --db ./data.db --input ./backup.json --mode overwrite
        """)
    }
}

// MARK: - Main Entry Point

@main
struct Main {
    static func main() async {
        await CLI.run()
    }
}
