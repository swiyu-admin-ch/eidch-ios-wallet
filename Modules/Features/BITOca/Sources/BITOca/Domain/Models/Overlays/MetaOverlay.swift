// MARK: - MetaOverlay

public protocol MetaOverlay: LocalizedOverlay {
  var name: String? { get }
  var description: String? { get }
}

// MARK: - MetaOverlay1x0

public struct MetaOverlay1x0: MetaOverlay {
  public let type = OverlaySpecType.meta1_0
  public let captureBaseDigest: String
  public let language: String
  public let name: String?
  public let description: String?

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case language
    case name
    case description
  }
}
