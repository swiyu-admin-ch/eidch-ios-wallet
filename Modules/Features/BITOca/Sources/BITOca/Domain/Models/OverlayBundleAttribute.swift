public struct OverlayBundleAttribute: Equatable {

  init(captureBaseDigest: String, name: String, attributeType: AttributeType, labels: [Locale: String] = [:], dataSources: [DataSourceFormat: JsonPath] = [:]) {
    self.captureBaseDigest = captureBaseDigest
    self.name = name
    self.attributeType = attributeType
    self.labels = labels
    self.dataSources = dataSources
  }

  public let captureBaseDigest: String
  public let name: String
  public let attributeType: AttributeType
  public let labels: [Locale: String]
  public let dataSources: [DataSourceFormat: JsonPath]
}
