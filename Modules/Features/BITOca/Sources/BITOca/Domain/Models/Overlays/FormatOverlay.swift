// MARK: - FormatOverlay

public protocol FormatOverlay: Overlay {
  var attributeFormats: [AttributeKey: String] { get }
}

// MARK: - FormatOverlay1x0

public struct FormatOverlay1x0: FormatOverlay {
  public let type = OverlaySpecType.format1_0
  public let captureBaseDigest: String
  public let attributeFormats: [AttributeKey: String]

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case attributeFormats = "attribute_formats"
  }
}
