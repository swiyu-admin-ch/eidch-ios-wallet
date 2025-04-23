import BITCredential
import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - CredentialOfferView

struct CredentialOfferView: View {

  // MARK: Lifecycle

  init(credential: Credential, trustStatement: TrustStatement?, state: CredentialOfferViewModel.State = .result, router: CredentialOfferInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.credentialOfferViewModel((credential, trustStatement, state, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case acceptButton
    case declineButton
    case bottomAcceptButton
    case bottomDeclineButton
    case confirmDeclineButton
    case cancelDeclineButton
    case card
    case details
  }

  var body: some View {
    content()
      .accessibilityAction(named: L10n.credentialOfferAcceptButton, {
        Task { await viewModel.send(event: .accept) }
      })
      .accessibilityAction(named: L10n.credentialOfferRefuseButton, {
        Task { await viewModel.send(event: .decline) }
      })
      .readSize(onChange: { size in
        compression = UICompressionStyle(height: size.height)
      })
      .navigationBarHidden(true)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory
  @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

  @State private var compression = UICompressionStyle.normal
  @State private var viewport = CGRect.zero

  @StateObject private var viewModel: CredentialOfferViewModel

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    if orientation.isPortrait {
      portraitLayout()
    } else {
      landscapeLayout()
    }
  }
}

// MARK: - Components

extension CredentialOfferView {

  @ViewBuilder
  private func claimsList() -> some View {
    VStack(alignment: .leading, spacing: .x10) {
      VStack(alignment: .leading) {
        Text(L10n.tkReceiveCredentialOfferContentSectionPrimary)
          .font(.custom.body)
          .padding(.top, .x4)
          .padding(.leading, .x6)

        Divider()

        LazyVStack {
          CredentialOfferClaimListView(viewModel.credentialBody.claims)
        }
        .padding(.leading, .x6)
      }

      VStack(alignment: .leading) {
        Divider()
        IconKeyValueCell(key: "", value: L10n.tkReceiveCredentialOfferWrongDataSectionCellPrimary, image: Assets.warning.swiftUIImage, disclosureIndicator: Image(systemName: "chevron.right"), onTap: { Task { await viewModel.send(event: .openWrongData) } })
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .padding(.leading, .x6)
      }

      if orientation.isPortrait || sizeCategory.isAccessibilityCategory {
        footerButtons()
          .padding(.x6)
          .accessibilityElement(children: .contain)
      }
    }
    .accessibilityElement(children: .contain)
    .accessibilityLabel(L10n.tkReceiveCredentialOfferContentSectionPrimary)
    .accessibilitySortPriority(10)
  }

  @ViewBuilder
  private func credentialContainer() -> some View {
    VStack {
      Spacer(minLength: compression.isCompressed ? .x4 : .x12)
      CredentialCard(viewModel.credential)
        .padding(.horizontal, .x10)
        .accessibilityHidden(true)
        .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
      Spacer(minLength: compression.isCompressed ? .x6 : .x12)

      footerButtons(addAccessibilityIdentifier: true)
        .accessibilityElement(children: .contain)
    }
    .padding(.x6)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .clipShape(.rect(cornerRadius: .x8))
    .accessibilityElement(children: .contain)
    .accessibilitySortPriority(500)
  }

  @ViewBuilder
  private func loadingContainer() -> some View {
    VStack {
      Spacer()
      VStack {
        VStack {
          Spacer(minLength: compression.isCompressed ? .x4 : .x12)
          CredentialCard(viewModel.credential)
            .padding(.horizontal, .x10)
            .accessibilityHidden(true)
            .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
          Spacer(minLength: compression.isCompressed ? .x6 : .x12)

          ProgressView()
            .controlSize(.large)
            .padding(.bottom, .x10)
        }
        .padding(.vertical, .x6)
      }
      .padding(.x6)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
      .ignoresSafeArea(edges: .bottom)
      .accessibilityElement(children: .contain)
    }
  }

  @ViewBuilder
  private func declineContainer() -> some View {
    VStack {
      Spacer()
      VStack {
        VStack {
          Spacer()
          VStack(spacing: .x3) {
            if sizeCategory < .accessibilityExtraLarge {
              Image(systemName: "questionmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 56, height: 56)
                .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
                .font(Font.title.weight(.ultraLight))
                .accessibilityHidden(true)
            }

            Text(L10n.tkReceiveDeclineOfferPrimary)
              .multilineTextAlignment(.center)
              .font(.custom.bodyEmphasized)
              .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
              .accessibilitySortPriority(1000)
            Text(L10n.tkReceiveDeclineOfferSecondary)
              .multilineTextAlignment(.center)
              .font(.custom.body)
              .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor.opacity(0.8))
              .accessibilitySortPriority(900)
          }
          Spacer()

          declineButtons(addAccessibilityIdentifier: true)
            .padding(.top, .x4)
        }
        .padding(.vertical, compression.isCompressed ? .x2 : .x6)
      }
      .frame(maxWidth: .infinity)
      .padding(compression.isCompressed ? .x4 : .x6)
      .background(ThemingAssets.Brand.Core.navyBlue.swiftUIColor.ignoresSafeArea(edges: .bottom))
      .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
      .ignoresSafeArea(edges: .bottom)
      .accessibilityElement(children: .contain)
    }
  }

  @ViewBuilder
  private func issuerHeader() -> some View {
    if let issuer = viewModel.issuerDisplay {
      ActorHeaderView(issuer: issuer, trustStatus: viewModel.issuerTrustStatus)
        .accessibilitySortPriority(500)
    }
  }

  @ViewBuilder
  private func subtitle() -> some View {
    Text(L10n.tkReceiveCredentialOfferHeaderSectionSecondary)
      .font(.custom.title3)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilityIdentifier(AccessibilityIdentifier.details.rawValue)
  }

  @ViewBuilder
  private func footerButtons(addAccessibilityIdentifier: Bool = false) -> some View {
    VStack {
      ButtonStackView {
        Button { Task { await viewModel.send(event: .decline) } } label: {
          Label(L10n.tkReceiveCredentialOfferButtonDecline, systemImage: "xmark")
            .multilineTextAlignment(.center)
            .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.filledPrimary)
        .controlSize(.large)
        .accessibilityLabel(L10n.credentialOfferRefuseButton)
        .accessibilityIdentifier(addAccessibilityIdentifier ? AccessibilityIdentifier.declineButton.rawValue : AccessibilityIdentifier.bottomDeclineButton.rawValue)
        .accessibilitySortPriority(50)

        Button { Task { await viewModel.send(event: .accept) } } label: {
          Label(L10n.tkReceiveCredentialOfferButtonAccept, systemImage: "checkmark")
            .multilineTextAlignment(.center)
            .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.filledSecondary)
        .controlSize(.large)
        .accessibilityLabel(L10n.credentialOfferAcceptButton)
        .accessibilityIdentifier(addAccessibilityIdentifier ? AccessibilityIdentifier.acceptButton.rawValue : AccessibilityIdentifier.bottomAcceptButton.rawValue)
        .accessibilitySortPriority(100)
      }
    }
  }

  @ViewBuilder
  private func declineButtons(addAccessibilityIdentifier: Bool = false) -> some View {
    ButtonStackView {
      Button { Task { await viewModel.send(event: .confirmDecline) } } label: {
        Text(L10n.tkReceiveDeclineOfferPrimaryButton)
          .multilineTextAlignment(.center)
          .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bezeledLightReversed)
      .preferredColorScheme(.light)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkReceiveDeclineOfferPrimaryButton)
      .accessibilityIdentifier(addAccessibilityIdentifier ? AccessibilityIdentifier.confirmDeclineButton.rawValue : "")
      .accessibilitySortPriority(100)

      Button { Task { await viewModel.send(event: .cancelDecline) } } label: {
        Text(L10n.tkGlobalCancel)
          .multilineTextAlignment(.center)
          .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
          .frame(maxWidth: .infinity)
      }
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor.opacity(0.7))
      .buttonStyle(.plain)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkGlobalCancel)
      .accessibilityIdentifier(addAccessibilityIdentifier ? AccessibilityIdentifier.cancelDeclineButton.rawValue : "")
      .accessibilitySortPriority(50)
    }
    .frame(maxWidth: 450)
  }
}

