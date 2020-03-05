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
    .target(name: "AST", dependencies: ["Utils"]),
    .target(name: "Parser", dependencies: ["AST", "Utils"]),
    .target(name: "Sema", dependencies: ["AST"]),

    .target(name: "Utils", dependencies: []),
  ]
)
