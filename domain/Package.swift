// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "domain",
  platforms: [.macOS(.v11)],
  products: [
    .library(name: "domain",
             targets: ["domain"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", .exact("1.0.0")),
    .package(url: "https://github.com/johnsundell/collectionconcurrencykit", .exact("0.2.0")),
    .package(url: "https://github.com/Jounce/Surge", .exact("2.3.2")),
    .package(url: "https://github.com/Quick/Nimble", .exact("10.0.0")),
    .package(url: "https://github.com/pointfreeco/swift-custom-dump", .exact("0.5.2"))
  ],
  targets: [
    .target(name: "domain",
            dependencies: [.byName(name: "Surge"),
                           .product(name: "Algorithms", package: "swift-algorithms"),
                           .product(name: "CollectionConcurrencyKit", package: "collectionconcurrencykit"),
                           .product(name: "CustomDump", package: "swift-custom-dump")]),
    .testTarget(name: "domainTests",
                dependencies: ["domain", "Nimble"]),
  ]
)
