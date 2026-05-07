import BITClaimsPathPointer

// MARK: - DataSourceOverlay

public protocol DataSourceOverlay: Overlay {
  var format: String { get }
  var attributeSources: [AttributeKey: ClaimsPathPointer] { get }
}

// MARK: - DataSourceOverlay2x0

public struct DataSourceOverlay2x0: DataSourceOverlay {
  public let type = OverlaySpecType.dataSource2_0
  public let captureBaseDigest: String
  public let format: String
  public let attributeSources: [AttributeKey: ClaimsPathPointer]

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case format
    case attributeSources = "attribute_sources"
  }
}

// MARK: - DataSourceOverlay1x0

public struct DataSourceOverlay1x0: DataSourceOverlay {

  // MARK: Lifecycle

  public init(captureBaseDigest: String, format: String, attributeSources: [AttributeKey: ClaimsPathPointer]) {
    self.captureBaseDigest = captureBaseDigest
    self.format = format
    self.attributeSources = attributeSources
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    captureBaseDigest = try container.decode(String.self, forKey: .captureBaseDigest)
    format = try container.decode(String.self, forKey: .format)
    let sources = try container.decode([AttributeKey: JsonPath].self, forKey: .attributeSources)
    attributeSources = sources.mapValues(\.claimsPathPointer)
  }

  // MARK: Public

  public let type = OverlaySpecType.dataSource1_0
  public let captureBaseDigest: String
  public let format: String
  public let attributeSources: [AttributeKey: ClaimsPathPointer]

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case format
    case attributeSources = "attribute_sources"
  }
}
