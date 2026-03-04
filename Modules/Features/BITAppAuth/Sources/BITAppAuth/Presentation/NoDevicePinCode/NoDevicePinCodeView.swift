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

  private func background() -> some View {
    Rectangle()
      .overlay(
        ThemingAssets.Gradient.gradient4.swiftUIImage
          .resizable()
          .scaledToFill()
          .clipped()
          .overlay(.black.opacity(overlayDimming)))
      .clipped()
      .ignoresSafeArea()
      .accessibilityHidden(true)
  }

  private func mainContent() -> some View {
    VStack(alignment: .center, spacing: .x6) {
      Assets.shield.swiftUIImage
        .accessibilityHidden(true)

      VStack(alignment: .center, spacing: .x2) {
        Text(L10n.tkUnsecuredDevicePrimary)
          .font(.custom.title)
          .foregroundColor(ThemingAssets.Grays.white.swiftUIColor)
          .multilineTextAlignment(.center)

        Text(L10n.tkUnsecuredDeviceSecondary)
          .font(.custom.body)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
      }

      Text(L10n.tkUnsecuredDeviceTertiary)
        .font(.custom.body)
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
    }
    .padding(.horizontal, .x6)
  }

  private func footer() -> some View {
    Button(action: viewModel.openSettings) {
      Text(L10n.tkUnsecuredDeviceButtonSettings)
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
