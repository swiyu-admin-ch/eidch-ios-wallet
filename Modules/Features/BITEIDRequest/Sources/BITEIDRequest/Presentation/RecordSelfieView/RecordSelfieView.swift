import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - RecordSelfieView

struct RecordSelfieView: View {

  // MARK: Internal

  var body: some View {
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)

      switch viewModel.state {
      case .loading:
        loadingView()
          .transition(.opacity)
          .task {
            viewModel.initializeSDK()
          }
      case .camera:
        cameraView()
          .transition(.opacity)
      }
    }
    .cameraPermission()
    .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
    .font(.custom.body)
    .animation(.easeInOut(duration: 0.4), value: viewModel.state)
    .onDisappear(perform: viewModel.stop)
    .navigationTitle(L10n.tkEidRequestRecordSelfieTitle)
    .toolbar { CloseButtonToolbar(action: { viewModel.close() }) }
    .navigate(to: $viewModel.destination)
    .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
  }

  // MARK: Private

  @Orientation private var orientation
  @Environment(\.navigator) private var navigator
  @InjectedObject(\.recordSelfieViewModel) private var viewModel

  @ViewBuilder
  private func introductionPopupView() -> some View {
    Notification(
      title: L10n.tkEidRequestRecordSelfieNotificationPrimary,
      titleColor: ThemingAssets.Label.primary.swiftUIColor,
      content: L10n.tkEidRequestRecordSelfieNotificationSecondary,
      contentColor: ThemingAssets.Label.primary.swiftUIColor,
      closeAction: {
        viewModel.closeIntroductionPopup()
      },
      background: ThemingAssets.Background.secondary.swiftUIColor, closeButtonStyle: .secondary)
      .padding(.horizontal, .x3)
      .padding(.vertical, .x2)
      .frame(maxWidth: 480)
  }

  @ViewBuilder
  private func popupView(_ notification: AVBeamNotification?) -> some View {
    if let recoverySuggestion = notification?.recoverySuggestion {
      Text(recoverySuggestion)
        .font(.custom.subheadline)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .padding(.horizontal, .x2)
        .padding(.vertical, .x1)
        .background(ThemingAssets.Background.tertiary.swiftUIColor)
        .clipShape(.capsule)
    }
  }

}

extension RecordSelfieView {

  @ViewBuilder
  private func loadingView() -> some View {
    VStack {
      ProgressView()
      Text(L10n.tkEidRequestSdkInitializationPrimary)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ThemingAssets.Background.secondary.swiftUIColor)
    .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
    .ignoresSafeArea(edges: .bottom)
    .task {
      viewModel.initializeSDK()
    }
  }

  @ViewBuilder
  private func cameraView() -> some View {
    ZStack(alignment: .center) {
      GLViewWrapper(viewModel.avBeam.getGLView)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: [.leading, .trailing, .bottom])

      Assets.selfieOverlay.swiftUIImage
        .aspectRatio(contentMode: .fit)
        .padding(.x4)

      if orientation.isLandscape {
        HStack {
          Spacer()
          RecordingButton(state: $viewModel.buttonState, action: viewModel.startRecordSelfie)
        }
      }
    }
    .popup(isPresented: $viewModel.isIntroductionPopupPresented, view: introductionPopupView) {
      $0.appearFrom(.bottomSlide)
        .position(.bottom)
        .closeOnTap(false)
        .closeOnTapOutside(false)
        .type(.floater(verticalPadding: 0, horizontalPadding: 0, useSafeAreaInset: true))
    }
    .popup(isPresented: $viewModel.isNotificationPresented, view: {
      popupView(viewModel.notification)
    }) {
      $0.appearFrom(.topSlide)
        .position(.top)
        .closeOnTap(false)
        .closeOnTapOutside(false)
        .type(.floater(verticalPadding: .x8, horizontalPadding: .x4, useSafeAreaInset: true))
    }
    .navigationTitle(L10n.tkEidRequestRecordSelfieTitle)
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        RecordingButton(state: $viewModel.buttonState, action: viewModel.startRecordSelfie)
      }
    }
  }
}

#Preview {
  RecordSelfieView()
}
