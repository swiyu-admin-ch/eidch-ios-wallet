// MARK: - TypeDecodedOverlay

struct TypeDecodedOverlay: Decodable {

  // MARK: Lifecycle

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DecodingKeys.self)
    type = try? container.decode(OverlaySpecType.self, forKey: .type)
    overlay = try Self.decodeOverlay(type: type, decoder: decoder)
  }

  // MARK: Internal

  let type: OverlaySpecType?
  let overlay: (any Overlay)?

  // MARK: Private

  private enum DecodingKeys: String, CodingKey {
    case type
  }

  private static func decodeOverlay(type: OverlaySpecType?, decoder: Decoder) throws -> (any Overlay)? {
    switch type {
    case .branding1_1: try BrandingOverlay1x1(from: decoder)
    case .characterEncoding1_0: try CharacterEncodingOverlay1x0(from: decoder)
    case .dataSource1_0: try DataSourceOverlay1x0(from: decoder)
    case .entry1_0: try EntryOverlay1x0(from: decoder)
    case .entryCode1_0: try EntryCodeOverlay1x0(from: decoder)
    case .format1_0: try FormatOverlay1x0(from: decoder)
    case .label1_0: try LabelOverlay1x0(from: decoder)
    case .meta1_0: try MetaOverlay1x0(from: decoder)
    case .order1_0: try OrderOverlay1x0(from: decoder)
    case .standard1_0: try StandardOverlay1x0(from: decoder)
    default: nil
    }
  }
}
