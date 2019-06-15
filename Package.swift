// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TypedNotificationCenter",
    products: [
        .library(
            name: "TypedNotificationCenter",
            targets: ["TypedNotificationCenter"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TypedNotificationCenter",
            dependencies: []),
        .testTarget(
            name: "TypedNotificationCenterTests",
            dependencies: ["TypedNotificationCenter"]),
    ]
)
