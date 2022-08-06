// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-configuration-parser",
    products: [
        .library(
            name: "ConfigurationParser",
            targets: ["ConfigurationParser"]
        )
    ],
    targets: [
        .target(
            name: "ConfigurationParser",
            dependencies: []
        ),
        .testTarget(
            name: "ConfigurationParserTests",
            dependencies: ["ConfigurationParser"]
        )
    ]
)
