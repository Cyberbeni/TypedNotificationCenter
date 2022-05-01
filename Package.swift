// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "TypedNotificationCenter",
	platforms: [
		.macOS("10.9"),
		.iOS(.v8),
		.watchOS(.v2),
		.tvOS(.v9),
	],
	products: [
		.library(
			name: "TypedNotificationCenter",
			targets: ["TypedNotificationCenter"]
		),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "TypedNotificationCenter",
			dependencies: []
		),
		.testTarget(
			name: "TypedNotificationCenterTests",
			dependencies: ["TypedNotificationCenter"]
		),
		.testTarget(
			name: "TypedNotificationCenterPerformanceTests",
			dependencies: ["TypedNotificationCenter"]
		),
	]
)
