
// MARK: - OrderOverlay

public protocol OrderOverlay: Overlay {
  var attributeOrders: [AttributeKey: Int] { get }
}

// MARK: - OrderOverlay1x0

public struct OrderOverlay1x0: OrderOverlay {

  // MARK: Public

  public let type = OverlaySpecType.order1_0
  public let captureBaseDigest: String
  public let attributeOrders: [AttributeKey: Int]

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case attributeOrders = "attribute_orders"
  }
}
