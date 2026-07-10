// swift-tools-version: 6.2
import PackageDescription

let concurrencyBaseline: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .defaultIsolation(nil),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
    name: "AppServices",
    platforms: [ .iOS(.v17) ],
    products: [ .library(name: "AnvyxServiceKit", targets: ["AnvyxServiceKit"]) ],
    targets: [
        .target(name: "AnvyxServiceKit", swiftSettings: concurrencyBaseline),
        .testTarget(name: "AnvyxServiceKitTests", dependencies: ["AnvyxServiceKit"], swiftSettings: concurrencyBaseline),
    ]
)
