import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - CredentialOfferView

struct CredentialOfferView: View {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, trustInformation: TrustInformation?, state: CredentialOfferViewModel.State = .loading, router: CredentialOfferInternalRoutes, delegate: InvitationDelegate?) {
    self.router = router
    _viewModel = StateObject(wrappedValue: Container.shared.credentialOfferViewModel((credential, trustInformation, state, router, delegate)))
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
    Content(
      declineAction: viewModel.decline,
      acceptAction: {
        Task { await viewModel.accept() }
      },
      wrongDataAction: viewModel.openWrongData,
      cancelDeclineAction: viewModel.cancelDecline,
      confirmDeclineAction: {
        Task { await viewModel.confirmDecline() }
      },
      badgeAction: { badgeType in
        router.badgeInformation(badgeType: badgeType)
      },
      clusters: viewModel.credential.clusters,
      credentialViewModel: viewModel.credentialViewModel,
      state: viewModel.state,
      trustInformation: viewModel.trustInformation)
      .confirmationDialog(L10n.tkReceiveCredentialOfferConfirmIssuancePrimary, isPresented: $viewModel.isUnknownIssuerAlertShown, titleVisibility: .visible) {
        Button(L10n.tkReceiveCredentialOfferConfirmIssuanceButtonSecondary, role: .destructive) {
          Task { await viewModel.confirmDecline() }
        }
        Button(L10n.tkReceiveCredentialOfferConfirmIssuanceButtonPrimary) {
          Task { await viewModel.confirmAccept() }
        }
        Button(L10n.tkGlobalCancel, role: .cancel) { }
      } message: {
        Text(L10n.tkReceiveCredentialOfferConfirmIssuanceSecondary)
      }
      .accessibilityAction(named: L10n.tkReceiveCredentialOfferButtonAccept, {
        Task { await viewModel.accept() }
      })
      .accessibilityAction(named: L10n.tkReceiveCredentialOfferButtonDecline, viewModel.decline)
      .task {
        await viewModel.onAppear()
      }
      .navigationBarHidden(true)
      .onColorSchemeChange { scheme in
        viewModel.updateCredentialViewModel(with: scheme.rawValue)
      }
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @StateObject private var viewModel: CredentialOfferViewModel

  private let router: CredentialOfferInternalRoutes

}

// MARK: CredentialOfferView.Content

extension CredentialOfferView {

  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      declineAction: @escaping () -> Void = { },
      acceptAction: @escaping () -> Void = { },
      wrongDataAction: @escaping () -> Void = { },
      cancelDeclineAction: @escaping () -> Void = { },
      confirmDeclineAction: @escaping () -> Void = { },
      badgeAction: @escaping (BadgeType) -> Void = { _ in },
      clusters: [CredentialClaimCluster],
      credentialViewModel: VerifiableCredentialViewModel?,
      state: CredentialOfferViewModel.State,
      trustInformation: TrustInformation?)
    {
      self.declineAction = declineAction
      self.acceptAction = acceptAction
      self.wrongDataAction = wrongDataAction
      self.cancelDeclineAction = cancelDeclineAction
      self.confirmDeclineAction = confirmDeclineAction
      self.badgeAction = badgeAction
      self.clusters = clusters
      self.credentialViewModel = credentialViewModel
      self.state = state
      self.trustInformation = trustInformation
    }

    // MARK: Internal

    var body: some View {
      content()
        .readSize(onChange: { size in
          compression = UICompressionStyle(height: size.height)
        })
        .ignoresSafeArea(edges: .top)
        .readSafeAreaInsets(onChange: { insets in
          topInset = insets.top
        })
    }

    // MARK: Private

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

    @State private var compression = UICompressionStyle.normal
    @State private var viewport = CGRect.zero
    @State private var topInset = CGFloat.zero

    @Orientation private var orientation

    private let declineAction: () -> Void
    private let acceptAction: () -> Void
    private let wrongDataAction: () -> Void
    private let cancelDeclineAction: () -> Void
    private let confirmDeclineAction: () -> Void
    private let badgeAction: (BadgeType) -> Void
    private let clusters: [CredentialClaimCluster]
    private let credentialViewModel: VerifiableCredentialViewModel?
    private let state: CredentialOfferViewModel.State
    private let trustInformation: TrustInformation?

  }
}

// MARK: - Components

extension CredentialOfferView.Content {

  @ViewBuilder
  private func content() -> some View {
    if orientation.isPortrait {
      portraitLayout()
    } else {
      landscapeLayout()
    }
  }

  private func resultContainer() -> some View {
    VStack(alignment: .leading, spacing: .x4) {
      subtitle()
        .padding(.horizontal, .x6)
      credentialContainer()
      claimsList()
    }
  }

