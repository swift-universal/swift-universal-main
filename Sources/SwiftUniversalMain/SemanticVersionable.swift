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

public extension SemanticVersionable {
  /// The canonical schema version to write when a model is initialized without
  /// an explicit override.
  static var defaultSchemaVersion: String { semanticVersion }

  /// Normalize a candidate schema version back to the type's semantic version.
  ///
  /// This is intentionally lenient for assignment paths so callers can keep
  /// writing the canonical version while still surfacing a warning when stale or
  /// incorrect input tries to flow in.
  static func canonicalSchemaVersion(_ candidate: String?) -> String {
    guard let candidate else {
      return defaultSchemaVersion
    }

    guard candidate == semanticVersion else {
      semanticVersionLog.warning(
        "semantic-version normalized_schema_version " +
          "type=\(String(reflecting: Self.self)) " +
          "expected=\(semanticVersion) " +
          "received=\(candidate)"
      )
      return defaultSchemaVersion
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
