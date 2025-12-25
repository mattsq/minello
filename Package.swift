// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HomeCooked",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        // Libraries
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "UseCases", targets: ["UseCases"]),
        .library(name: "PersistenceInterfaces", targets: ["PersistenceInterfaces"]),
        .library(name: "PersistenceGRDB", targets: ["PersistenceGRDB"]),
        .library(name: "ImportExport", targets: ["ImportExport"]),
        .library(name: "SyncInterfaces", targets: ["SyncInterfaces"]),
        .library(name: "SyncNoop", targets: ["SyncNoop"]),
        .library(name: "SyncCloudKit", targets: ["SyncCloudKit"]),

        // CLIs
        .executable(name: "hc-import", targets: ["hc-import"]),
        .executable(name: "hc-backup", targets: ["hc-backup"]),
        .executable(name: "hc-migrate", targets: ["hc-migrate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.0"),
    ],
    targets: [
        // Domain - Pure value types, IDs, validators (Linux)
        .target(
            name: "Domain",
            dependencies: [],
            path: "Packages/Domain"
        ),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"],
            path: "Tests/DomainTests"
        ),

        // UseCases - Reorder logic, search, list ops, markdown (Linux)
        .target(
            name: "UseCases",
            dependencies: ["Domain"],
            path: "Packages/UseCases"
        ),
        .testTarget(
            name: "UseCasesTests",
            dependencies: ["UseCases"],
            path: "Tests/UseCasesTests"
        ),

        // PersistenceInterfaces - Repository protocols + errors (Linux)
        .target(
            name: "PersistenceInterfaces",
            dependencies: ["Domain"],
            path: "Packages/PersistenceInterfaces"
        ),

        // PersistenceGRDB - SQLite/GRDB implementation (Linux + Apple)
        .target(
            name: "PersistenceGRDB",
            dependencies: [
                "Domain",
                "PersistenceInterfaces",
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Packages/PersistenceGRDB"
        ),
        .testTarget(
            name: "PersistenceGRDBTests",
            dependencies: ["PersistenceGRDB", "PersistenceInterfaces"],
            path: "Tests/PersistenceGRDBTests"
        ),

        // ImportExport - Trello importer; JSON backup/restore (Linux)
        .target(
            name: "ImportExport",
            dependencies: ["Domain", "PersistenceInterfaces"],
            path: "Packages/ImportExport"
        ),
        .testTarget(
            name: "ImportExportTests",
            dependencies: ["ImportExport"],
            path: "Tests/ImportExportTests"
        ),

        // SyncInterfaces - Sync protocol only (Linux)
        .target(
            name: "SyncInterfaces",
            dependencies: ["Domain"],
            path: "Packages/SyncInterfaces"
        ),

        // SyncNoop - No-op sync client (Linux)
        .target(
            name: "SyncNoop",
            dependencies: ["SyncInterfaces"],
            path: "Packages/SyncNoop"
        ),

        // SyncCloudKit - CloudKit sync implementation (Apple only)
        .target(
            name: "SyncCloudKit",
            dependencies: ["Domain", "SyncInterfaces", "PersistenceInterfaces"],
            path: "Packages/SyncCloudKit"
        ),
        .testTarget(
            name: "SyncCloudKitTests",
            dependencies: ["SyncCloudKit", "SyncNoop"],
            path: "Tests/SyncCloudKitTests"
        ),

        // CLIs
        .executableTarget(
            name: "hc-import",
            dependencies: ["ImportExport", "PersistenceGRDB"],
            path: "CLIs/hc-import"
        ),
        .executableTarget(
            name: "hc-backup",
            dependencies: ["ImportExport", "PersistenceGRDB"],
            path: "CLIs/hc-backup"
        ),
        .executableTarget(
            name: "hc-migrate",
            dependencies: ["PersistenceGRDB"],
            path: "CLIs/hc-migrate"
        ),
    ]
)
