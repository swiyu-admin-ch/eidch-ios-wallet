import BITL10n
import BITTheming
import Factory
import PopupView
import SwiftUI

// MARK: - DeeplinkLoadingView

struct DeeplinkLoadingView: View {

  // MARK: Lifecycle

  init(url: URL, router: InvitationRouterRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.deeplinkViewModel((url, router)))
  }

  // MARK: Internal

  @StateObject var viewModel: DeeplinkViewModel

  var body: some View {
    content
      .onAppear {
        Task {
          await viewModel.onAppear()
        }
      }
  }

  // MARK: Private

  private enum Defaults {
    static let innerGradientMaxWidth = 250.0
    static let innerGradientMaxHeight = 462.0
  }

  @ViewBuilder
  private var content: some View {
    if let error = viewModel.error {
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
    let invitationError = error as? InvitationError ?? .invalidQRCode
    VStack(spacing: .x1) {
      Spacer()

      invitationError.icon
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 56, height: 56)
        .accessibilityHidden(true)

      Text(invitationError.primaryText)
        .font(.custom.title)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .multilineTextAlignment(.center)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      Text(invitationError.secondaryText)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.center)
        .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)

      Spacer()

      Button(L10n.tkGlobalClose, action: viewModel.close)
        .padding(.bottom, .x6)
        .controlSize(.large)
        .buttonStyle(.primary)
        .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    }
    .padding(.horizontal, .x6)
    .frame(maxWidth: .infinity)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
  }
}
