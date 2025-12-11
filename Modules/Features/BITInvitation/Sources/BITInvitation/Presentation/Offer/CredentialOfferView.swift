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

  init(credential: VerifiableCredential, trustInformation: TrustInformation, state: CredentialOfferViewModel.State = .result, router: CredentialOfferInternalRoutes) {
    self.router = router
    _viewModel = StateObject(wrappedValue: Container.shared.credentialOfferViewModel((credential, trustInformation, state, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "credentialOfferContent"
    case acceptButton
    case declineButton
    case confirmDeclineContent
    case confirmDeclineButton
    case cancelDeclineButton
    case card
    case claimsList
    case wrongData
  }

  var body: some View {
    content()
      .confirmationDialog(L10n.tkReceiveCredentialOfferConfirmIssuancePrimary, isPresented: $viewModel.isUnknownIssuerAlertShown, titleVisibility: .visible) {
        Button(L10n.tkReceiveCredentialOfferConfirmIssuanceButtonSecondary, role: .destructive) {
          Task { await viewModel.send(event: .confirmDecline) }
        }
        Button(L10n.tkReceiveCredentialOfferConfirmIssuanceButtonPrimary) {
          Task { await viewModel.send(event: .confirmAccept) }
        }
        Button(L10n.tkGlobalCancel, role: .cancel) { }
      } message: {
        Text(L10n.tkReceiveCredentialOfferConfirmIssuanceSecondary)
      }
      .accessibilityAction(named: L10n.tkReceiveCredentialOfferButtonAccept, {
        Task { await viewModel.send(event: .accept) }
      })
      .accessibilityAction(named: L10n.tkReceiveCredentialOfferButtonDecline, {
        Task { await viewModel.send(event: .decline) }
      })
      .ignoresSafeArea(edges: .top)
      .readSize(onChange: { size in
        compression = UICompressionStyle(height: size.height)
      })
      .readSafeAreaInsets(onChange: { insets in
        topInset = insets.top
      })
      .navigationBarHidden(true)
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory
  @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

  @State private var compression = UICompressionStyle.normal
  @State private var viewport = CGRect.zero
  @State private var topInset = CGFloat.zero

  @StateObject private var viewModel: CredentialOfferViewModel

  private let router: CredentialOfferInternalRoutes

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
  private func resultContainer() -> some View {
    VStack(alignment: .leading, spacing: .x4) {
      subtitle()
        .padding(.horizontal, .x6)
      credentialContainer()
      claimsList()
    }
  }

  @ViewBuilder
  private func claimsList() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      ClaimClusterList(viewModel.credential.clusters)
      wrongDataSection()
    }
    .padding(.vertical, .x4)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .clipShape(.rect(cornerRadius: .CornerRadius.xl))
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.claimsList.rawValue)
  }

  @ViewBuilder
  private func credentialContainer() -> some View {
    VStack {
      Spacer(minLength: compression.isCompressed ? .x4 : .x12)
      if let credentialViewModel = viewModel.credentialViewModel {
        CredentialCard(
          name: credentialViewModel.credentialDisplay?.name,
          summary: credentialViewModel.credentialDisplay?.summary,
          background: credentialViewModel.credentialDisplay?.backgroundColor,
          logoBase64: credentialViewModel.credentialDisplay?.logoBase64,
          environment: credentialViewModel.environment,
          statusBadgeLabel: credentialViewModel.statusText,
          statusBadgeImage: credentialViewModel.statusImage,
          statusBadgeStyle: credentialViewModel.statusBadgeStyle)
          .padding(.horizontal, .x10)
          .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
      }
    }
    .padding(.x6)
    .background(ThemingAssets.Background.groupedRow.swiftUIColor)
    .clipShape(.rect(cornerRadius: .CornerRadius.xl))
    .accessibilityElement(children: .contain)
    .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }

  @ViewBuilder
  private func wrongDataSection() -> some View {
    SectionView {
      IconCell(
        image: Assets.warning.swiftUIImage,
        text: L10n.tkReceiveCredentialOfferWrongDataSectionCellPrimary,
        disclosureIndicator: .navigation)
      {
        Task { await viewModel.send(event: .openWrongData) }
      }
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .padding(.horizontal, .x6)
      .accessibilityIdentifier(AccessibilityIdentifier.wrongData.rawValue)
    }
  }

  @ViewBuilder
  private func loadingContainer() -> some View {
    VStack {
      Spacer(minLength: compression.isCompressed ? .x4 : .x12)
      if let credentialViewModel = viewModel.credentialViewModel {
        CredentialCard(
          name: credentialViewModel.credentialDisplay?.name,
          summary: credentialViewModel.credentialDisplay?.summary,
          background: credentialViewModel.credentialDisplay?.backgroundColor,
          logoBase64: credentialViewModel.credentialDisplay?.logoBase64,
          environment: credentialViewModel.environment,
          statusBadgeLabel: credentialViewModel.statusText,
          statusBadgeImage: credentialViewModel.statusImage,
          statusBadgeStyle: credentialViewModel.statusBadgeStyle)
          .padding(.horizontal, .x10)
          .accessibilityHidden(true)
      }
      Spacer(minLength: compression.isCompressed ? .x6 : .x12)

      ProgressView()
        .controlSize(.large)
        .padding(.bottom, .x10)
    }
    .padding(.x6)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    .accessibilityElement(children: .contain)
  }

  @ViewBuilder
  private func declineContainer() -> some View {
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
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x1.rawValue)
        Text(L10n.tkReceiveDeclineOfferSecondary)
          .multilineTextAlignment(.center)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor.opacity(0.8))
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x2.rawValue)
      }
      Spacer()

      declineButtons()
        .padding(.top, .x4)
    }
    .padding(.vertical, compression.isCompressed ? .x2 : .x6)
    .frame(maxWidth: .infinity)
    .padding(compression.isCompressed ? .x4 : .x6)
    .background(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
    .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.confirmDeclineContent.rawValue)
  }

  @ViewBuilder
  private func issuerHeader() -> some View {
    if let credentialViewModel = viewModel.credentialViewModel {
      ActorHeaderView(issuer: credentialViewModel.issuerDisplay, trustInformation: viewModel.trustInformation, topInset: topInset) { badgeType in
        router.badgeInformation(badgeType: badgeType)
      }.accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
    }
  }

  @ViewBuilder
  private func subtitle() -> some View {
    Text(L10n.tkReceiveCredentialOfferHeaderSectionSecondary)
      .font(.custom.subheadline)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
  }

  @ViewBuilder
  private func footerButtons() -> some View {
    ButtonSheet(colorConfig: .secondary) {
      AdaptiveButtonStack {
        Button { Task { await viewModel.send(event: .accept) } } label: {
          Label(L10n.tkReceiveCredentialOfferButtonAccept, systemImage: "checkmark")
            .multilineTextAlignment(.center)
            .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.tertiary)
        .controlSize(.large)
        .accessibilityIdentifier(AccessibilityIdentifier.acceptButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      } secondary: {
        Button { Task { await viewModel.send(event: .decline) } } label: {
          Label(L10n.tkReceiveCredentialOfferButtonDecline, systemImage: "xmark")
            .multilineTextAlignment(.center)
            .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.primary)
        .controlSize(.large)
        .accessibilityLabel(L10n.credentialOfferRefuseButton)
        .accessibilityIdentifier(AccessibilityIdentifier.declineButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
      }
    }
  }

  @ViewBuilder
  private func declineButtons() -> some View {
    AdaptiveButtonStack {
      Button { Task { await viewModel.send(event: .confirmDecline) } } label: {
        Text(L10n.tkReceiveDeclineOfferPrimaryButton)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.navyBlue)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkReceiveDeclineOfferPrimaryButton)
      .accessibilityIdentifier(AccessibilityIdentifier.confirmDeclineButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x3.rawValue)
    } secondary: {
      Button { Task { await viewModel.send(event: .cancelDecline) } } label: {
        Text(L10n.tkGlobalCancel)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor.opacity(0.7))
      .buttonStyle(.plain)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkGlobalCancel)
      .accessibilityIdentifier(AccessibilityIdentifier.cancelDeclineButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x4.rawValue)
    }
    .frame(maxWidth: 450)
  }
}

