// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "UIntX",
    products: [
        .library(
            name: "UIntX",
            targets: ["UIntX"]
        ),
    ],
    targets: [
        .target(
            name: "UIntX",
            dependencies: []
        ),
        .testTarget(
            name: "UIntXTests",
            dependencies: ["UIntX"]
        ),
    ]
)
