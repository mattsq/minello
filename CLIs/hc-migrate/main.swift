// CLIs/hc-migrate/main.swift
// Database migration CLI tool

import Foundation
import GRDB
import PersistenceGRDB

/// CLI tool for managing database migrations
struct HCMigrate {
    enum Command: String {
        case list
        case migrate
        case dryRun = "dry-run"
    }

    static func main() {
        let args = CommandLine.arguments

        // Parse arguments
        var command: Command = .list
        var dbPath: String?
        var showHelp = false

        var i = 1
        while i < args.count {
            let arg = args[i]

            switch arg {
            case "--help", "-h":
                showHelp = true
            case "--db":
                i += 1
                if i < args.count {
                    dbPath = args[i]
                }
            case "--dry-run":
                command = .dryRun
            case "list":
                command = .list
            case "migrate":
                command = .migrate
            default:
                // Assume it's a database path if not preceded by --db
                if dbPath == nil && !arg.hasPrefix("-") {
                    dbPath = arg
                }
            }
            i += 1
        }

        if showHelp {
            printHelp()
            return
        }

        // Default to :memory: if no path specified
        let effectivePath = dbPath ?? ":memory:"

        do {
            switch command {
            case .list:
                try listMigrations(dbPath: effectivePath)
            case .migrate:
                try runMigrations(dbPath: effectivePath)
            case .dryRun:
                try dryRun(dbPath: effectivePath)
            }
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }

    static func printHelp() {
        print("""
        hc-migrate - HomeCooked database migration tool

        USAGE:
            hc-migrate [command] [options]

        COMMANDS:
            list        List all migrations and their status (default)
            migrate     Run pending migrations
            dry-run     Show which migrations would be applied without running them

        OPTIONS:
            --db <path>    Path to database file (default: :memory:)
            --dry-run      Show pending migrations without applying
            -h, --help     Show this help message

        EXAMPLES:
            hc-migrate --db homecooked.db
            hc-migrate migrate --db homecooked.db
            hc-migrate --dry-run --db homecooked.db
        """)
    }

    static func listMigrations(dbPath: String) throws {
        let dbQueue = try DatabaseQueue(path: dbPath)
        let migrator = HomeCookedMigrator.makeMigrator()

        let appliedMigrations = try dbQueue.read { db in
            try migrator.appliedMigrations(db)
        }

        print("Applied migrations:")
        if appliedMigrations.isEmpty {
            print("  (none)")
        } else {
            for migration in appliedMigrations {
                print("  ✓ \(migration)")
            }
        }

        let completedMigrations = try dbQueue.read { db in
            try migrator.completedMigrations(db)
        }

        let pending = Set(migrator.migrations)
            .subtracting(completedMigrations)

        if !pending.isEmpty {
            print("\nPending migrations:")
            for migration in pending {
                print("  • \(migration)")
            }
        }
    }

    static func runMigrations(dbPath: String) throws {
        let dbQueue = try DatabaseQueue(path: dbPath)
        let migrator = HomeCookedMigrator.makeMigrator()

        print("Running migrations on: \(dbPath)")

        let appliedBefore = try dbQueue.read { db in
            try migrator.appliedMigrations(db)
        }

        try migrator.migrate(dbQueue)

        let appliedAfter = try dbQueue.read { db in
            try migrator.appliedMigrations(db)
        }

        let newMigrations = Set(appliedAfter).subtracting(appliedBefore)

        if newMigrations.isEmpty {
            print("Database is already up to date.")
        } else {
            print("Applied migrations:")
            for migration in newMigrations {
                print("  ✓ \(migration)")
            }
        }
    }

    static func dryRun(dbPath: String) throws {
        let dbQueue = try DatabaseQueue(path: dbPath)
        let migrator = HomeCookedMigrator.makeMigrator()

        let completed = try dbQueue.read { db in
            try migrator.completedMigrations(db)
        }

        let pending = migrator.migrations
            .filter { !completed.contains($0) }

        print("Dry run for: \(dbPath)")
        print("\nMigrations that would be applied:")
        if pending.isEmpty {
            print("  (none - database is up to date)")
        } else {
            for migration in pending {
                print("  • \(migration)")
            }
        }
    }
}

// Run the CLI
HCMigrate.main()
