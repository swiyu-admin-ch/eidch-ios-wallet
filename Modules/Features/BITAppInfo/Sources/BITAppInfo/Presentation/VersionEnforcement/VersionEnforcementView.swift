import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - VersionEnforcementView

struct VersionEnforcementView: View {

  // MARK: Lifecycle

  init(viewModel: VersionEnforcementViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  // MARK: Internal

  @Environment(\.sizeCategory) var sizeCategory

  var body: some View {
    ZStack {
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

      content()
    }
    .environment(\.colorScheme, .light)
  }

  // MARK: Private

  @State private var viewModel: VersionEnforcementViewModel

  private let overlayDimming = 0.21

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    switch viewModel.enforcementType {
    case .forced:
      VersionEnforcementForcedView(message: viewModel.message)

    case .optional:
      VersionEnforcementOptionalView(message: viewModel.message, onDismiss: viewModel.dismissToHomeScreen)

    case .outdatedOsVersion:
      VersionEnforcementOudatedOsView()

    case .blacklistedDevice:
      VersionEnforcementBlacklistedDeviceView()
    }
  }
}
