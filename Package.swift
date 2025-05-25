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
        .library(
            name: "Paywalls",
            targets: ["Paywalls"]),
        .library(
            name: "Profile",
            targets: ["Profile"]),
        .library(
            name: "GPTApi",
            targets: ["GPTApi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", exact: "1.1.0"),
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", from: "3.5.0")
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
        .target(
            name: "Paywalls",
            dependencies: [
                .product(name: "Adapty", package: "AdaptySDK-iOS"),
                .product(name: "AdaptyUI", package: "AdaptySDK-iOS"),
                "CoreUI"
            ]
        ),
        .target(
            name: "Profile",
            dependencies: [
                "CoreUI"
            ]
        ),
        .target(
            name: "GPTApi",
            dependencies: [
                "CoreNetwork"
            ]
        ),
    ]
)
