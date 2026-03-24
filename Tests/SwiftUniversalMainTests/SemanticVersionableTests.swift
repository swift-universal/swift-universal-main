@testable import SwiftUniversalMain
import Testing

private struct ExampleSemanticVersionable: SemanticVersionable {
  static let semanticVersion = "0.1.0"
}

@Test("SemanticVersionable exposes a static version string")
func semanticVersionableExposesStaticVersionString() {
  #expect(ExampleSemanticVersionable.semanticVersion == "0.1.0")
}
