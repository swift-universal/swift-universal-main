/// A recursive JSON value model that stays available anywhere standard Swift can go.
///
/// Keep this surface free of `Foundation` so higher-level packages can model
/// arbitrary JSON payloads without narrowing their portability.
extension JSON {
  /// A JSON object represented as string keys and recursive JSON values.
  public typealias Object = [String: Value]

  public enum Value: Codable, Sendable, Equatable {
    case null

    /// A JSON number stored as `Double` for portability.
    ///
    /// This keeps the model below `Foundation`, but it does mean callers that
    /// need exact decimal or large integer preservation should model those
    /// values at a higher layer instead of assuming this primitive will do it.
    case number(Double)
    case string(String)
    case bool(Bool)
    case object(Object)
    case array([Value])

    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()

      if container.decodeNil() {
        self = .null
        return
      }

      if let number = try? container.decode(Double.self) {
        self = .number(number)
        return
      }

      if let string = try? container.decode(String.self) {
        self = .string(string)
        return
      }

      if let bool = try? container.decode(Bool.self) {
        self = .bool(bool)
        return
      }

      if let object = try? container.decode(Object.self) {
        self = .object(object)
        return
      }

      if let array = try? container.decode([Value].self) {
        self = .array(array)
        return
      }

      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Failed to decode JSON.Value.")
    }

    public func encode(to encoder: any Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
        case .null:
          try container.encodeNil()

        case let .number(number):
          try container.encode(number)

        case let .string(string):
          try container.encode(string)

        case let .bool(bool):
          try container.encode(bool)

        case let .object(object):
          try container.encode(object)

        case let .array(array):
          try container.encode(array)
      }
    }
  }
}
