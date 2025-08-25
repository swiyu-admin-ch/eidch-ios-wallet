import BITCore

public typealias EntryCode = String

// MARK: - EntryCodeOverlay1x0

public struct EntryCodeOverlay1x0: Overlay {

  // MARK: Lifecycle

  public init(
    captureBaseDigest: String,
    attributeEntryCodes: [AttributeKey: [EntryCode]])
  {
    self.captureBaseDigest = captureBaseDigest
    self.attributeEntryCodes = attributeEntryCodes
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    captureBaseDigest = try container.decode(String.self, forKey: .captureBaseDigest)

    // we ommit SAIDs that reference code tables, decoding only lists of entry codes
    let entryCodesContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .attributeEntryCodes)
    attributeEntryCodes = entryCodesContainer.allKeys.compactGroup(keySelector: \.stringValue, valueTransform: { key in
      try? entryCodesContainer.decode([EntryCode].self, forKey: key)
    })
  }

  // MARK: Public

  public let type = OverlaySpecType.entryCode1_0
  public let captureBaseDigest: String
  public let attributeEntryCodes: [AttributeKey: [EntryCode]]

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case captureBaseDigest = "capture_base"
    case attributeEntryCodes = "attribute_entry_codes"
  }
}
