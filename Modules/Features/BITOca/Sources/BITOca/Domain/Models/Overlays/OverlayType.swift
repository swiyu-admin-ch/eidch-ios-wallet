public enum OverlayType {
  case label
  case dataSource

  // MARK: Internal

  func getSpecTypes() -> [OverlaySpecType] {
    switch self {
    case .label:
      [.label1_0]
    case .dataSource:
      [.dataSource1_0]
    }
  }
}
