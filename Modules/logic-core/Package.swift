// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

guard let gboSecurity = ProcessInfo.processInfo.environment["GBO_SECURITY_PACKAGE_PATH"],
      let gboWalletKit = ProcessInfo.processInfo.environment["GBO_WALLET_KIT_PACKAGE_PATH"] else {
  fatalError("Set GBO_SECURITY_PACKAGE_PATH to the prepared GBO LoTE SDK; see GBO-LOCAL-PATCHES.md")
}

let package = Package(
  name: "logic-core",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "logic-core",
      targets: ["logic-core"])
  ],
  dependencies: [
    .package(path: gboSecurity),
    .package(path: gboWalletKit),
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
    )
  ],
  targets: [
    .target(
      name: "logic-core",
      dependencies: [
        .product(name: "MdocSecurity18013", package: "eudi-lib-ios-iso18013-security"),
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
    )
  ]
)
