/// A minimal contract for types that publish their semantic version line directly.
/// Keep this in `SwiftUniversalMain` so schema packages do not need an extra utility layer.
public protocol SemanticVersionable {
  /// The semantic version associated with the conforming type.
  static var version: String { get }
}
