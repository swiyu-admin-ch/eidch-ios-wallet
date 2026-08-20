import BITCredential
import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - PresentationRequestReviewView

struct PresentationRequestReviewView: View {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    _viewModel = State(wrappedValue: Container.shared.presentationRequestReviewViewModel(context))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "presentationRequestReviewContent"
    case acceptButton
    case denyButton
    case unregisteredWarning
  }

  var body: some View {
    Content(
      state: viewModel.state,
      alert: $viewModel.alert,
      eventAction: { event in Task { await viewModel.send(event) } },
      actorInformationAction: { actorInformation in
        navigator.navigate(to: PresentationDestinations.actorInformation(actorInformation))
      },
      claimInformationAction: { isSensitive, claimName in
        navigator.navigate(to: PresentationDestinations.claimInformation(isSensitive: isSensitive, claimName: claimName))
      })
      .onFirstAppear {
        Task {
          await viewModel.send(.onAppear)
        }
      }
      .onColorSchemeChange { scheme in
        viewModel.updateCredential(with: scheme.rawValue)
      }
      .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @State private var viewModel: PresentationRequestReviewViewModel
}

// MARK: PresentationRequestReviewView.Content

extension PresentationRequestReviewView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      state: PresentationRequestReviewState,
      alert: Binding<PresentationRequestReviewAlert?>,
      eventAction: @escaping (PresentationRequestReviewViewModel.Event) -> Void = { _ in },
      actorInformationAction: @escaping (ActorInformation) -> Void = { _ in },
      claimInformationAction: @escaping (Bool, String) -> Void = { _, _ in })
    {
      self.state = state
      self.alert = alert
      self.eventAction = eventAction
      self.actorInformationAction = actorInformationAction
      self.claimInformationAction = claimInformationAction
    }

    // MARK: Internal

    var body: some View {
      stateView
        .landscapeMaxWidth()
        .ignoresSafeArea(edges: .top)
        .readSafeAreaInsets(onChange: { insets in
          topInset = insets.top
        })
        .frame(maxWidth: .infinity)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(PresentationRequestReviewView.AccessibilityIdentifier.content.rawValue)
    }

    // MARK: Private

    @State private var topInset: CGFloat = 0

    @ScaledMetric(relativeTo: .footnote) private var warningIconWidth: CGFloat = 11
    @ScaledMetric(relativeTo: .footnote) private var warningIconHeight: CGFloat = 14

    private let state: PresentationRequestReviewState
    private let alert: Binding<PresentationRequestReviewAlert?>
    private let eventAction: (PresentationRequestReviewViewModel.Event) -> Void
    private let actorInformationAction: (ActorInformation) -> Void
    private let claimInformationAction: (Bool, String) -> Void

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

    private func loadingView() -> some View {
      VStack {
        Spacer()
        ProgressView()
          .controlSize(.large)
        Spacer()
      }
    }

    private func actorHeader(_ verifierDisplay: VerifierDisplay) -> some View {
      ActorHeaderView(verifier: verifierDisplay, topInset: topInset, onTapped: actorInformationAction)
    }
  }
}

// MARK: - Result

extension PresentationRequestReviewView.Content {
  private func resultView(_ viewState: PresentationRequestReviewState.Result) -> some View {
    let isAlertPresented = Binding(
      get: { alert.wrappedValue != nil },
      set: { if !$0 { alert.wrappedValue = nil } })

    return VStack(alignment: .leading, spacing: .x4) {
      actorHeader(viewState.verifierDisplay)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      SectionView(title: L10n.tkPresentReviewCredentialDataSectionPrimary) {
        if !viewState.hasVerifiedQuery {
          unregisteredRequestWarning()
            .padding(.horizontal, .x4)
            .padding(.top, .x2)
        }

        CredentialSummaryWidget(credential: viewState.credential, claimBadges: viewState.claimBadges, claimInformationAction: claimInformationAction)
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
    .confirmationDialog(alert.wrappedValue?.title ?? "", isPresented: isAlertPresented, titleVisibility: .visible) {
      Button(L10n.tkPresentReviewConfirmPresentationButtonSecondary, role: .destructive) {
        eventAction(.deny)
      }
      Button(L10n.tkPresentReviewConfirmPresentationButtonPrimary) {
        eventAction(.submit(viewState, true))
      }
      Button(L10n.tkGlobalCancel, role: .cancel) {}
    } message: {
      if let alert = alert.wrappedValue {
        Text(alert.message)
      }
    }
  }

  private func unregisteredRequestWarning() -> some View {
    HStack(alignment: .top, spacing: .x2) {
      Assets.warningIcon.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: warningIconWidth, height: warningIconHeight, alignment: .top)
        .padding(.top, .x1)
        .accessibilityHidden(true)

      Text(L10n.tkPresentUnregisteredRequestWarning)
        .font(.custom.footnote)
    }
    .foregroundStyle(ThemingAssets.Component.Callout.Alert.symbol.swiftUIColor)
    .padding(.x4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(ThemingAssets.Component.Callout.Alert.background.swiftUIColor)
    .clipShape(.rect(cornerRadius: .x2))
    .contentShape(.accessibility, .rect(cornerRadius: .x2))
    .overlay {
      RoundedRectangle(cornerRadius: .x2)
        .stroke(ThemingAssets.Component.Callout.Alert.border.swiftUIColor, lineWidth: 1)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(L10n.tkPresentUnregisteredRequestWarning)
    .accessibilityIdentifier(PresentationRequestReviewView.AccessibilityIdentifier.unregisteredWarning.rawValue)
  }

  private func footerButtons(submitAction: @escaping (Bool) -> Void, denyAction: @escaping () -> Void) -> some View {
    ButtonSheet(colorConfig: .secondary) {
      AdaptiveButtonStack {
        Button { submitAction(false) } label: {
          Label(L10n.tkPresentReviewPrimaryButton, systemImage: "checkmark")
            .frame(maxWidth: .infinity)
            .lineLimit(1)
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
        loader(isMessagePresented: viewState.isMessagePresented, progress: viewState.progress)
      }
      .padding(.bottom, .x10)
      .padding(.horizontal, .x6)
      .background(ThemingAssets.Background.secondary.swiftUIColor)
      .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    }
    .applyScrollViewIfNeeded()
    .ignoresSafeArea(edges: .bottom)
  }

  private func loader(isMessagePresented: Bool, progress: Double?) -> some View {
    VStack(spacing: .x3) {
      if let progress {
        progressView(progress: progress)
      } else {
        ProgressView()
          .controlSize(.large)
      }

      if isMessagePresented {
        Text(L10n.tkPresentReviewLoading)
          .font(.custom.body)
          .accessibilityLabel(L10n.tkPresentReviewLoadingAlt)
      }
    }
    .tint(ThemingAssets.Brand.Core.navyBlue.swiftUIColor)
    .animation(.default, value: isMessagePresented)
  }

  private func progressView(progress: Double) -> some View {
    ProgressView(
      value: progress,
      label: {},
      currentValueLabel: {
        Text(progress.formatted(.percent.precision(.fractionLength(0))))
          .foregroundStyle(ThemingAssets.Brand.Accent.purple.swiftUIColor)
      })
      .progressViewStyle(.linearGradient)
      .frame(width: 240)
  }
}

#if DEBUG
#Preview {
  PresentationRequestReviewView.Content(state: .Mock.result, alert: .constant(nil))
}
#endif
