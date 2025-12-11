import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialCell

public struct VerifiableCredentialCellV1: View {

  // MARK: Lifecycle

  public init(_ viewModel: VerifiableCredentialViewModel, disclosureIndicator: DisclosureIndicator = .none) {
    self.viewModel = viewModel
    self.disclosureIndicator = disclosureIndicator
  }

  // MARK: Public

  public var body: some View {
    HStack(alignment: .center) {
      HStack(alignment: alignment, spacing: .x3) {
        if sizeCategory <= .accessibilityLarge {
          CredentialCard(
            name: viewModel.credentialDisplay?.name,
            summary: viewModel.credentialDisplay?.summary,
            background: viewModel.credentialDisplay?.backgroundColor,
            logoBase64: viewModel.credentialDisplay?.logoBase64,
            environment: viewModel.environment,
            statusBadgeLabel: viewModel.statusText,
            statusBadgeImage: viewModel.statusImage,
            statusBadgeStyle: viewModel.statusBadgeStyle)
            .controlSize(.small)
        }

        VStack(alignment: .leading, spacing: 0) {
          Text(viewModel.credentialDisplay?.name ?? L10n.tkCredentialFallbackTitle)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .font(.custom.body)
          if let summary = viewModel.credentialDisplay?.summary {
            Text(summary)
              .font(.custom.callout)
              .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          }

          HStack(spacing: .x3) {
            if viewModel.environment == .swiyuInt {
              Badge(label: L10n.tkCredentialStatusDemo)
                .badgeStyle(.info)
            }

            HStack(spacing: .x1) {
              viewModel.statusImage
                .aspectRatio(contentMode: .fit)
              Text(viewModel.statusText)
            }
            .foregroundStyle(viewModel.statusColor)
          }
          .font(.custom.caption1)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .padding(.top, 2)
        }
      }

      Spacer()

      if let disclosureIndicatorImage = disclosureIndicator.image {
        disclosureIndicatorImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 6)
          .fontWeight(.bold)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .padding(.trailing, .x3)
      }
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityText)
    .readSize { size in
      alignment = size.height > cellMinHeight ? .top : .center
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  @State private var alignment = VerticalAlignment.center

  private var disclosureIndicator: DisclosureIndicator

  private let viewModel: VerifiableCredentialViewModel
  private let cellMinHeight: CGFloat = 96

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

}
