import BITL10n
import SwiftUI

// MARK: - ClaimInformationView

public struct ClaimInformationView: View {

  // MARK: Lifecycle

  public init(isSensitive: Bool, claimName: String) {
    self.isSensitive = isSensitive
    self.claimName = claimName
  }

  // MARK: Public

  public var body: some View {
    InformationDetailView(primaryText: primaryText, secondaryText: secondaryText) {
      SensitiveDataBadge(isSensitive: isSensitive, claimName: claimName)
    }
  }

  // MARK: Private

  private let isSensitive: Bool
  private let claimName: String

  private var primaryText: String {
    isSensitive ? L10n.tkBadgeInformationSensitiveClaimInfoPrimary : L10n.tkBadgeInformationNonSensitiveClaimInfoPrimary
  }

  private var secondaryText: String {
    isSensitive ? L10n.tkBadgeInformationSensitiveClaimInfoSecondary : L10n.tkBadgeInformationNonSensitiveClaimInfoSecondary
  }
}

#if DEBUG
#Preview {
  ClaimInformationView(isSensitive: true, claimName: "Claim name")
}
#endif
