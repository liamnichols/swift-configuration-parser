// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-configuration-parser-example",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "configure-me", targets: ["ConfigureMe"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.3"),
        .package(path: "../")
    ],
    targets: [
        .executableTarget(
            name: "ConfigureMe",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ConfigurationParser", package: "swift-configuration-parser")
            ]
        )
    ]
)
