public enum OverlayType {
  case branding
  case characterEncoding
  case dataSource
  case entry
  case entryCode
  case format
  case label
  case meta
  case order
  case sensitive
  case standard

  // MARK: Internal

  func getSpecTypes() -> [OverlaySpecType] {
    switch self {
    case .branding:
      [.branding1_1]
    case .characterEncoding:
      [.characterEncoding1_0]
    case .dataSource:
      [.dataSource2_0, .dataSource1_0]
    case .entry:
      [.entry1_0]
    case .entryCode:
      [.entryCode1_0]
    case .format:
      [.format1_0]
    case .label:
      [.label1_0]
    case .meta:
      [.meta1_0]
    case .order:
      [.order1_0]
    case .sensitive:
      [.sensitive1_0]
    case .standard:
      [.standard1_0]
    }
  }
}
