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
        .library(
            name: "CoreAnalytics",
            targets: ["CoreAnalytics"]),
        .library(
            name: "CoreUI",
            targets: ["CoreUI"]),
        .library(
            name: "CoreNetwork",
            targets: ["CoreNetwork"]),
        .library(
            name: "CoreStorage",
            targets: ["CoreStorage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", exact: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI"),
                "CoreUI"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "CoreAnalytics",
            dependencies: []
        ),
        .target(
            name: "CoreUI",
            dependencies: []
        ),
        .target(
            name: "CoreNetwork",
            dependencies: []
        ),
        .target(
            name: "CoreStorage",
            dependencies: []
        ),
    ]
)
