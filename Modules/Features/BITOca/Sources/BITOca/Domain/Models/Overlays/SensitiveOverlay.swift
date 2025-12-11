// MARK: - SensitiveOverlay

public protocol SensitiveOverlay: Overlay {
  var attributes: [AttributeKey] { get }
}

// MARK: - SensitiveOverlay1x0

public struct SensitiveOverlay1x0: SensitiveOverlay {
  public let type = OverlaySpecType.sensitive1_0
  public let captureBaseDigest: String
  public let attributes: [AttributeKey]

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case attributes
  }
}
