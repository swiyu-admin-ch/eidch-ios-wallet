// MARK: - CharacterEncodingOverlay

public protocol CharacterEncodingOverlay: Overlay {
  var defaultCharacterEncoding: CharacterEncoding? { get }
  var attributeCharacterEncodings: [AttributeKey: CharacterEncoding]? { get }
}

// MARK: - CharacterEncodingOverlay1x0

public struct CharacterEncodingOverlay1x0: CharacterEncodingOverlay {
  public let type = OverlaySpecType.characterEncoding1_0
  public let captureBaseDigest: String
  public let defaultCharacterEncoding: CharacterEncoding?
  public let attributeCharacterEncodings: [AttributeKey: CharacterEncoding]?

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case defaultCharacterEncoding = "default_character_encoding"
    case attributeCharacterEncodings = "attribute_character_encoding"
  }
}

// MARK: - CharacterEncoding

public enum CharacterEncoding: Decodable, Equatable {
  case utf8
  case base64
  case unknown(rawString: String)

  public init(from decoder: Decoder) throws {
    let rawValue = try decoder.singleValueContainer().decode(String.self)
    self = switch rawValue {
    case _ where rawValue.lowercased() == "utf-8": .utf8
    case _ where rawValue.lowercased() == "base64": .base64
    default: .unknown(rawString: rawValue)
    }
  }
}
