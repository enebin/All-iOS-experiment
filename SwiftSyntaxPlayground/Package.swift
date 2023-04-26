// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftSyntaxPlayground",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftSyntaxPlayground",
            targets: ["SwiftSyntaxPlayground"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax", .upToNextMajor(from: "508.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftSyntaxPlayground",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ]),
        .testTarget(
            name: "SwiftSyntaxPlaygroundTests",
            dependencies: ["SwiftSyntaxPlayground"])
    ]
)