// MARK: - Portrait

extension CredentialOfferView {
  @ViewBuilder
  private func portraitLayout() -> some View {
    VStack(alignment: .leading, spacing: .x4) {
      issuerHeader()

      switch viewModel.state {
      case .result:
        resultContainer()
      case .loading:
        loadingContainer()
      case .decline:
        declineContainer()
      case .error:
        EmptyView()
      }
    }
    .applyScrollViewIfNeeded()
    .if(viewModel.state == .result) {
      $0.safeAreaInset(edge: .bottom) {
        footerButtons()
      }
    }
    .if(viewModel.state != .result) {
      $0.ignoresSafeArea(edges: .bottom)
    }
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
      credentialCard()
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
      if isLoading {
        ProgressView()
          .controlSize(.large)
          .frame(maxWidth: .infinity)
      } else {
        VStack(alignment: .leading, spacing: 0) {
          issuerHeader()
            .padding(.bottom, .x3)
          subtitle()
            .padding(.horizontal, .x2)
            .padding(.bottom, .x4)
          claimsList()
          Spacer() // Pushes buttons down if VStack is not filling screen
        }
        .applyScrollViewIfNeeded()
        .safeAreaInset(edge: .bottom) {
          footerButtons()
        }
      }
    }
  }

  @ViewBuilder
  private func credentialCard() -> some View {
    VStack {
      Spacer()
      VStack {
        if let viewModel = viewModel.credentialViewModel {
          CredentialCard(
            name: viewModel.credentialDisplay?.name,
            summary: viewModel.credentialDisplay?.summary,
            background: viewModel.credentialDisplay?.backgroundColor,
            logoBase64: viewModel.credentialDisplay?.logoBase64,
            environment: viewModel.environment,
            statusBadgeLabel: viewModel.statusText,
            statusBadgeImage: viewModel.statusImage,
            statusBadgeStyle: viewModel.statusBadgeStyle)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
            .accessibilityIdentifier(AccessibilityIdentifier.card.rawValue)
        }
      }
      .padding(.x5)
      .background(Color(uiColor: .secondarySystemBackground))
      .clipShape(.rect(cornerRadius: .CornerRadius.xl))
      .accessibilityElement(children: .contain)

      Spacer()
    }
    .padding(.leading)
  }

  @ViewBuilder
  private func declineLandscapeContainer() -> some View {
    VStack(spacing: 0) {
      issuerHeader()
        .padding(.bottom, .x3)
      subtitle()
        .padding(.bottom, .x4)
      declineContainer()
    }
    .applyScrollViewIfNeeded()
    .ignoresSafeArea(edges: .bottom)
  }

}

#if DEBUG
#Preview {
  CredentialOfferView(credential: .Mock.sample, trustInformation: .Mock.trustedIdentity, state: .result, router: CredentialOfferRouter())
}
#endif
