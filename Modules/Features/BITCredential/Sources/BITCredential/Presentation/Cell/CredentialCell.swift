import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import SwiftUI

// MARK: - CredentialCell

public struct CredentialCell: View {

  // MARK: Lifecycle

  public init(_ credential: Credential, disclosureIndicator: DisclosureIndicator = .none) {
    self.credential = credential
    self.disclosureIndicator = disclosureIndicator
  }

  // MARK: Public

  public var body: some View {
    VStack {
      HStack(alignment: .center) {
        HStack(alignment: alignment, spacing: .x3) {
          if sizeCategory <= .accessibilityLarge {
            CredentialCard(credential)
              .controlSize(.small)
          }

          VStack(alignment: .leading, spacing: 0) {
            Text(credential.preferredDisplay?.name ?? L10n.tkCredentialFallbackTitle)
              .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
              .font(.custom.body)
            if let summary = credential.preferredDisplay?.summary {
              Text(summary)
                .font(.custom.callout)
                .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
            }

            HStack(spacing: .x3) {
              if credential.environment == .demo {
                Badge {
                  Text(L10n.tkCredentialStatusDemo)
                }
                .badgeStyle(.bezeledGray)
                .controlSize(.small)
                .colorScheme(.light)
                .accessibilityLabel(L10n.tkCredentialStatusDemoAlt)
              }

              HStack(spacing: .x1) {
                credential.statusImage
                  .aspectRatio(contentMode: .fit)
                Text(credential.statusText)
              }
              .foregroundStyle(credential.statusColor)
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
      .readSize { size in
        alignment = size.height > cellMinHeight ? .top : .center
      }
    }
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory

  @State private var alignment = VerticalAlignment.center

  private var disclosureIndicator: DisclosureIndicator

  private let credential: Credential
  private let cellMinHeight: CGFloat = 96

}
