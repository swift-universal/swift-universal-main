import Foundation
@testable import SwiftUniversalMain
import Testing

struct JSONValueTests {
  private var decoder: JSONDecoder {
    JSONDecoder()
  }

  private var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.sortedKeys]
    return encoder
  }

  @Test
  func decodeScalarCases() throws {
    #expect(try decodeFixture("json-value-null") == .null)
    #expect(try decodeFixture("json-value-number") == .number(3.25))
    #expect(try decodeFixture("json-value-string") == .string("hello"))
    #expect(try decodeFixture("json-value-bool") == .bool(true))
  }

  @Test
  func decodeNestedObjectAndArray() throws {
    let decoded = try decodeFixture("json-value-object")

    #expect(
      decoded == .object([
        "flags": .array([.bool(true), .null]),
        "meta": .object([
          "name": .string("clip"),
          "score": .number(3.25),
        ]),
      ]))
  }

  @Test
  func encodeScalarCases() throws {
    let nullFixture = try fixtureString("json-value-null")
    let numberFixture = try fixtureString("json-value-number")
    let stringFixture = try fixtureString("json-value-string")
    let boolFixture = try fixtureString("json-value-bool")

    #expect(try encode(.null) == nullFixture)
    #expect(try encode(.number(3.25)) == numberFixture)
    #expect(try encode(.string("hello")) == stringFixture)
    #expect(try encode(.bool(true)) == boolFixture)
  }

  @Test
  func encodeNestedObjectAndArrayWithSortedKeys() throws {
    let object: JSON.Object = [
      "meta": .object([
        "score": .number(3.25),
        "name": .string("clip"),
      ]),
      "flags": .array([.bool(true), .null]),
    ]
    let value: JSON.Value = .object(object)
    let objectFixture = try fixtureString("json-value-object")

    #expect(try encode(value) == objectFixture)
  }

  private func decodeFixture(_ name: String) throws -> JSON.Value {
    try decoder.decode(JSON.Value.self, from: fixtureData(name))
  }

  private func encode(_ value: JSON.Value) throws -> String {
    try #require(String(bytes: encoder.encode(value), encoding: .utf8))
  }

  private func fixtureData(_ name: String) throws -> Data {
    let url = try #require(Bundle.module.url(forResource: name, withExtension: "json"))
    return try Data(contentsOf: url)
  }

  private func fixtureString(_ name: String) throws -> String {
    let text = try #require(String(data: fixtureData(name), encoding: .utf8))

    // Resource files are normal text files in Git, so accept one final newline
    // at EOF without turning that editorial detail into a JSON semantic failure.
    if text.hasSuffix("\n") {
      return String(text.dropLast())
    }

    return text
  }
}
