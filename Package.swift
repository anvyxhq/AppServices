// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppServices",
    platforms: [ .iOS(.v17) ],
    products: [ .library(name: "AnvyxServiceKit", targets: ["AnvyxServiceKit"]) ],
    targets: [
        .target(name: "AnvyxServiceKit"),
        .testTarget(name: "AnvyxServiceKitTests", dependencies: ["AnvyxServiceKit"]),
    ]
)
