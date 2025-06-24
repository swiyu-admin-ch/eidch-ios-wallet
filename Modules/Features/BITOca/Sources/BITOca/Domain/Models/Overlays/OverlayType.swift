public enum OverlayType {
  case branding
  case characterEncoding
  case dataSource
  case format
  case label
  case meta
  case order
  case standard

  // MARK: Internal

  func getSpecTypes() -> [OverlaySpecType] {
    switch self {
    case .branding:
      [.branding1_1]
    case .characterEncoding:
      [.characterEncoding1_0]
    case .dataSource:
      [.dataSource1_0]
    case .format:
      [.format1_0]
    case .label:
      [.label1_0]
    case .meta:
      [.meta1_0]
    case .order:
      [.order1_0]
    case .standard:
      [.standard1_0]
    }
  }
}
