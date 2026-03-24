@testable import SwiftUniversalMain
import Testing

private struct ExampleSemanticVersionable: SemanticVersionable {
  static let version = "0.1.0"
}

@Test("SemanticVersionable exposes a static version string")
func semanticVersionableExposesStaticVersionString() {
  #expect(ExampleSemanticVersionable.version == "0.1.0")
}
