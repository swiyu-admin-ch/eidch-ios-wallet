import BITL10n
import BITOpenID
import BITTheming
import SwiftUI

extension VcSchemaTrust {
  public var icon: Image? {
    switch self {
    case .trusted:
      Assets.legitimateBadge.swiftUIImage
    case .untrusted:
      Assets.notLegitimateBadge.swiftUIImage
    case .notProtected:
      nil
    }
  }

  public var badgeStyle: (any BadgeStyle)? {
    switch self {
    case .trusted:
      .success
    case .untrusted:
      .error
    case .notProtected:
      nil
    }
  }

  public func getDescription(isIssuance: Bool) -> String? {
    switch self {
    case .trusted: isIssuance ? L10n.tkIssuerLegitimate : L10n.tkVerifierLegitimate
    case .untrusted: isIssuance ? L10n.tkIssuerNotLegitimate : L10n.tkVerifierNotLegitimate
    case .notProtected:
      nil
    }
  }

}
