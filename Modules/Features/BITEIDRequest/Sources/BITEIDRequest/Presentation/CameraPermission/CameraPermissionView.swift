import BITTheming
import Factory
import SwiftUI

// MARK: - CameraPermissionView

struct CameraPermissionView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.cameraPermissionViewModel(router))
  }

  // MARK: Internal

  @StateObject var viewModel: CameraPermissionViewModel

  var body: some View {
    InformationView(
      image: Assets.camera.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: viewModel.primary,
          secondary: viewModel.secondary)
      },
      footer: {
        DefaultInformationFooterView(primaryButtonLabel: viewModel.buttonText, primaryButtonAction: viewModel.buttonAction)
      })
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }
}
