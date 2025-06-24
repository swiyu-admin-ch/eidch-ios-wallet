// MARK: - DataSourceOverlay

public protocol DataSourceOverlay: Overlay {
  var format: String { get }
  var attributeSources: [String: JsonPath] { get }
}

// MARK: - DataSourceOverlay1x0

public struct DataSourceOverlay1x0: DataSourceOverlay {
  public let type = OverlaySpecType.dataSource1_0
  public let captureBaseDigest: String
  public let format: String
  public let attributeSources: [AttributeKey: JsonPath]

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case format
    case attributeSources = "attribute_sources"
  }
}
