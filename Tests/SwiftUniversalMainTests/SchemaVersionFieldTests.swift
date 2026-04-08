@testable import SwiftUniversalMain
import Foundation
import Testing

private enum ExampleV010Tag: SchemaVersionTag {
  static let expected = "v0.1.0"
}

private enum ExampleV020Tag: SchemaVersionTag {
  static let expected = "v0.2.0"
}

private struct ExampleStrictModel: Codable, Equatable {
  var schemaVersion: SchemaVersionField<ExampleV010Tag> = .init()
  var name: String
}

@Suite("SchemaVersionField")
struct SchemaVersionFieldTests {
  @Test("roundtrip preserves the exact wire version")
  func roundtrip() throws {
    let original = ExampleStrictModel(name: "alpha")
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(ExampleStrictModel.self, from: data)
    #expect(decoded == original)
    #expect(decoded.schemaVersion.value == "v0.1.0")
  }

  @Test("strict accept of the canonical wire string")
  func strictAccept() throws {
    let json = #"{"schemaVersion":"v0.1.0","name":"alpha"}"#
    let decoded = try JSONDecoder().decode(
      ExampleStrictModel.self,
      from: Data(json.utf8)
    )
    #expect(decoded.schemaVersion.value == "v0.1.0")
    #expect(decoded.name == "alpha")
  }

  @Test("strict reject of a neighboring wire version")
  func strictReject() {
    let json = #"{"schemaVersion":"v0.2.0","name":"alpha"}"#
    #expect(throws: DecodingError.self) {
      _ = try JSONDecoder().decode(
        ExampleStrictModel.self,
        from: Data(json.utf8)
      )
    }
  }

  @Test("equatable and hashable derive without stored payload")
  func equatableHashable() {
    let a = SchemaVersionField<ExampleV010Tag>()
    let b = SchemaVersionField<ExampleV010Tag>()
    #expect(a == b)
    var hasher1 = Hasher()
    a.hash(into: &hasher1)
    var hasher2 = Hasher()
    b.hash(into: &hasher2)
    #expect(hasher1.finalize() == hasher2.finalize())
  }

  @Test("encoded form is the bare wire string")
  func encodedFormIsBareString() throws {
    let field = SchemaVersionField<ExampleV020Tag>()
    let data = try JSONEncoder().encode(field)
    let asString = String(data: data, encoding: .utf8)
    #expect(asString == "\"v0.2.0\"")
  }
}