  private func claimsList() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      ClaimClusterList(clusters)
      wrongDataSection()
    }
    .padding(.vertical, .x4)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .clipShape(.rect(cornerRadius: .x9))
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.claimsList.rawValue)
  }

  private func credentialContainer() -> some View {
    VStack {
      Spacer(minLength: compression.isCompressed ? .x4 : .x12)
      if let credentialViewModel {
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
          .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.card.rawValue)
      }
    }
    .padding(.x6)
    .background(ThemingAssets.Background.groupedRow.swiftUIColor)
    .clipShape(.rect(cornerRadius: .x9))
    .accessibilityElement(children: .contain)
    .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }

  private func wrongDataSection() -> some View {
    SectionView {
      IconCell(
        image: Assets.warning.swiftUIImage,
        text: L10n.tkReceiveCredentialOfferWrongDataSectionCellPrimary,
        disclosureIndicator: .navigation, onTap: wrongDataAction)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x6)
        .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.wrongData.rawValue)
    }
  }

  private func loadingContainer() -> some View {
    VStack {
      Spacer(minLength: compression.isCompressed ? .x4 : .x12)
      if let credentialViewModel {
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
    .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.confirmDeclineContent.rawValue)
  }

  @ViewBuilder
  private func issuerHeader() -> some View {
    if let credentialViewModel, let trustInformation {
      ActorHeaderView(issuer: credentialViewModel.issuerDisplay, trustInformation: trustInformation, topInset: topInset) { badgeType in
        badgeAction(badgeType)
      }.accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
    }
  }

  private func subtitle() -> some View {
    Text(L10n.tkReceiveCredentialOfferHeaderSectionSecondary)
      .font(.custom.subheadline)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
  }

  private func footerButtons() -> some View {
    ButtonSheet(colorConfig: .secondary) {
      AdaptiveButtonStack {
        Button { acceptAction() } label: {
          Label(L10n.tkReceiveCredentialOfferButtonAccept, systemImage: "checkmark")
            .multilineTextAlignment(.center)
            .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.tertiary)
        .controlSize(.large)
        .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.acceptButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      } secondary: {
        Button(action: declineAction) {
          Label(L10n.tkReceiveCredentialOfferButtonDecline, systemImage: "xmark")
            .multilineTextAlignment(.center)
            .lineLimit(sizeCategory.isAccessibilityCategory ? 0 : 1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.primary)
        .controlSize(.large)
        .accessibilityLabel(L10n.credentialOfferRefuseButton)
        .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.declineButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
      }
    }
  }

  private func declineButtons() -> some View {
    AdaptiveButtonStack {
      Button { confirmDeclineAction() } label: {
        Text(L10n.tkReceiveDeclineOfferPrimaryButton)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.navyBlue)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkReceiveDeclineOfferPrimaryButton)
      .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.confirmDeclineButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x3.rawValue)
    } secondary: {
      Button(action: cancelDeclineAction) {
        Text(L10n.tkGlobalCancel)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
      }
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor.opacity(0.7))
      .buttonStyle(.plain)
      .controlSize(.large)
      .accessibilityLabel(L10n.tkGlobalCancel)
      .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.cancelDeclineButton.rawValue)
      .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x4.rawValue)
    }
    .frame(maxWidth: 450)
  }
}

// MARK: - Portrait

extension CredentialOfferView.Content {
  private func portraitLayout() -> some View {
    VStack(alignment: .leading, spacing: .x4) {
      issuerHeader()

      switch state {
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
    .if(state == .result) {
      $0.safeAreaInset(edge: .bottom) {
        footerButtons()
      }
    }
    .if(state != .result) {
      $0.ignoresSafeArea(edges: .bottom)
    }
  }
}

// MARK: - Landscape

extension CredentialOfferView.Content {
  @ViewBuilder
  private func landscapeLayout() -> some View {
    switch state {
    case .loading,
         .result:
      credentialLandscapeContainer(isLoading: state == .loading)
    case .decline:
      declineLandscapeContainer()
        .padding(.horizontal, .x3)
    case .error:
      EmptyView()
    }
  }

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

  private func credentialCard() -> some View {
    VStack {
      Spacer()
      VStack {
        if let viewModel = credentialViewModel {
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
            .accessibilityIdentifier(CredentialOfferView.AccessibilityIdentifier.card.rawValue)
        }
      }
      .padding(.x5)
      .background(Color(uiColor: .secondarySystemBackground))
      .clipShape(.rect(cornerRadius: .x9))
      .accessibilityElement(children: .contain)

      Spacer()
    }
    .padding(.leading)
  }

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
  CredentialOfferView
    .Content(
      clusters: CredentialClaimCluster.Mock.arrayWithDisplay,
      credentialViewModel: VerifiableCredentialViewModel(
        credential: .Mock.sample,
        colorScheme: "light"),
      state: .result,
      trustInformation: .Mock.fullyTrusted)
}
#endif
