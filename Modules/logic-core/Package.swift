// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
let package = Package(
  name: "logic-core",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "logic-core",
      targets: ["logic-core"])
  ],
  dependencies: [
    .package(url: "https://github.com/jeroendk/eudi-lib-ios-iso18013-security.git", exact: "0.31.3001"),
    .package(url: "https://github.com/jeroendk/eudi-lib-ios-wallet-kit.git", exact: "0.62.2001"),
    .package(url: "https://github.com/apple/swift-certificates.git", from: "1.21.0"),
    .package(
      name: "logic-resources",
      path: "./logic-resources"
    ),
    .package(
      name: "logic-business",
      path: "./logic-business"
    ),
    .package(
      name: "logic-storage",
      path: "./logic-storage"
    ),
    .package(
      name: "logic-api",
      path: "./logic-api"
    ),
    .package(name: "logic-test", path: "./logic-test")
  ],
  targets: [
    .target(
      name: "logic-core",
      dependencies: [
        .product(name: "MdocSecurity18013", package: "eudi-lib-ios-iso18013-security"),
        .product(name: "X509", package: "swift-certificates"),
        "logic-resources",
        "logic-business",
        "logic-storage",
        "logic-api",
        .product(
          name: "EudiWalletKit",
          package: "eudi-lib-ios-wallet-kit"
        )
      ],
      path: "./Sources"
    ),
    .testTarget(
      name: "logic-core-tests",
      dependencies: [
        "logic-core",
        "logic-business",
        "logic-storage",
        "logic-api",
        "logic-test"
      ],
      path: "./Tests",
      resources: [.copy("Fixtures/GboLoTE")]
    )
  ]
)
