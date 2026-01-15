import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - PresentationRequestReviewView

struct PresentationRequestReviewView: View {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationInternalRoutes) {
    self.router = router
    _viewModel = StateObject(wrappedValue: Container.shared.presentationRequestReviewViewModel((context, router)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "presentationRequestReviewContent"
    case acceptButton
    case denyButton
  }

  var body: some View {
    Content(
      state: viewModel.state,
      isUnknownAlertPresented: $viewModel.isUnknownVerifierAlertShown,
      isSessionTimeoutPresented: $viewModel.isSessionTimeoutPresented,
      eventAction: { event in Task { await viewModel.send(event) } },
      badgeAction: { badgeType in router.badgeInformation(badgeType: badgeType) })
      .onColorSchemeChange { scheme in
        viewModel.updateCredential(with: scheme.rawValue)
      }
  }

  // MARK: Private

  @StateObject private var viewModel: PresentationRequestReviewViewModel

  private let router: PresentationInternalRoutes
}

// MARK: PresentationRequestReviewView.Content

extension PresentationRequestReviewView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      state: PresentationRequestReviewState,
      isUnknownAlertPresented: Binding<Bool>,
      isSessionTimeoutPresented: Binding<Bool>,
      eventAction: @escaping (PresentationRequestReviewViewModel.Event) -> Void = { _ in },
      badgeAction: @escaping (BadgeType) -> Void = { _ in })
    {
      self.state = state
      self.isUnknownAlertPresented = isUnknownAlertPresented
      self.isSessionTimeoutPresented = isSessionTimeoutPresented
      self.eventAction = eventAction
      self.badgeAction = badgeAction
    }

    // MARK: Internal

    var body: some View {
      stateView
        .landscapeMaxWidth()
        .ignoresSafeArea(edges: .top)
        .readSafeAreaInsets(onChange: { insets in
          topInset = insets.top
        })
        .navigationBarHidden(true)
        .frame(maxWidth: .infinity)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(PresentationRequestReviewView.AccessibilityIdentifier.content.rawValue)
    }

    // MARK: Private

    @State private var topInset: CGFloat = 0

    private let state: PresentationRequestReviewState
    private let isUnknownAlertPresented: Binding<Bool>
    private let isSessionTimeoutPresented: Binding<Bool>
    private let eventAction: (PresentationRequestReviewViewModel.Event) -> Void
    private let badgeAction: (BadgeType) -> Void

    @ViewBuilder
    private var stateView: some View {
      switch state {
      case .loading:
        loadingView()
      case .result(let viewState):
        resultView(viewState)
      case .processing(let viewState):
        processingView(viewState)
      }
    }

    @ViewBuilder
    private func loadingView() -> some View {
      VStack {
        Spacer()
        ProgressView()
          .controlSize(.large)
        Spacer()
      }
    }

    @ViewBuilder
    private func actorHeader(_ verifierDisplay: VerifierDisplay) -> some View {
      ActorHeaderView(verifier: verifierDisplay, topInset: topInset, onBadgeTapped: badgeAction)
    }
  }
}

// MARK: - Result

