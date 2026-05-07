import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import SwiftUI

// MARK: - ActorHeaderView

public struct ActorHeaderView: View {

  // MARK: Lifecycle

  public init(
    name: String? = nil,
    badgeTypes: [ActorInformationBadgeType],
    imageData: Data? = nil,
    topInset: CGFloat = 0,
    onBadgeTapped: ((BadgeType) -> Void)? = nil)
  {
    self.name = name ?? L10n.tkErrorNotregisteredTitle
    self.badgeTypes = badgeTypes
    self.imageData = imageData
    self.topInset = topInset
    self.onBadgeTapped = onBadgeTapped
  }

  // MARK: Public

  public var body: some View {
    VStack(alignment: .leading, spacing: .x3) {
      actorInformation
      badges
    }
    .padding(.top, topInset)
    .padding(.top, .x4)
    .padding(.bottom, .x3)
    .padding(.horizontal, .x4)
    .background(ThemingAssets.Background.groupedRow.swiftUIColor)
    .clipShape(RoundedCorner(radius: .x6, corners: [.bottomLeft, .bottomRight]))
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content
    case image
  }

  @Environment(\.colorScheme) var colorScheme

  // MARK: Private

  private let imageData: Data?
  private let name: String
  private let badgeTypes: [ActorInformationBadgeType]
  private let topInset: CGFloat
  private let onBadgeTapped: ((BadgeType) -> Void)?

  private var actorInformation: some View {
    HStack(alignment: .center, spacing: .x4) {
      NormalizedLogoCircular(imageData)
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)

      Text(name)
        .lineLimit(0)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityAddTraits(.isHeader)
    }
  }

  private var badges: some View {
    FlowLayout(verticalSpacing: .x3, horizontalSpacing: .x3) {
      ForEach(badgeTypes, id: \.hashValue) { badgeType in
        badgeButton(type: badgeType)
      }
    }
  }

  private func badgeButton(type: ActorInformationBadgeType) -> some View {
    Button {
      onBadgeTapped?(.actorInformation(type: type, actorName: name))
    } label: {
      ActorInformationBadge(type: type)
    }
  }
}

extension ActorHeaderView {
  public init(
    name: String,
    trustInformation: TrustInformation,
    type: ActorHeaderViewType,
    imageData: Data? = nil,
    topInset: CGFloat = 0,
    onBadgeTapped: ((BadgeType) -> Void)? = nil)
  {
    var badgeTypes = [
      trustInformation.identity.actorInformationBadgeType,
      trustInformation.vcSchema.getActorInformationBadgeType(for: type),
    ].compactMap { $0 }

    if case .notCompliant(let nonComplianceReason) = trustInformation.actorCompliance, let reason = nonComplianceReason.localized() {
      badgeTypes.append(.notCompliant(reason: reason))
    }

    self.init(name: name, badgeTypes: badgeTypes, imageData: imageData, topInset: topInset, onBadgeTapped: onBadgeTapped)
  }
}

#if DEBUG
#Preview {
  VStack(spacing: .x10) {
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyTrusted, type: .issuance)
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyUntrusted, type: .issuance)
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyTrusted, type: .presentation)
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyUntrusted, type: .presentation)
  }
  .background(.gray)
}
#endif

// MARK: - ActorHeaderViewType

public enum ActorHeaderViewType {
  case issuance
  case presentation
}

extension IdentityTrust {
  var actorInformationBadgeType: ActorInformationBadgeType {
    switch self {
    case .trusted:
      .trusted
    case .untrusted:
      .notTrusted
    case .unknown:
      .unknownTrust
    }
  }
}

extension VcSchemaTrust {
  func getActorInformationBadgeType(for type: ActorHeaderViewType) -> ActorInformationBadgeType? {
    switch self {
    case .trusted:
      type == .issuance ? .legitimateIssuer : .legitimateVerifier
    case .untrusted:
      type == .issuance ? .notLegitimateIssuer : .notLegitimateVerifier
    case .notProtected:
      nil
    }
  }
}
