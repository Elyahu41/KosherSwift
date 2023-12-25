// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KosherSwift",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "KosherSwift",
            targets: [
		.target(
			name:"KosherSwift",
			path:"KosherSwift")]
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "KosherSwift"),
        .testTarget(
            name: "KosherSwiftTests",
            dependencies: ["KosherSwift"]),
    ]
)
