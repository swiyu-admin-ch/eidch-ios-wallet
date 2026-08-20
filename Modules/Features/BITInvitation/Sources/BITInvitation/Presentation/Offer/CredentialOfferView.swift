import BITCredential
import BITCredentialShared
import BITL10n
import BITNavigation
import BITNonCompliance
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - CredentialOfferView

struct CredentialOfferView: View {

  // MARK: Lifecycle

  init(credential: VerifiableCredential, state: CredentialOfferViewModel.State = .loading) {
    _viewModel = State(wrappedValue: Container.shared.credentialOfferViewModel((credential, state)))
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
  }

  var body: some View {
    let isAlertPresented = Binding(
      get: { viewModel.alert != nil },
      set: { if !$0 { viewModel.alert = nil } })

    Content(
      declineAction: viewModel.decline,
      acceptAction: {
        Task { await viewModel.accept() }
      },
      cancelDeclineAction: viewModel.cancelDecline,
      confirmDeclineAction: {
        Task { await viewModel.confirmDecline() }
      },
      actorInformationAction: { actorInformation in
        navigator.navigate(to: InvitationDestinations.actorInformation(actorInformation))
      },
      clusters: viewModel.credential.resolvedClusters,
      credentialViewModel: viewModel.credentialViewModel,
      state: viewModel.state,
      trustInformation: viewModel.trustInformation,
      actorCompliance: viewModel.actorCompliance)
      .navigate(to: $viewModel.destination)
      .navigationReturnToCheckpoint(trigger: $viewModel.isOfferAccepted, checkpoint: Checkpoints.home, value: HomeCheckpointsState.acceptCredential)
      .navigationReturnToCheckpoint(trigger: $viewModel.isOfferDeclined, checkpoint: Checkpoints.home, value: HomeCheckpointsState.declineCredential)
      .confirmationDialog(viewModel.alert?.title ?? "", isPresented: isAlertPresented, titleVisibility: .visible) {
        Button(L10n.tkReceiveCredentialOfferConfirmIssuanceButtonSecondary, role: .destructive) {
          Task { await viewModel.confirmDecline() }
        }
        Button(L10n.tkReceiveCredentialOfferConfirmIssuanceButtonPrimary) {
          Task { await viewModel.accept(force: true) }
        }
        Button(L10n.tkGlobalCancel, role: .cancel) {}
      } message: {
        if let alert = viewModel.alert {
          Text(alert.message)
        }
      }
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

  @Environment(\.navigator) private var navigator: Navigator
  @State private var viewModel: CredentialOfferViewModel
}

// MARK: CredentialOfferView.Content

extension CredentialOfferView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      declineAction: @escaping () -> Void = {},
      acceptAction: @escaping () -> Void = {},
      cancelDeclineAction: @escaping () -> Void = {},
      confirmDeclineAction: @escaping () -> Void = {},
      actorInformationAction: @escaping (ActorInformation) -> Void = { _ in },
      clusters: [CredentialClaimCluster],
      credentialViewModel: VerifiableCredentialViewModel?,
      state: CredentialOfferViewModel.State,
      trustInformation: TrustInformation?,
      actorCompliance: ActorCompliance = .compliant)
    {
      self.declineAction = declineAction
      self.acceptAction = acceptAction
      self.cancelDeclineAction = cancelDeclineAction
      self.confirmDeclineAction = confirmDeclineAction
      self.actorInformationAction = actorInformationAction
      self.clusters = clusters
      self.credentialViewModel = credentialViewModel
      self.state = state
      self.trustInformation = trustInformation
      self.actorCompliance = actorCompliance
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
        .accessibilityHidden(state == .loading)
        .onAppear {
          if state == .loading {
            announceLoading()
          }
        }
        .onChange(of: state) { _, newState in
          if newState == .loading {
            announceLoading()
          } else {
            cancelLoadingAnnouncement()
          }
        }
    }

    // MARK: Private

    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverEnabled

    @State private var compression = UICompressionStyle.normal
    @State private var viewport = CGRect.zero
    @State private var topInset = CGFloat.zero
    @State private var hasAnnouncedInitialLoading = false
    @State private var hasAnnouncedLongRunning = false
    @State private var longRunningAnnouncementTask: Task<Void, Never>?

    @Orientation private var orientation

    private let declineAction: () -> Void
    private let acceptAction: () -> Void
    private let cancelDeclineAction: () -> Void
    private let confirmDeclineAction: () -> Void
    private let actorInformationAction: (ActorInformation) -> Void
    private let clusters: [CredentialClaimCluster]
    private let credentialViewModel: VerifiableCredentialViewModel?
    private let state: CredentialOfferViewModel.State
    private let trustInformation: TrustInformation?
    private let actorCompliance: ActorCompliance
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
        .accessibilityRespondsToUserInteraction(false)
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
    .accessibilityRespondsToUserInteraction(false)
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
          .accessibilityRespondsToUserInteraction(false)
        Text(L10n.tkReceiveDeclineOfferSecondary)
          .multilineTextAlignment(.center)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor.opacity(0.8))
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue + AccessibilityPriority.x2.rawValue)
          .accessibilityRespondsToUserInteraction(false)
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
      ActorHeaderView(
        issuer: credentialViewModel.issuerDisplay,
        trustInformation: trustInformation,
        actorCompliance: actorCompliance,
        topInset: topInset,
        onTapped: { actorInformation in
          guard state != .loading else { return }
          actorInformationAction(actorInformation)
        })
        .disabled(state == .loading)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
        .accessibilityPriorityFocus()
    }
  }

  private func subtitle() -> some View {
    Text(L10n.tkReceiveCredentialOfferHeaderSectionSecondary)
      .font(.custom.subheadline)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      .accessibilityRespondsToUserInteraction(false)
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

// MARK: - Accessibility Announcement

extension CredentialOfferView.Content {
  private func announceLoading() {
    guard isVoiceOverEnabled else { return }
    guard !hasAnnouncedInitialLoading else { return }

    hasAnnouncedInitialLoading = true
    postLoadingAnnouncement(L10n.tkGlobalPleasewait)

    longRunningAnnouncementTask?.cancel()
    longRunningAnnouncementTask = Task { @MainActor in
      try? await Task.sleep(for: .seconds(10))
      guard !Task.isCancelled else { return }
      guard !hasAnnouncedLongRunning else { return }

      hasAnnouncedLongRunning = true
      postLoadingAnnouncement(L10n.tkGlobalStillworking)
    }
  }

  private func postLoadingAnnouncement(_ message: String) {
    AccessibilityNotification.Announcement(AttributedString(message)).post()
  }

  private func postHighPriorityAnnouncement(_ message: String) {
    var announcement = AttributedString(message)
    announcement.accessibilitySpeechAnnouncementPriority = .high
    AccessibilityNotification.Announcement(announcement).post()
  }

  private func cancelLoadingAnnouncement() {
    longRunningAnnouncementTask?.cancel()
    longRunningAnnouncementTask = nil
    hasAnnouncedInitialLoading = false
    hasAnnouncedLongRunning = false
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
      credentialLandscapeContainer()
    case .decline:
      declineLandscapeContainer()
        .padding(.horizontal, .x3)
    case .error:
      EmptyView()
    }
  }

  private func credentialLandscapeContainer() -> some View {
    HStack(spacing: .x5) {
      credentialCard()
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)

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
      .accessibilityRespondsToUserInteraction(false)

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
