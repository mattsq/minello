// PersistenceGRDB/Sources/PersistenceGRDB/Migrations.swift
// Database schema migrations

import Foundation
import GRDB

/// Database migrator for HomeCooked schema
public struct HomeCookedMigrator {
    /// Creates and configures the database migrator
    /// - Returns: Configured DatabaseMigrator
    public static func makeMigrator() -> DatabaseMigrator {
        var migrator = DatabaseMigrator()

        // Migration v1: Initial schema with boards, columns, and cards
        migrator.registerMigration("v1_initial_schema") { db in
            // Enable foreign key support
            try db.execute(sql: "PRAGMA foreign_keys = ON")

            // Create boards table
            try db.create(table: "boards") { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("columns", .text).notNull() // JSON array of column IDs
                t.column("created_at", .text).notNull() // ISO8601
                t.column("updated_at", .text).notNull() // ISO8601
            }

            // Create index on boards.created_at for sorting
            try db.create(index: "idx_boards_created_at", on: "boards", columns: ["created_at"])

            // Create columns table
            try db.create(table: "columns") { t in
                t.column("id", .text).primaryKey()
                t.column("board_id", .text).notNull()
                    .references("boards", column: "id", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("index", .integer).notNull()
                t.column("cards", .text).notNull() // JSON array of card IDs
                t.column("created_at", .text).notNull() // ISO8601
                t.column("updated_at", .text).notNull() // ISO8601
            }

            // Create indices on columns
            try db.create(index: "idx_columns_board_id", on: "columns", columns: ["board_id"])
            try db.create(index: "idx_columns_board_index", on: "columns", columns: ["board_id", "index"])

            // Create cards table
            try db.create(table: "cards") { t in
                t.column("id", .text).primaryKey()
                t.column("column_id", .text).notNull()
                    .references("columns", column: "id", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("details", .text).notNull()
                t.column("due", .text) // ISO8601, nullable
                t.column("tags", .text).notNull() // JSON array
                t.column("checklist", .text).notNull() // JSON array of ChecklistItem
                t.column("sort_key", .double).notNull()
                t.column("created_at", .text).notNull() // ISO8601
                t.column("updated_at", .text).notNull() // ISO8601
            }

            // Create indices on cards
            try db.create(index: "idx_cards_column_id", on: "cards", columns: ["column_id"])
            try db.create(index: "idx_cards_column_sort", on: "cards", columns: ["column_id", "sort_key"])
            try db.create(index: "idx_cards_due", on: "cards", columns: ["due"])

            // Create full-text search table for cards with porter tokenizer for stemming
            // This allows "grocery" to match "groceries", etc.
            try db.create(virtualTable: "cards_fts", using: FTS5()) { t in
                t.tokenizer = .porter()
                t.column("title")
                t.column("details")
            }

            // Trigger to keep FTS index in sync with cards table
            try db.execute(sql: """
                CREATE TRIGGER cards_fts_insert AFTER INSERT ON cards BEGIN
                    INSERT INTO cards_fts(rowid, title, details)
                    VALUES (new.rowid, new.title, new.details);
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER cards_fts_update AFTER UPDATE ON cards BEGIN
                    UPDATE cards_fts SET title = new.title, details = new.details
                    WHERE rowid = new.rowid;
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER cards_fts_delete AFTER DELETE ON cards BEGIN
                    DELETE FROM cards_fts WHERE rowid = old.rowid;
                END;
                """)
        }

        // Migration v2: Add personal_lists table
        migrator.registerMigration("v2_personal_lists") { db in
            // Create personal_lists table
            try db.create(table: "personal_lists") { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("items", .text).notNull() // JSON array of ChecklistItem
                t.column("created_at", .text).notNull() // ISO8601
                t.column("updated_at", .text).notNull() // ISO8601
            }

            // Create index on personal_lists.created_at for sorting
            try db.create(index: "idx_lists_created_at", on: "personal_lists", columns: ["created_at"])

            // Create full-text search table for personal_lists with porter tokenizer for stemming
            try db.create(virtualTable: "personal_lists_fts", using: FTS5()) { t in
                t.tokenizer = .porter()
                t.column("title")
            }

            // Trigger to keep FTS index in sync with personal_lists table
            try db.execute(sql: """
                CREATE TRIGGER personal_lists_fts_insert AFTER INSERT ON personal_lists BEGIN
                    INSERT INTO personal_lists_fts(rowid, title)
                    VALUES (new.rowid, new.title);
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER personal_lists_fts_update AFTER UPDATE ON personal_lists BEGIN
                    UPDATE personal_lists_fts SET title = new.title
                    WHERE rowid = new.rowid;
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER personal_lists_fts_delete AFTER DELETE ON personal_lists BEGIN
                    DELETE FROM personal_lists_fts WHERE rowid = old.rowid;
                END;
                """)
        }

        // Migration v3: Update FTS tables to use porter tokenizer for stemming
        migrator.registerMigration("v3_fts_porter_tokenizer") { db in
            // Drop existing cards FTS table and triggers
            try db.execute(sql: "DROP TRIGGER IF EXISTS cards_fts_insert")
            try db.execute(sql: "DROP TRIGGER IF EXISTS cards_fts_update")
            try db.execute(sql: "DROP TRIGGER IF EXISTS cards_fts_delete")
            try db.execute(sql: "DROP TABLE IF EXISTS cards_fts")

            // Recreate cards FTS table with porter tokenizer
            try db.create(virtualTable: "cards_fts", using: FTS5()) { t in
                t.tokenizer = .porter()
                t.column("title")
                t.column("details")
            }

            // Recreate triggers
            try db.execute(sql: """
                CREATE TRIGGER cards_fts_insert AFTER INSERT ON cards BEGIN
                    INSERT INTO cards_fts(rowid, title, details)
                    VALUES (new.rowid, new.title, new.details);
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER cards_fts_update AFTER UPDATE ON cards BEGIN
                    UPDATE cards_fts SET title = new.title, details = new.details
                    WHERE rowid = new.rowid;
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER cards_fts_delete AFTER DELETE ON cards BEGIN
                    DELETE FROM cards_fts WHERE rowid = old.rowid;
                END;
                """)

            // Repopulate FTS table from existing cards
            try db.execute(sql: """
                INSERT INTO cards_fts(rowid, title, details)
                SELECT rowid, title, details FROM cards
                """)

            // Drop existing personal_lists FTS table and triggers
            try db.execute(sql: "DROP TRIGGER IF EXISTS personal_lists_fts_insert")
            try db.execute(sql: "DROP TRIGGER IF EXISTS personal_lists_fts_update")
            try db.execute(sql: "DROP TRIGGER IF EXISTS personal_lists_fts_delete")
            try db.execute(sql: "DROP TABLE IF EXISTS personal_lists_fts")

            // Recreate personal_lists FTS table with porter tokenizer
            try db.create(virtualTable: "personal_lists_fts", using: FTS5()) { t in
                t.tokenizer = .porter()
                t.column("title")
            }

            // Recreate triggers
            try db.execute(sql: """
                CREATE TRIGGER personal_lists_fts_insert AFTER INSERT ON personal_lists BEGIN
                    INSERT INTO personal_lists_fts(rowid, title)
                    VALUES (new.rowid, new.title);
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER personal_lists_fts_update AFTER UPDATE ON personal_lists BEGIN
                    UPDATE personal_lists_fts SET title = new.title
                    WHERE rowid = new.rowid;
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER personal_lists_fts_delete AFTER DELETE ON personal_lists BEGIN
                    DELETE FROM personal_lists_fts WHERE rowid = old.rowid;
                END;
                """)

            // Repopulate FTS table from existing lists
            try db.execute(sql: """
                INSERT INTO personal_lists_fts(rowid, title)
                SELECT rowid, title FROM personal_lists
                """)
        }

        return migrator
    }
}
