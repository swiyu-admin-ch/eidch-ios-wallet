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
    case .label1_0: try LabelOverlay1x0(from: decoder)
    case .dataSource1_0: try DataSourceOverlay1x0(from: decoder)
    default: nil
    }
  }
}
