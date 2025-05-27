// MARK: - LabelOverlay

public protocol LabelOverlay: LocalizedOverlay {
  var attributeLabels: [String: String] { get }
}

// MARK: - LabelOverlay1x0

public struct LabelOverlay1x0: LabelOverlay {
  public let type = OverlaySpecType.label1_0
  public let captureBaseDigest: String
  public let language: String
  public let attributeLabels: [AttributeKey: String]
  public let attributeCategories: [String]?
  public let categoryLabels: [String: String]?

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case language
    case attributeLabels = "attribute_labels"
    case attributeCategories = "attribute_categories"
    case categoryLabels = "category_labels"
  }
}
