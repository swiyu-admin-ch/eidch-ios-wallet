public struct OverlayBundleAttribute: Equatable {

  // MARK: Lifecycle

  init(
    captureBaseDigest: String,
    name: String,
    attributeType: AttributeType,
    characterEncoding: CharacterEncoding? = nil,
    dataSources: [DataSourceFormat: JsonPath] = [:],
    format: String? = nil,
    labels: [Locale: String] = [:],
    order: Int? = nil,
    standard: Standard? = nil)
  {
    self.captureBaseDigest = captureBaseDigest
    self.name = name
    self.attributeType = attributeType
    self.characterEncoding = characterEncoding
    self.dataSources = dataSources
    self.format = format
    self.labels = labels
    self.order = order
    self.standard = standard
  }

  // MARK: Public

  public let captureBaseDigest: String
  public let name: String
  public let attributeType: AttributeType
  public let characterEncoding: CharacterEncoding?
  public let dataSources: [DataSourceFormat: JsonPath]
  public let format: String?
  public let labels: [Locale: String]
  public let order: Int?
  public let standard: Standard?
}
