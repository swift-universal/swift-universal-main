@testable import SwiftUniversalMain
import Foundation
import Testing

private struct ExampleSemanticVersionable: SemanticVersionable {
  static let semanticVersion = "0.1.0"
  var schemaVersion: String { Self.semanticVersion }
}

private struct ExampleSchemaDocument: SemanticVersionable {
  static let semanticVersion = "0.1.0"

  private var storedSchemaVersion: String

  var schemaVersion: String { storedSchemaVersion }

  init(schemaVersion: String = Self.semanticVersion) {
    storedSchemaVersion = schemaVersion
  }
}

private struct ExampleCodingKeys: CodingKey {
  var stringValue: String
  var intValue: Int?

  init?(stringValue: String) {
    self.stringValue = stringValue
    intValue = nil
  }

  init?(intValue: Int) {
    self.stringValue = "\(intValue)"
    self.intValue = intValue
  }
}

@Test("SemanticVersionable exposes static and instance version strings")
func semanticVersionableExposesStaticAndInstanceVersionStrings() {
  #expect(ExampleSemanticVersionable.semanticVersion == "0.1.0")
  #expect(ExampleSemanticVersionable().schemaVersion == "0.1.0")
}

@Test("SemanticVersionable rejects mismatched schemaVersion assignments")
func semanticVersionableRejectsMismatchedSchemaVersionAssignments() throws {
  let document = ExampleSchemaDocument(schemaVersion: "0.1.0")
  #expect(document.schemaVersion == "0.1.0")

  #expect(throws: SchemaVersionAssignmentError.self) {
    _ = try ExampleSchemaDocument.validateAssignedSchemaVersion("2.0.0")
  }
}

@Test("SemanticVersionable decodes only the matching schemaVersion")
func semanticVersionableRejectsMismatchedDecodedSchemaVersion() throws {
  let mismatchedJSON = #"{"schemaVersion":"0.2.0"}"#
  let data = Data(mismatchedJSON.utf8)
  let decoder = JSONDecoder()

  struct Payload: Decodable, SemanticVersionable {
    static let semanticVersion = "0.1.0"
    let schemaVersion: String

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: ExampleCodingKeys.self)
      schemaVersion = try Self.decodeSchemaVersion(forKey: .init(stringValue: "schemaVersion")!, in: container)
    }
  }

  #expect(throws: DecodingError.self) {
    _ = try decoder.decode(Payload.self, from: data)
  }
}