extension PresentationRequestReviewView.Content {
  @ViewBuilder
  private func resultView(_ viewState: PresentationRequestReviewState.Result) -> some View {
    VStack(alignment: .leading, spacing: .x4) {
      actorHeader(viewState.verifierDisplay)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      SectionView(title: L10n.tkPresentReviewCredentialDataSectionPrimary) {
        CredentialSummaryWidget(credential: viewState.credential, claimBadges: viewState.claimBadges, badgeAction: badgeAction)
      }
      .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)

      ClaimClusterList(viewState.clusters)
        .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
      Spacer()
    }
    .applyScrollViewIfNeeded()
    .safeAreaInset(edge: .bottom) {
      footerButtons(
        submitAction: { force in eventAction(.submit(viewState, force)) },
        denyAction: { eventAction(.deny) })
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue) // not fully working for now...
        .accessibilityElement(children: .contain)
    }
    .confirmationDialog(L10n.tkPresentReviewConfirmPresentationPrimary, isPresented: isUnknownAlertPresented, titleVisibility: .visible) {
      Button(L10n.tkPresentReviewConfirmPresentationButtonSecondary, role: .destructive) {
        eventAction(.deny)
      }
      Button(L10n.tkPresentReviewConfirmPresentationButtonPrimary) {
        eventAction(.submit(viewState, true))
      }
      Button(L10n.tkGlobalCancel, role: .cancel) { }
    } message: {
      Text(L10n.tkPresentReviewConfirmPresentationSecondary)
    }
    .alert(isPresented: isSessionTimeoutPresented) {
      Alert(
        title: Text(L10n.tkPresentReviewSessionTimeoutTitle),
        message: Text(L10n.tkPresentReviewSessionTimeoutBody),
        primaryButton: .default(Text(L10n.tkPresentReviewSessionTimeoutPrimaryButton), action: { eventAction(.login) }),
        secondaryButton: .cancel(Text(L10n.tkGlobalCancel)))
    }
    .accessibilityAction(named: L10n.tkPresentReviewPrimaryButtonAlt) {
      eventAction(.submit(viewState, true))
    }
    .accessibilityAction(named: L10n.tkPresentReviewSecondaryButtonAlt) {
      eventAction(.deny)
    }
  }

  @ViewBuilder
  private func footerButtons(submitAction: @escaping (Bool) -> Void, denyAction: @escaping () -> Void) -> some View {
    ButtonSheet(colorConfig: .secondary) {
      AdaptiveButtonStack {
        Button { submitAction(false) } label: {
          Label(L10n.tkPresentReviewPrimaryButton, systemImage: "checkmark")
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .accessibilityLabel(L10n.tkPresentReviewPrimaryButtonAlt)
        }
        .buttonStyle(.tertiary)
        .controlSize(.large)
        .accessibilityIdentifier(PresentationRequestReviewView.AccessibilityIdentifier.acceptButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      } secondary: {
        Button(action: denyAction) {
          Label(L10n.tkPresentReviewSecondaryButton, systemImage: "xmark")
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .accessibilityLabel(L10n.tkPresentReviewSecondaryButtonAlt)
        }
        .buttonStyle(.primary)
        .controlSize(.large)
        .accessibilityIdentifier(PresentationRequestReviewView.AccessibilityIdentifier.denyButton.rawValue)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
      }
    }
  }
}

// MARK: - Processing

extension PresentationRequestReviewView.Content {

  @ViewBuilder
  private func processingView(_ viewState: PresentationRequestReviewState.Processing) -> some View {
    VStack {
      actorHeader(viewState.verifierDisplay)
        .padding(.bottom, .x3)

      VStack {
        Spacer()
        HStack(spacing: .x3) {
          Spacer()
          CredentialCard(
            name: viewState.credential.credentialDisplay?.name,
            summary: viewState.credential.credentialDisplay?.summary,
            background: viewState.credential.credentialDisplay?.backgroundColor,
            logoBase64: viewState.credential.credentialDisplay?.logoBase64,
            environment: viewState.credential.environment)
            .controlSize(.small)
          Spacer()
        }
        Spacer(minLength: .x4)
        loader(isMessagePresented: viewState.isMessagePresented)
      }
      .padding(.bottom, .x10)
      .padding(.horizontal, .x6)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    }
    .applyScrollViewIfNeeded()
    .ignoresSafeArea(edges: .bottom)
  }

  @ViewBuilder
  private func loader(isMessagePresented: Bool) -> some View {
    VStack(spacing: .x3) {
      ProgressView()
        .controlSize(.large)

      if isMessagePresented {
        Text(L10n.tkPresentReviewLoading)
          .font(.custom.body)
          .accessibilityLabel(L10n.tkPresentReviewLoadingAlt)
      }
    }
    .animation(.default, value: isMessagePresented)
  }
}

#if DEBUG
#Preview {
  PresentationRequestReviewView.Content(state: .Mock.result, isUnknownAlertPresented: .constant(false), isSessionTimeoutPresented: .constant(false))
}
#endif
