import BITL10n
import BITTheming
import SwiftUI

// MARK: - ActorInformationBadge

public struct ActorInformationBadge: View {

  public init(type: ActorInformationBadgeType) {
    self.type = type
  }

  public var body: some View {
    Badge(label: type.label, accessibilityLabel: type.accessibilityLabel, image: type.image)
      .badgeStyle(ActorInformationBadgeType.badgeStyle(type: type))
  }

  private let type: ActorInformationBadgeType
}

extension ActorInformationBadgeType {
  var label: String {
    switch self {
    case .trusted:
      L10n.tkIssuerTrusted
    case .notTrusted:
      L10n.tkIssuerNotTrusted
    case .unknownTrust:
      L10n.tkIssuerNotInSystem
    case .legitimateIssuer:
      L10n.tkIssuerLegitimate
    case .legitimateVerifier:
      L10n.tkVerifierLegitimate
    case .notLegitimateIssuer:
      L10n.tkIssuerNotLegitimate
    case .notLegitimateVerifier:
      L10n.tkVerifierNotLegitimate
    case .notCompliant:
      L10n.tkActorNonCompliant
    }
  }

  var accessibilityLabel: String {
    L10n.tkAccessibilityInformationAbout + ", " + label
  }

  var image: Image {
    switch self {
    case .trusted:
      Assets.trustBadge.swiftUIImage
    case .notTrusted:
      Assets.notTrustedBadge.swiftUIImage
    case .unknownTrust:
      Assets.unknownTrustBadge.swiftUIImage
    case .legitimateIssuer,
         .legitimateVerifier:
      Assets.legitimateBadge.swiftUIImage
    case .notCompliant,
         .notLegitimateIssuer,
         .notLegitimateVerifier:
      Assets.warningBadge.swiftUIImage
    }
  }

  /// var like for the others does not work because of the any (seems like a problem of swift...)
  static func badgeStyle(type: ActorInformationBadgeType) -> any BadgeStyle {
    switch type {
    case .legitimateIssuer,
         .legitimateVerifier,
         .trusted:
      .success
    case .notTrusted:
      .info
    case .notCompliant,
         .notLegitimateIssuer,
         .notLegitimateVerifier,
         .unknownTrust:
      .error
    }
  }
}

#if DEBUG
#Preview {
  VStack {
    ActorInformationBadge(type: .trusted)
    ActorInformationBadge(type: .notTrusted)
    ActorInformationBadge(type: .legitimateIssuer)
    ActorInformationBadge(type: .legitimateVerifier)
    ActorInformationBadge(type: .notLegitimateIssuer)
    ActorInformationBadge(type: .notLegitimateVerifier)
    ActorInformationBadge(type: .notCompliant(reason: "Reason"))
  }
}
#endif
