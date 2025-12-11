import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import Factory
import SwiftUI

// MARK: - VerifiableCredentialCell

public struct VerifiableCredentialCell: View {

  // MARK: Lifecycle

  public init(_ viewModel: VerifiableCredentialViewModel, disclosureIndicator: DisclosureIndicator = .none) {
    self.viewModel = viewModel
    self.disclosureIndicator = disclosureIndicator
  }

  // MARK: Public

  public var body: some View {
    HStack(alignment: .center, spacing: .x3) {
      if sizeCategory <= .accessibilityLarge {
        card
      }
      information
      trailingImage
    }
    .padding(.horizontal, .x4)
    .padding(.vertical, .x3)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityText)
  }

  // MARK: Private

  @ScaledMetric(relativeTo: .caption) private var statusImageWidth: CGFloat = 14
  @Environment(\.sizeCategory) private var sizeCategory

  private var disclosureIndicator: DisclosureIndicator
  private let viewModel: VerifiableCredentialViewModel

  private var accessibilityText: String {
    var parts = [String]()
    parts.append(viewModel.credentialDisplay?.name ?? L10n.tkCredentialFallbackTitle)
    if let summary = viewModel.credentialDisplay?.summary {
      parts.append(summary)
    }
    if viewModel.environment == .swiyuInt {
      parts.append(L10n.tkCredentialStatusDemoAlt)
    }
    parts.append(viewModel.statusText)
    return parts.joined(separator: ", ")
  }

  private var card: some View {
    CredentialCard(
      name: viewModel.credentialDisplay?.name,
      summary: viewModel.credentialDisplay?.summary,
      background: viewModel.credentialDisplay?.backgroundColor,
      logoBase64: viewModel.credentialDisplay?.logoBase64,
      environment: viewModel.environment)
      .controlSize(.mini)
  }

  private var information: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(viewModel.credentialDisplay?.name ?? L10n.tkCredentialFallbackTitle)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .font(.custom.body)
      if let summary = viewModel.credentialDisplay?.summary {
        Text(summary)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .font(.custom.body)
      }

      HStack(spacing: .x3) {
        if viewModel.environment == .swiyuInt {
          Badge(label: L10n.tkCredentialStatusDemo)
            .badgeStyle(.info)
        }

        HStack(spacing: .x1) {
          viewModel.statusImage
            .resizable()
            .scaledToFit()
            .frame(width: statusImageWidth)
          Text(viewModel.statusText)
            .font(.custom.caption1)
        }
        .foregroundStyle(viewModel.statusColor)
      }
      .padding(.top, 2)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  @ViewBuilder
  private var trailingImage: some View {
    if let disclosureIndicatorImage = disclosureIndicator.image {
      disclosureIndicatorImage
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 6)
        .fontWeight(.bold)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
    }
  }

}

#if DEBUG
#Preview {
  ZStack {
    ThemingAssets.Background.secondary.swiftUIColor.ignoresSafeArea()
    SectionView {
      VerifiableCredentialCell(VerifiableCredentialViewModel(credential: .Mock.sample))
      VerifiableCredentialCell(VerifiableCredentialViewModel(credential: .Mock.sample), disclosureIndicator: .navigation)
    }
  }
}
#endif
