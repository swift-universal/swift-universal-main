import CommonLog

// Keep one package-local logger for version normalization so schema packages
// share the same warning surface instead of inventing per-model logging.
private let semanticVersionLog = Log(
  system: "SwiftUniversalMain",
  category: "SemanticVersionable",
  maxExposureLevel: .trace
)

/// A minimal contract for types that publish both their type-level semantic
/// version and their instance-level schema version.
///
/// Keep this in `SwiftUniversalMain` so schema packages do not need an extra
/// utility layer just to keep version defaults and validation consistent.
public protocol SemanticVersionable {
  /// The semantic version associated with the conforming type.
  static var semanticVersion: String { get }

  /// The schema version carried by an instance on the wire.
  ///
  /// Nested models and primitives that do not persist a top-level
  /// `schemaVersion` field can return `Self.semanticVersion` here.
  var schemaVersion: String { get }
}

public struct SchemaVersionAssignmentError: Error, Sendable, Equatable {
  public var typeName: String
  public var expected: String
  public var received: String

  public init(typeName: String, expected: String, received: String) {
    self.typeName = typeName
    self.expected = expected
    self.received = received
  }
}

public extension SemanticVersionable {
  /// The canonical schema version to write when a model is initialized without
  /// an explicit override.
  static var defaultSchemaVersion: String { semanticVersion }

  /// Reject an attempted schema version reassignment.
  ///
  /// Top-level schema docs should expose `schemaVersion` as read-only and keep
  /// version validation explicit instead of silently normalizing mismatches.
  static func validateAssignedSchemaVersion(_ candidate: String) throws -> String {
    guard candidate == semanticVersion else {
      semanticVersionLog.warning(
        "semantic-version rejected_schema_version_assignment " +
          "type=\(String(reflecting: Self.self)) " +
          "expected=\(semanticVersion) " +
          "received=\(candidate)"
      )
      throw SchemaVersionAssignmentError(
        typeName: String(reflecting: Self.self),
        expected: semanticVersion,
        received: candidate
      )
    }

    return candidate
  }

  /// Decode and strictly validate the persisted schema version.
  ///
  /// Specific schema decoders should fail fast instead of silently widening
  /// themselves to accept neighboring lines.
  static func decodeSchemaVersion<Key: CodingKey>(
    forKey key: Key,
    in container: KeyedDecodingContainer<Key>
  ) throws -> String {
    let decodedSchemaVersion = try container.decode(String.self, forKey: key)
    guard decodedSchemaVersion == semanticVersion else {
      throw DecodingError.dataCorruptedError(
        forKey: key,
        in: container,
        debugDescription: "Expected \(key.stringValue) \(semanticVersion)"
      )
    }

    return decodedSchemaVersion
  }
}
