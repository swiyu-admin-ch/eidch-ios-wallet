/// https://oca.colossi.network/specification/v1.0.1.html#capture-base
public struct CaptureBase1x0: CaptureBase {
  public var type = CaptureBaseSpecType.base1_0
  public let digest: String
  public let attributes: [String: AttributeType]
  public let classification: String?
  public let flaggedAttributes: [String]?
}
