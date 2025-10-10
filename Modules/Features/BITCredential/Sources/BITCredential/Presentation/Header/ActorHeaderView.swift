import BITCredentialShared
import BITTheming
import SwiftUI

// MARK: - ActorHeaderView

public struct ActorHeaderView: View {

  // MARK: Lifecycle

  public init(name: String, trustInformation: TrustInformation, imageData: Data? = nil, topInset: CGFloat = 0, isIssuance: Bool = true) {
    self.name = name
    self.trustInformation = trustInformation
    self.imageData = imageData
    self.topInset = topInset
    self.isIssuance = isIssuance
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
    .clipShape(RoundedCorner(radius: .xxl, corners: [.bottomLeft, .bottomRight]))
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

  private static let imageMaxSize: CGFloat = 24

  @ScaledMetric(relativeTo: .body) private var badgeIconWidth: CGFloat = 14

  private let imageData: Data?
  private let name: String
  private let trustInformation: TrustInformation
  private let topInset: CGFloat
  private let isIssuance: Bool

  private var actorInformation: some View {
    HStack(alignment: .center, spacing: .x4) {
      (imageData.flatMap(Image.init) ?? Assets.unknownIcon.swiftUIImage)
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: Self.imageMaxSize, height: Self.imageMaxSize)
        .foregroundColor(.white)
        .colorMultiply(colorScheme.standardColor())
        .padding(.x3)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .clipShape(Circle())
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)
        .accessibilityHidden(true)

      Text(name)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityAddTraits(.isHeader)
    }
  }

  private var badges: some View {
    FlowLayout(verticalSpacing: .x3, horizontalSpacing: .x3) {
      let identityTrust = trustInformation.identity
      badge(image: identityTrust.icon, label: identityTrust.description, style: identityTrust.badgeStyle)
      if
        let icon = trustInformation.vcSchema.icon,
        let description = trustInformation.vcSchema.getDescription(isIssuance: isIssuance),
        let style = trustInformation.vcSchema.badgeStyle
      {
        badge(image: icon, label: description, style: style)
      }
    }
  }

  private func badge(image: Image, label: String, style: any BadgeStyle) -> some View {
    Badge {
      Label(
        title: {
          Text(label)
        },
        icon: {
          image
            .resizable()
            .scaledToFit()
            .frame(width: badgeIconWidth)
            .accessibilityHidden(true)
        })
    }
    .badgeStyle(AnyBadgeStyle(style: style))
  }
}

#if DEBUG
#Preview {
  VStack(spacing: .x10) {
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyTrusted, isIssuance: true)
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyUntrusted, isIssuance: true)
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyTrusted, isIssuance: false)
    ActorHeaderView(name: "Test", trustInformation: .Mock.fullyUntrusted, isIssuance: false)
  }
  .background(.gray)
}
#endif
