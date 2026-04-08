import Foundation

/// A static carrier for the exact wire `schemaVersion` a schema model expects.
///
/// The phantom-tag pattern exists because Swift's `Decodable` synthesis cannot
/// pass per-conformer state into a property wrapper or a closure: a wrapper's
/// `init(from:)` has no access to the enclosing type, so it cannot know which
/// version to require. Lifting the expected version into the type system via a
/// tag protocol gives `SchemaVersionField`'s decoder static access to the
/// canonical string without storing any payload on the instance.
///
/// Conformers are typically nested enums or empty structs:
///
/// ```swift
/// public enum Tag: SchemaVersionTag {
///   public static let expected = "v0.1.0"
/// }
/// ```
public protocol SchemaVersionTag {
  /// The canonical wire `schemaVersion` string for the owning schema model.
  static var expected: String { get }
}

/// A zero-payload field that strictly enforces a model's exact `schemaVersion`
/// at decode time while keeping Swift's synthesized `Codable` intact for the
/// rest of the enclosing type.
///
/// The trick is that the expected version lives in the generic `Tag` parameter
/// rather than on the instance, so:
///
/// - `init(from:)` can fail fast on a mismatched wire string without needing
///   any context from the enclosing type.
/// - `encode(to:)` always writes `Tag.expected`, so re-encoded payloads stay
///   byte-stable against existing fixtures.
/// - The struct has no stored properties, so synthesized `Equatable` and
///   `Hashable` collapse to "all instances of the same `Tag` are equal", which
///   is exactly the desired semantics.
///
/// A conforming model declares one nested tag plus one field; the rest of the
/// model keeps synthesized `Codable`. See
/// `SchemaCatalogDomainDescriptor` for the canonical usage shape.
public struct SchemaVersionField<Tag: SchemaVersionTag>: Codable, Sendable, Equatable, Hashable {
  /// Construct a field. There is no payload to supply: the value is fixed by
  /// the `Tag` parameter.
  public init() {}

  /// The wire `schemaVersion` string this field represents. Always equal to
  /// `Tag.expected`.
  public var value: String { Tag.expected }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let raw = try container.decode(String.self)
    guard raw == Tag.expected else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription:
          "schemaVersion mismatch: expected \(Tag.expected), found \(raw)"
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(Tag.expected)
  }
}
