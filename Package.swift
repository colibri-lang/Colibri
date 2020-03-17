// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "Colibri",
  products: [
    .executable(name: "colibri", targets: ["colibri"]),
  ],
  dependencies: [],
  targets: [
    .target(name: "colibri", dependencies: []),
    .target(name: "ColibriLib", dependencies: ["Sema"]),
    .target(name: "AST", dependencies: []),
    .target(name: "Parser", dependencies: ["AST"]),
    .target(name: "Sema", dependencies: ["AST"]),

    .target(name: "AssertThat", dependencies: []),
    .target(name: "Utils", dependencies: []),

    .testTarget(name: "ParserTests", dependencies: ["AssertThat", "Parser"]),
  ]
)
