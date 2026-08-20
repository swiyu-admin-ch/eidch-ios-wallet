import BITL10n
import BITTheming
import Factory
import NavigatorUI
import PopupView
import SwiftUI

// MARK: - DeeplinkLoadingView

struct DeeplinkLoadingView: View {

  // MARK: Lifecycle

  init(url: URL) {
    _viewModel = State(wrappedValue: Container.shared.deeplinkViewModel(url))
  }

  // MARK: Internal

  @State var viewModel: DeeplinkViewModel

  var body: some View {
    content
      .navigate(to: $viewModel.destination)
      .onChange(of: viewModel.onDismiss) { _, newValue in
        guard newValue else { return }
        viewModel.resetProximityEngagementIfNeeded()
        navigator.dismiss()
      }
      .task {
        await viewModel.onAppear()
      }
  }

  // MARK: Private

  private enum Defaults {
    static let innerGradientMaxWidth = 250.0
    static let innerGradientMaxHeight = 462.0
  }

  @Environment(\.navigator) private var navigator: Navigator

  @ViewBuilder
  private var content: some View {
    if let error = viewModel.error, !presentsErrorPage(error) {
      errorView(error)
    } else {
      progressView()
    }
  }

}

// MARK: - Components

extension DeeplinkLoadingView {
  private func progressView() -> some View {
    ZStack {
      Rectangle()
        .overlay(
          ThemingAssets.Gradient.gradient4.swiftUIImage
            .resizable()
            .scaledToFill()
            .clipped())
        .clipped()
        .ignoresSafeArea()
        .accessibilityHidden(true)

      ThemingAssets.Gradient.gradient2.swiftUIImage
        .resizable()
        .frame(maxWidth: Defaults.innerGradientMaxWidth, maxHeight: Defaults.innerGradientMaxHeight)
        .clipShape(.rect(cornerRadius: .x7))
        .accessibilityHidden(true)

      ProgressView()
        .tint(.white)
        .scaleEffect(1.5)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
    }
  }

  @ViewBuilder
  private func errorView(_ error: Error) -> some View {
    let invitationError = error as? InvitationError ?? .invalidQRCode()
    VStack(spacing: .x1) {
      Spacer()

      if let icon = invitationError.icon, let primaryText = invitationError.primaryText, let secondaryText = invitationError.secondaryText {
        icon
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 56, height: 56)
          .accessibilityHidden(true)

        Text(primaryText)
          .font(.custom.title)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .multilineTextAlignment(.center)
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

        Text(secondaryText)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .multilineTextAlignment(.center)
          .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      }

      Spacer()

      Button(L10n.tkGlobalClose) {
        navigator.dismiss()
      }
      .padding(.bottom, .x6)
      .controlSize(.large)
      .buttonStyle(.primary)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    }
    .padding(.horizontal, .x6)
    .frame(maxWidth: .infinity)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
  }

  private func presentsErrorPage(_ error: Error) -> Bool {
    guard let invitationError = error as? InvitationError else {
      return false
    }

    return invitationError.errorDataset != nil
  }

}
