// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HomeCooked",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "HomeCooked",
            targets: ["HomeCooked"]
        ),
    ],
    dependencies: [
        // No external dependencies - pure SwiftUI + SwiftData
    ],
    targets: [
        .target(
            name: "HomeCooked",
            dependencies: [],
            path: ".",
            exclude: [
                "Tests",
                "Tooling",
                "Package.swift",
            ],
            sources: [
                "App",
                "Persistence",
                "Features",
                "DesignSystem",
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags(["-warnings-as-errors"]),
            ]
        ),
        .testTarget(
            name: "HomeCookedTests",
            dependencies: ["HomeCooked"],
            path: "Tests",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableExperimentalFeature("StrictConcurrency"),
                .unsafeFlags(["-warnings-as-errors"]),
            ]
        ),
    ]
)
