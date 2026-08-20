import BITCredentialShared
import BITL10n
import BITNonCompliance
import BITTheming
import SwiftUI

// MARK: - ActorHeaderView

public struct ActorHeaderView: View {

  // MARK: Lifecycle

  public init(
    viewModel: ActorHeaderViewModel,
    topInset: CGFloat = 0,
    onTapped: ((ActorInformation) -> Void)? = nil)
  {
    self.viewModel = viewModel
    self.topInset = topInset
    self.onTapped = onTapped
  }

  // MARK: Public

  public var body: some View {
    content
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

  @ScaledMetric(relativeTo: .body) private var trustBadgeWidth = 17
  @ScaledMetric(relativeTo: .body) private var trustBadgeHeight = 21
  @ScaledMetric(relativeTo: .body) private var nonComplianceIconSize = 18

  private let viewModel: ActorHeaderViewModel
  private let topInset: CGFloat
  private let onTapped: ((ActorInformation) -> Void)?

  private var content: some View {
    VStack(alignment: .leading, spacing: .x4) {
      actorInformation
      if viewModel.isNonCompliant {
        nonComplianceButton
      }
    }
  }

  private var actorInformation: some View {
    Group {
      if let onTapped {
        Button {
          onTapped(viewModel.actorInformation)
        } label: {
          actorInformationContent
        }
        .buttonStyle(.plain)
      } else {
        actorInformationContent
      }
    }
  }

  private var actorInformationContent: some View {
    HStack(alignment: .center, spacing: .x4) {
      NormalizedLogoCircular(viewModel.imageData)
        .accessibilityIdentifier(AccessibilityIdentifier.image.rawValue)

      HStack(alignment: .center, spacing: .x2) {
        Text(viewModel.name)
          .lineLimit(0)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilityAddTraits(.isHeader)

        if viewModel.showsTrustBadge {
          Assets.trustBadge.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(width: trustBadgeWidth, height: trustBadgeHeight)
            .accessibilityHidden(true)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var nonComplianceButton: some View {
    Button {
      onTapped?(viewModel.nonComplianceActorInformation)
    } label: {
      HStack(alignment: .center, spacing: .x3) {
        Text(L10n.tkActorNonCompliantButton)
          .frame(maxWidth: .infinity, alignment: .center)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)

        ThemingAssets.information.swiftUIImage
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: nonComplianceIconSize, height: nonComplianceIconSize)
          .accessibilityHidden(true)
      }
      .frame(maxWidth: .infinity)
    }
    .buttonStyle(.warning)
    .controlSize(.large)
  }
}

extension ActorHeaderView {
  public init(
    name: String,
    trustInformation: TrustInformation,
    actorCompliance: ActorCompliance = .compliant,
    imageData: Data? = nil,
    topInset: CGFloat = 0,
    onTapped: ((ActorInformation) -> Void)? = nil)
  {
    self.init(
      viewModel: ActorHeaderViewModel(
        name: name,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance,
        imageData: imageData),
      topInset: topInset,
      onTapped: onTapped)
  }
}

#if DEBUG
#Preview {
  VStack(spacing: .x10) {
    ActorHeaderView(name: "Trusted actor", trustInformation: .Mock.fullyTrusted)
    ActorHeaderView(name: "Untrusted actor", trustInformation: .Mock.fullyUntrusted)
    ActorHeaderView(name: "Unknown actor", trustInformation: .Mock.unknownIdentity)
  }
  .background(.gray)
}
#endif
