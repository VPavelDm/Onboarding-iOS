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
            name: "Profile",
            targets: ["Profile"]),
        .library(
            name: "GPTApi",
            targets: ["GPTApi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI", exact: "1.1.0"),
        .package(url: "https://github.com/adaptyteam/AdaptySDK-iOS.git", from: "3.17.0"),
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        .package(url: "https://github.com/OpenSwiftUIProject/OpenCombine.git", from: "0.15.1"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                .product(name: "ConfettiSwiftUI", package: "ConfettiSwiftUI", condition: .when(platforms: [.iOS, .macOS])),
                "CoreUI",
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
                .product(name: "OpenCombine", package: "OpenCombine"),
                .product(name: "OpenCombineFoundation", package: "OpenCombine"),
            ],
            resources: [
                .process("Resources")
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]
        ),
        .target(
            name: "CoreAnalytics",
            dependencies: []
        ),
        .target(
            name: "CoreUI",
            dependencies: [
                .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
            ],
            resources: [
                .process("Resources")
            ],
            plugins: [.plugin(name: "skipstone", package: "skip")]
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
