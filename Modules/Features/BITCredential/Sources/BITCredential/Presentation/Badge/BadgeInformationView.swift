import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - BadgeInformationView

public struct BadgeInformationView: View {

  // MARK: Lifecycle

  public init(badgeType: BadgeType, onClose: @escaping () -> Void = {}) {
    self.badgeType = badgeType
    self.onClose = onClose
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x2) {
      badge.padding(.horizontal, .x4)
      Text(badgeType.primaryText)
        .font(.custom.headline)
        .padding(.top, .x2)
        .padding(.horizontal, .x6)
      VStack(alignment: .leading, spacing: .x6) {
        if let secondaryText = badgeType.secondaryText {
          Text(secondaryText)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        }
        if let url = URL(string: L10n.tkBadgeInformationFurtherInformationLinkValue) {
          Link(destination: url, label: {
            LinkText(L10n.tkBadgeInformationFurtherInformationLinkText)
              .font(.custom.footnote)
          })
        }
      }
      .padding(.horizontal, .x6)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .landscapeMaxWidth()
    .applyScrollViewIfNeeded()
    .toolbar(content: toolbarContent)
  }

  // MARK: Private

  private let badgeType: BadgeType
  private let onClose: () -> Void

  @ViewBuilder
  private var badge: some View {
    switch badgeType {
    case .actorInformation(let type, _):
      ActorInformationBadge(type: type)
    case .sensitiveData(let isSensitive, let claimName):
      SensitiveDataBadge(isSensitive: isSensitive, claimName: claimName)
    }
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: onClose, label: {
        Assets.closeAlt.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
    }
  }

}

extension BadgeType {
  fileprivate var primaryText: String {
    switch self {
    case .actorInformation(let type, let actorName):
      type.getPrimaryText(actorName: actorName)
    case .sensitiveData(let isSensitive, _):
      isSensitive ? L10n.tkBadgeInformationSensitiveClaimInfoPrimary : L10n.tkBadgeInformationNonSensitiveClaimInfoPrimary
    }
  }

  fileprivate var secondaryText: String? {
    switch self {
    case .actorInformation(let type, let actorName):
      type.getSecondaryText(actorName: actorName)
    case .sensitiveData(let isSensitive, _):
      isSensitive ? L10n.tkBadgeInformationSensitiveClaimInfoSecondary : L10n.tkBadgeInformationNonSensitiveClaimInfoSecondary
    }
  }
}

extension ActorInformationBadgeType {
  fileprivate func getPrimaryText(actorName: String) -> String {
    switch self {
    case .trusted:
      L10n.tkBadgeInformationInTrustRegistryPrimary(actorName)
    case .notTrusted:
      L10n.tkBadgeInformationInBaseRegistryPrimary(actorName)
    case .unknownTrust:
      L10n.tkBadgeInformationNotInSystemPrimary(actorName)
    case .legitimateIssuer:
      L10n.tkBadgeInformationLegitimateIssuerPrimary(actorName)
    case .legitimateVerifier:
      L10n.tkBadgeInformationLegitimateVerifierPrimary(actorName)
    case .notLegitimateIssuer:
      L10n.tkBadgeInformationNotLegitimateIssuerPrimary(actorName)
    case .notLegitimateVerifier:
      L10n.tkBadgeInformationNotLegitimateVerifierPrimary(actorName)
    }
  }

  fileprivate func getSecondaryText(actorName: String) -> String? {
    switch self {
    case .trusted:
      L10n.tkBadgeInformationInTrustRegistrySecondary(actorName)
    case .notTrusted:
      L10n.tkBadgeInformationInBaseRegistrySecondary(actorName)
    case .unknownTrust:
      L10n.tkBadgeInformationNotInSystemSecondary(actorName)
    case .legitimateIssuer,
         .legitimateVerifier,
         .notLegitimateIssuer,
         .notLegitimateVerifier:
      nil
    }
  }
}

#if DEBUG
#Preview {
  BadgeInformationView(badgeType: .actorInformation(type: .trusted, actorName: "Actor name"))
}
#endif
