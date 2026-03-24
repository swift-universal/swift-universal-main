// swift-tools-version:6.2
import Foundation
import PackageDescription

// MARK: - Package Declaration

let package = Package(
  name: "SwiftUniversalMain",
  platforms: [
    .iOS(.v15),
    .macOS(.v11),
    .macCatalyst(.v13),
    .tvOS(.v16),
    .visionOS(.v1),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "SwiftUniversalMain", targets: ["SwiftUniversalMain"])
  ],
  targets: [
    .target(
      name: "SwiftUniversalMain",
      path: "Sources/SwiftUniversalMain",
      swiftSettings: Package.Inject.shared.swiftSettings,
    ),
    .testTarget(
      name: "SwiftUniversalMainTests",
      dependencies: ["SwiftUniversalMain"],
      path: "Tests/SwiftUniversalMainTests",
      resources: [
        .process("resources"),
      ],
      swiftSettings: Package.Inject.shared.swiftSettings,
    ),
  ],
)

// MARK: - Package Service

if ProcessInfo.processInfo.environment["DEBUG_PACKAGE_INJECT"] == "1" {
  print("---- Package Inject Deps: Begin ----")
  print("Use Local Deps? \(ProcessInfo.useLocalDeps)")
  print(Package.Inject.shared.dependencies.map(\.kind))
  print("---- Package Inject Deps: End ----")
}

extension Package {
  @MainActor
  public struct Inject {
    public static let version = "3.0.0"

    public var swiftSettings: [SwiftSetting] = []
    var dependencies: [PackageDescription.Package.Dependency] = []

    public static let shared: Inject = ProcessInfo.useLocalDeps ? .local : .remote

    static var local: Inject = .init(swiftSettings: [.local])
    static var remote: Inject = .init()
  }
}

// MARK: - PackageDescription extensions

extension SwiftSetting {
  public static let local: SwiftSetting = .unsafeFlags([
    "-Xfrontend",
    "-warn-long-expression-type-checking=10",
  ])
}

// MARK: - Foundation extensions

extension ProcessInfo {
  public static var useLocalDeps: Bool {
    guard let raw = ProcessInfo.processInfo.environment["SPM_USE_LOCAL_DEPS"] else { return true }
    let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    return normalized == "1" || normalized == "true" || normalized == "yes" || normalized == "on"
  }
}

// PACKAGE_SERVICE_END_V0_0_1
