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
    #expect(try decode("null") == .null)
    #expect(try decode("3.25") == .number(3.25))
    #expect(try decode("\"hello\"") == .string("hello"))
    #expect(try decode("true") == .bool(true))
  }

  @Test
  func decodeNestedObjectAndArray() throws {
    let json = #"""
    {
      "flags": [true, null],
      "meta": {
        "name": "clip",
        "score": 3.25
      }
    }
    """#

    let decoded = try decode(json)

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
    #expect(try encode(.null) == "null")
    #expect(try encode(.number(3.25)) == "3.25")
    #expect(try encode(.string("hello")) == "\"hello\"")
    #expect(try encode(.bool(true)) == "true")
  }

  @Test
  func encodeNestedObjectAndArrayWithSortedKeys() throws {
    let value: JSON.Value = .object([
      "meta": .object([
        "score": .number(3.25),
        "name": .string("clip"),
      ]),
      "flags": .array([.bool(true), .null]),
    ])

    #expect(
      try encode(value)
        == #"{"flags":[true,null],"meta":{"name":"clip","score":3.25}}"#)
  }

  private func decode(_ source: String) throws -> JSON.Value {
    try decoder.decode(JSON.Value.self, from: Data(source.utf8))
  }

  private func encode(_ value: JSON.Value) throws -> String {
    try #require(String(bytes: encoder.encode(value), encoding: .utf8))
  }
}
