import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NoDevicePinCodeView

struct NoDevicePinCodeView: View {

  // MARK: Lifecycle

  init(viewModel: NoDevicePinCodeViewModel) {
    self.viewModel = viewModel
  }

  // MARK: Internal

  var body: some View {
    ZStack {
      background()
      content()
    }
    .environment(\.colorScheme, .light)
  }

  // MARK: Private

  private let overlayDimming = 0.21
  private var viewModel: NoDevicePinCodeViewModel

  @ViewBuilder
  private func content() -> some View {
    VStack {
      Spacer()
      mainContent()
      Spacer()
    }
    .applyScrollViewIfNeeded()
    .safeAreaInset(edge: .bottom) {
      footer()
        .padding(.bottom, .x4)
    }
  }
}

extension NoDevicePinCodeView {

  @ViewBuilder
  private func background() -> some View {
    Rectangle()
      .overlay(
        ThemingAssets.Gradient.gradient4.swiftUIImage
          .resizable()
          .scaledToFill()
          .clipped()
          .overlay(.black.opacity(overlayDimming))
      )
      .clipped()
      .ignoresSafeArea()
      .accessibilityHidden(true)
  }

  @ViewBuilder
  private func mainContent() -> some View {
    VStack(alignment: .center, spacing: .x6) {
      Assets.shield.swiftUIImage
        .accessibilityHidden(true)

      VStack(alignment: .center, spacing: .x2) {
        Text(L10n.tkUnsafedeviceUnsafeTitle)
          .font(.custom.title)
          .foregroundColor(ThemingAssets.Grays.white.swiftUIColor)
          .multilineTextAlignment(.center)

        Text(L10n.tkUnsafedeviceUnsafeBody)
          .font(.custom.body)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
      }

      Text(L10n.tkUnsafedeviceUnsafeSmallbody)
        .font(.custom.body)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, .x6)
  }

  @ViewBuilder
  private func footer() -> some View {
    Button(action: viewModel.openSettings) {
      Text(L10n.tkUnsafedeviceUnsafePrimaryButton)
    }
    .controlSize(.large)
    .buttonStyle(.primary)
  }
}

#if DEBUG
#Preview {
  NoDevicePinCodeView(viewModel: NoDevicePinCodeViewModel(router: NoDevicePinCodeRouter()))
}
#endif
