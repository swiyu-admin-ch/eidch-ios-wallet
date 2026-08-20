import BITL10n
import BITTheming
import SwiftUI

// MARK: - SensitiveDataBadge

public struct SensitiveDataBadge: View {

  public init(isSensitive: Bool, claimName: String) {
    self.isSensitive = isSensitive
    self.claimName = claimName
  }

  public var body: some View {
    Badge(label: claimName, image: isSensitive ? Assets.sensitiveBadge.swiftUIImage : nil)
      .badgeStyle(isSensitive ? .sensitive : .info)
      .if(isSensitive) { $0.accessibilityHint(L10n.tkGlobalSensitiveDataHint) }
  }

  private let isSensitive: Bool
  private let claimName: String
}

#if DEBUG
#Preview {
  VStack {
    SensitiveDataBadge(isSensitive: true, claimName: "Sensitive")
    SensitiveDataBadge(isSensitive: false, claimName: "Not Sensitive")
  }
}
#endif
