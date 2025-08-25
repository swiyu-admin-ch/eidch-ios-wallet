import BITCore

// MARK: - EntryOverlay

public protocol EntryOverlay: LocalizedOverlay {
  var language: String { get }
  var attributeEntries: [AttributeKey: [EntryCode: String]] { get }
}

// MARK: - EntryOverlay1x0

public struct EntryOverlay1x0: EntryOverlay {

  // MARK: Lifecycle

  public init(
    captureBaseDigest: String,
    language: String,
    attributeEntries: [AttributeKey: [EntryCode: String]])
  {
    self.captureBaseDigest = captureBaseDigest
    self.language = language
    self.attributeEntries = attributeEntries
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    captureBaseDigest = try container.decode(String.self, forKey: .captureBaseDigest)
    language = try container.decode(String.self, forKey: .language)

    // we ommit SAIDs that reference code tables, decoding only lists of entry codes
    let entriesContainer = try container.nestedContainer(keyedBy: DynamicCodingKey.self, forKey: .attributeEntries)
    attributeEntries = entriesContainer.allKeys.compactGroup(keySelector: \.stringValue, valueTransform: { key in
      try? entriesContainer.decode([EntryCode: String].self, forKey: key)
    })
  }

  // MARK: Public

  public let type = OverlaySpecType.entry1_0
  public let captureBaseDigest: String
  public let language: String
  public let attributeEntries: [AttributeKey: [EntryCode: String]]

  public func validate(with captureBases: [any CaptureBase], overlays: [any Overlay]) throws {
    guard
      let entryCodeOverlay = overlays
        .compactMap({ $0 as? EntryCodeOverlay1x0 })
        .first(where: { $0.captureBaseDigest == captureBaseDigest }) else
    {
      throw OcaError.invalidEntryOverlay
    }

    let entriesValid = attributeEntries.allSatisfy { attributeKey, entries in
      guard let entryCodes = entryCodeOverlay.attributeEntryCodes[attributeKey] else {
        return false
      }
      return entries.keys.allSatisfy(entryCodes.contains)
    }

    guard entriesValid else {
      throw OcaError.invalidEntryOverlay
    }
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case language
    case captureBaseDigest = "capture_base"
    case attributeEntries = "attribute_entries"
  }
}
