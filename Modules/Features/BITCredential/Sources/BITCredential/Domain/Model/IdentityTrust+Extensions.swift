import BITCredentialShared
import BITL10n
import BITTheming
import SwiftUI

extension IdentityTrust {
  public var icon: Image {
    switch self {
    case .trusted:
      Assets.trustBadge.swiftUIImage
    case .untrusted:
      Assets.notTrustedBadge.swiftUIImage
    }
  }

  public var description: String {
    switch self {
    case .trusted: L10n.tkIssuerTrusted
    case .untrusted: L10n.tkIssuerNotTrusted
    }
  }

  public var badgeStyle: any BadgeStyle {
    switch self {
    case .trusted:
      .success
    case .untrusted:
      .info
    }
  }
}
