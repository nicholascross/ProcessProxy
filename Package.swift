// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProcessProxy",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "process-proxy", targets: ["ProcessProxy"]),
        .library(
            name: "ProcessProxyKit",
            targets: ["ProcessProxyKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0") // HTTP server
    ],
    targets: [
        .executableTarget(
            name: "ProcessProxy",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .target(name: "ProcessProxyKit")
            ]
        ),
        .target(
            name: "ProcessProxyKit",
            dependencies: []
        )
    ],
    swiftLanguageModes: [.v6]
)
