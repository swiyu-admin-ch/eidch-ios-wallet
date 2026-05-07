import BITCredential
import BITCredentialShared
import BITL10n
import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - PresentationRequestResultStateView

struct PresentationRequestResultStateView: View {

  // MARK: Lifecycle

  init(state: PresentationRequestResultState, context: PresentationRequestContext) {
    _viewModel = State(wrappedValue: Container.shared.presentationRequestResultStateViewModel((state, context)))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "presentationRequestResultStateContent"
    case dataTransmitted
    case finishButton
  }

  var body: some View {
    VStack {
      ActorHeaderView(verifier: viewModel.verifierDisplay, topInset: topInset) { badgeType in
        navigator.navigate(to: PresentationDestinations.badgeInformation(badgeType))
      }.padding(.bottom, .x3)
      stateView
    }
    .applyScrollViewIfNeeded()
    .toolbar(.hidden)
    .ignoresSafeArea(edges: .bottom)
    .ignoresSafeArea(edges: .top)
    .readSize(onChange: { size in
      compression = sizeCategory.isAccessibilityCategory ? .small : UICompressionStyle(height: size.height)
      availableWidth = size.width
    })
    .readSafeAreaInsets(onChange: { insets in
      topInset = insets.top
    })
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .onAppear(perform: {
      isAccessibilityTitleFocused = true
    })
    .navigationBack(onChangeOf: $viewModel.isNavigationBackTriggered)
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  @ViewBuilder
  var content: some View {
    switch viewModel.state {
    case .invalidCredential,
         .success:
      dataTransmittedView
    case .deny:
      denyView
    case .error:
      errorMessages(title: L10n.tkPresentResultErrorPrimary, subtitle: L10n.tkPresentResultErrorSecondary)
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @Environment(\.sizeCategory) private var sizeCategory

  @State private var compression = UICompressionStyle.normal
  @State private var availableWidth: CGFloat = 0
  @State private var topInset: CGFloat = 0

  @AccessibilityFocusState(for: .voiceOver)
  private var isAccessibilityTitleFocused: Bool

  @State private var viewModel: PresentationRequestResultStateViewModel

  private var stateView: some View {
    VStack {
      Spacer()
      if sizeCategory < .accessibilityExtraLarge {
        viewModel.state.icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 56, height: 56)
          .accessibilityHidden(true)
      }
      content
      Spacer(minLength: compression.isCompressed ? .x4 : .x6)
      buttons
    }
    .frame(maxWidth: .infinity)
    .padding(.top, compression.isCompressed ? .x4 : .x6)
    .padding(.bottom, .x10)
    .padding(.horizontal, .x6)
    .background(viewModel.state.backgroundColor)
    .clipShape(RoundedCorner(radius: .x8, corners: [.topLeft, .topRight]))
    .accessibilityElement(children: .contain)
  }

  private var denyView: some View {
    Text(L10n.tkPresentResultDeclinedPrimary)
      .multilineTextAlignment(.center)
      .font(.custom.body)
      .foregroundStyle(ThemingAssets.Brand.Core.navyBlueLabel.swiftUIColor)
      .padding(.bottom, compression.isCompressed ? .x2 : .x4)
      .accessibilityPriorityFocus()
  }

  private var dataTransmittedView: some View {
    VStack(spacing: .x1) {
      Text(L10n.tkPresentResultDataTransmittedTitle)
        .accessibilityAddTraits(.isHeader)
      Text(L10n.tkPresentResultDataTransmittedBody)
        .opacity(0.7)
    }
    .padding(.bottom, compression.isCompressed ? .x2 : .x4)
    .font(.custom.body)
    .multilineTextAlignment(.center)
    .foregroundStyle(ThemingAssets.Brand.Core.firGreenLabel.swiftUIColor)
    .accessibilityIdentifier(AccessibilityIdentifier.dataTransmitted.rawValue)
    .accessibilityPriorityFocus()
  }

  private var finishButton: some View {
    Button(action: close) {
      Text(L10n.tkGlobalFinish)
        .frame(maxWidth: .infinity)
    }
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.finishButton.rawValue)
  }

  private var errorButtons: some View {
    AdaptiveButtonStack {
      Button { viewModel.retry() } label: {
        Text(L10n.tkPresentResultErrorButtonRetry)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bezeled)
      .controlSize(.large)
    } secondary: {
      Button(action: close) {
        Text(L10n.tkGlobalFinish)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.plain)
      .controlSize(.large)
    }
  }

  @ViewBuilder
  private var buttons: some View {
    switch viewModel.state {
    case .invalidCredential,
         .success:
      finishButton
        .buttonStyle(.firGreen)
    case .deny:
      finishButton
        .buttonStyle(.navyBlue)
    case .error:
      errorButtons
    }
  }

  private func errorMessages(title: String, subtitle: String) -> some View {
    VStack(spacing: .x1) {
      Text(title)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      Text(subtitle)
        .multilineTextAlignment(.center)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor.opacity(0.7))
    }
    .padding(.top, .x1)
    .accessibilityPriorityFocus()
  }

  private func close() {
    if navigator.canReturnToCheckpoint(PresentationCheckpoints.didFinish) {
      return navigator.returnToCheckpointSafely(PresentationCheckpoints.didFinish, value: viewModel.state)
    }

    if navigator.canReturnToCheckpoint(Checkpoints.home) {
      return navigator.returnToCheckpointSafely(Checkpoints.home)
    }

    navigator.dismiss()
  }
}

extension PresentationRequestResultState {
  fileprivate var backgroundColor: Color {
    switch self {
    case .invalidCredential,
         .success:
      ThemingAssets.Brand.Core.firGreen.swiftUIColor
    case .deny:
      ThemingAssets.Brand.Core.navyBlue.swiftUIColor
    case .error:
      ThemingAssets.Background.tertiary.swiftUIColor
    }
  }

  fileprivate var icon: Image {
    switch self {
    case .invalidCredential,
         .success:
      Assets.presentationDataTransmitted.swiftUIImage
    case .deny:
      Assets.presentationDeny.swiftUIImage
    case .error:
      Assets.presentationError.swiftUIImage
    }
  }

  fileprivate var sheetAccessibilityLabel: String {
    switch self {
    case .deny,
         .invalidCredential,
         .success:
      L10n.tkPresentResultConfirmAlt
    case .error:
      L10n.tkPresentResultWarningAlt
    }
  }
}

#if DEBUG
#Preview {
  PresentationRequestResultStateView(state: .invalidCredential, context: .Mock.vcSdJwtSample)
}
#endif
