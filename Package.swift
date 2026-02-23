// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ContactFieldKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ContactFieldKit",
            targets: ["ContactFieldKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/BaptisteSansierra/NoFlyZone.git", from: "1.0.4")
        //.package(path: "/Users/bat/work/personal/Packages/NoFlyZone")
    ],
    targets: [
        .target(
            name: "ContactFieldKit",
            dependencies: [
                .product(name: "NoFlyZone", package: "noflyzone")
            ]
        ),

    ]
)
