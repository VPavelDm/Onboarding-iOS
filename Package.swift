// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "onboarding-ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(url: "https://github.com/VPavelDm/SwiftExtensions", branch: "main"),
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", exact: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "CoreUI", package: "SwiftExtensions"),
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI")
            ],
            resources: [
                .process("Resources")
            ]
        ),


    ]
)
