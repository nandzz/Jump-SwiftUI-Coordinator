// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Jump",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Jump",
            targets: ["Jump"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Jump",
            dependencies: []),
        .target(
            name: "Mocks",
            dependencies: [ "Jump"],
            path: "./Tests/Mocks"
        ),
        .testTarget(
            name: "JumpTests",
            dependencies: ["Jump", "Mocks"]),
    ]
)
