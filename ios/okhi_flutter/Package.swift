// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "okhi_flutter",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "okhi-flutter", targets: ["okhi_flutter"])
    ],
    dependencies: [
        .package(url: "https://github.com/OkHi/ios-okhi.git", exact: "1.10.19")
    ],
    targets: [
        .target(
            name: "okhi_flutter",
            dependencies: [
                .product(name: "OkHi", package: "ios-okhi")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