// MARK: - Portrait

extension CredentialOfferView {
  @ViewBuilder
  private func portraitLayout() -> some View {
    VStack(alignment: .leading) {
      VStack(spacing: .x4) {
        issuerHeader()
        subtitle()
      }
      .padding(.horizontal, .x6)
      .padding(.top, .x3)

      switch viewModel.state {
      case .result:
        credentialContainer()
        claimsList()
      case .loading:
        loadingContainer()
      case .decline:
        declineContainer()
      case .error:
        EmptyView()
      }
    }
    .applyScrollViewIfNeeded()
  }

}

// MARK: - Landscape

extension CredentialOfferView {
  @ViewBuilder
  private func landscapeLayout() -> some View {
    switch viewModel.state {
    case .loading,
         .result:
      credentialLandscapeContainer(isLoading: viewModel.state == .loading)
    case .decline:
      declineLandscapeContainer()
        .padding(.horizontal, .x3)
    case .error:
      EmptyView()
    }
  }

  @ViewBuilder
  private func credentialLandscapeContainer(isLoading: Bool) -> some View {
    HStack(spacing: .x5) {
      credentialCard().accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
      if isLoading {
        ProgressView()
          .controlSize(.large)
          .frame(maxWidth: .infinity)
      } else {
        VStack(alignment: .leading, spacing: .x6) {
          issuerHeader()
          subtitle()
          claimsList()
          Spacer() // Pushes buttons down if VStack is not filling screen
        }
        .padding(.top, .x4)
        .applyScrollViewIfNeeded()
        .safeAreaInset(edge: .bottom) {
          if !sizeCategory.isAccessibilityCategory {
            footerButtons()
              .padding(.x3)
              .background(ThemingAssets.Background.primary.swiftUIColor)
          }
        }
      }
    }
  }

  @ViewBuilder
  private func credentialCard() -> some View {
    VStack {
      Spacer()
      VStack {
        CredentialCard(viewModel.credential)
          .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
          .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
      }
      .padding(.x5)
      .background(Color(uiColor: .secondarySystemBackground))
      .clipShape(.rect(cornerRadius: .x8))
      .accessibilityElement(children: .contain)

      Spacer()
    }
    .padding(.leading)
  }

  @ViewBuilder
  private func declineLandscapeContainer() -> some View {
    VStack {
      issuerHeader()
      subtitle()
      declineContainer()
    }
    .padding(.top, .x4)
    .applyScrollViewIfNeeded()
    .ignoresSafeArea(edges: .bottom)
  }

}

#if DEBUG
#Preview {
  CredentialOfferView(credential: .Mock.sample, trustStatement: nil, state: .result, router: CredentialOfferRouter())
}
#endif
