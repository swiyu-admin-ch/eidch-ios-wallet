// MARK: - StandardOverlay

public protocol StandardOverlay: Overlay {
  var attributeStandards: [AttributeKey: Standard] { get }
}

// MARK: - StandardOverlay1x0

public struct StandardOverlay1x0: StandardOverlay {
  public let type = OverlaySpecType.standard1_0
  public let captureBaseDigest: String
  public let attributeStandards: [AttributeKey: Standard]

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case attributeStandards = "attr_standards"
  }
}

// MARK: - Standard

public enum Standard: Decodable, Equatable {
  case dataURLScheme
  case unknown(rawString: String)

  public init(from decoder: Decoder) throws {
    let rawValue = try decoder.singleValueContainer().decode(String.self)
    self = switch rawValue {
    case _ where rawValue.starts(with: "urn:ietf:rfc:2397"): .dataURLScheme
    default: .unknown(rawString: rawValue)
    }
  }
}
