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
    ZStack {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      content
    }
    .navigationBar(.secondaryScroll, scrollEdgeAppearance: .secondary)
    .toolbar(content: toolbarContent)
  }

  // MARK: Private

  private let badgeType: BadgeType
  private let onClose: () -> Void

  private var content: some View {
    VStack(alignment: .leading, spacing: .x2) {
      badge.padding(.horizontal, .x4)
      Text(badgeType.primaryText)
        .font(.custom.headline)
        .padding(.top, .x2)
        .padding(.horizontal, .x4)
        .accessibilityAddTraits(.isHeader)
      VStack(alignment: .leading, spacing: .x6) {
        if let paragraphTitle = badgeType.indentedParagraphTitleText, let paragraphText = badgeType.indentedParagraphText {
          VStack(alignment: .leading, spacing: .x4) {
            Text(paragraphTitle)
            Text(paragraphText)
              .font(.custom.body.italic())
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.x3)
              .background(
                RoundedRectangle(cornerRadius: 10)
                  .foregroundStyle(ThemingAssets.Background.groupedRow.swiftUIColor))
          }
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .padding(.horizontal, .x2)
        }
        if let secondaryText = badgeType.secondaryText {
          Text(secondaryText)
            .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        }
        if let url = URL(string: L10n.tkBadgeInformationFurtherInformationLinkValue) {
          CustomLink(to: url, label: L10n.tkBadgeInformationFurtherInformationLinkText)
        }
      }
      .padding(.horizontal, .x4)
    }
    .frame(maxHeight: .infinity, alignment: .top)
    .landscapeMaxWidth()
    .applyScrollViewIfNeeded()
  }

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

  fileprivate var indentedParagraphTitleText: String? {
    switch self {
    case .actorInformation(let type, _):
      type.getIndentedParagraphTitleText()
    case .sensitiveData: nil
    }
  }

  fileprivate var indentedParagraphText: String? {
    switch self {
    case .actorInformation(let type, _):
      type.getIndentedParagraphText()
    case .sensitiveData: nil
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
    case .notCompliant:
      L10n.tkBadgeInformationNonCompliantPrimary(actorName)
    }
  }

  fileprivate func getIndentedParagraphTitleText() -> String? {
    switch self {
    case .notCompliant:
      L10n.tkBadgeInformationNonCompliantSecondary
    default: nil
    }
  }

  fileprivate func getIndentedParagraphText() -> String? {
    switch self {
    case .notCompliant(let reason):
      reason
    default: nil
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
    case .notCompliant:
      L10n.tkBadgeInformationNonCompliantHint(actorName, actorName)
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
