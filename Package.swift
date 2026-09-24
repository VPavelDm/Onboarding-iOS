// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "onboarding-ios",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17), .macOS(.v14)
    ],
    products: [
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
            name: "PaywallsAdapty",
            targets: ["PaywallsAdapty"]),
        .library(
            name: "PaywallsRC",
            targets: ["PaywallsRC"]),
        .library(
            name: "Profile",
            targets: ["Profile"]),
        .library(
            name: "GPTApi",
            targets: ["GPTApi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", exact: "1.1.0"),
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", from: "3.17.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.0.0"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI", condition: .when(platforms: [.iOS, .macOS])),
                "CoreUI",
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: ["Onboarding"]
        ),
        .target(
            name: "CoreAnalytics",
            dependencies: []
        ),
        .target(
            name: "CoreUI",
            dependencies: [
            ],
            resources: [
                .process("Resources")
            ]
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
                "CoreUI",
                "CoreAnalytics"
            ]
        ),
        .testTarget(
            name: "PaywallsTests",
            dependencies: ["Paywalls"]
        ),
        .target(
            name: "PaywallsRC",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
                "Paywalls"
            ]
        ),
        .target(
            name: "PaywallsAdapty",
            dependencies: [
                .product(name: "Adapty", package: "AdaptySDK-iOS"),
                .product(name: "AdaptyUI", package: "AdaptySDK-iOS"),
                "Paywalls",
                "CoreUI",
                "CoreAnalytics"
            ]
        ),
        .target(
            name: "Profile",
            dependencies: [
                "CoreUI"
            ],
            resources: [
                .process("Resources")
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
