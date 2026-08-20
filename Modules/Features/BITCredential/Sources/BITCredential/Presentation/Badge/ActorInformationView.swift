import BITL10n
import BITTheming
import SwiftUI

// MARK: - ActorInformationView

public struct ActorInformationView: View {

  // MARK: Lifecycle

  public init(actorInformation: ActorInformation) {
    self.actorInformation = actorInformation
  }

  // MARK: Public

  public var body: some View {
    InformationDetailView(
      primaryText: primaryText,
      indentedParagraphTitleText: indentedParagraphTitleText,
      indentedParagraphText: actorInformation.nonComplianceReason,
      secondaryText: secondaryText)
    {
      actorImage
    }
  }

  // MARK: Private

  private let actorInformation: ActorInformation

  private var primaryText: String {
    guard !actorInformation.isNonCompliant else {
      return L10n.tkBadgeInformationNonCompliantPrimary(actorInformation.actorName)
    }
    return actorInformation.identity.getPrimaryText(actorName: actorInformation.actorName)
  }

  private var indentedParagraphTitleText: String? {
    guard actorInformation.isNonCompliant else { return nil }
    return L10n.tkBadgeInformationNonCompliantSecondary
  }

  private var secondaryText: String? {
    guard !actorInformation.isNonCompliant else {
      return L10n.tkBadgeInformationNonCompliantHint(actorInformation.actorName, actorInformation.actorName)
    }
    return actorInformation.identity.getSecondaryText(actorName: actorInformation.actorName)
  }

  private var actorImage: some View {
    NormalizedLogoCircular(actorInformation.imageData)
      .padding(.x3)
      .overlay {
        Circle()
          .stroke(ThemingAssets.Label.primary.swiftUIColor.opacity(0.2), lineWidth: 1)
      }
      .padding(.top, .x1)
      .frame(maxWidth: .infinity, alignment: .center)
  }
}

extension IdentityTrust {
  fileprivate func getPrimaryText(actorName: String) -> String {
    switch self {
    case .trusted:
      L10n.tkBadgeInformationInTrustRegistryPrimary(actorName)
    case .trustedCheckApp:
      L10n.tkBadgeInformationTrustedCheckAppPrimary
    case .untrusted:
      L10n.tkBadgeInformationInBaseRegistryPrimary(actorName)
    case .unknown:
      L10n.tkBadgeInformationNotInSystemPrimary(actorName)
    }
  }

  fileprivate func getSecondaryText(actorName: String) -> String? {
    switch self {
    case .trusted:
      L10n.tkBadgeInformationInTrustRegistrySecondary(actorName)
    case .trustedCheckApp:
      L10n.tkBadgeInformationTrustedCheckAppSecondary
    case .untrusted:
      L10n.tkBadgeInformationInBaseRegistrySecondary(actorName)
    case .unknown:
      L10n.tkBadgeInformationNotInSystemSecondary(actorName)
    }
  }
}

#if DEBUG
#Preview {
  ActorInformationView(actorInformation: ActorInformation(identity: .trusted, actorName: "Actor name"))
}
#endif
