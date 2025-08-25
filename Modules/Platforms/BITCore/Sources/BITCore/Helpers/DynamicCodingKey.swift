public struct DynamicCodingKey: CodingKey {
  public init?(stringValue: String) {
    self.stringValue = stringValue
  }

  public var stringValue: String

  public init?(intValue: Int) {
    nil
  }

  public var intValue: Int? {
    nil
  }
}
