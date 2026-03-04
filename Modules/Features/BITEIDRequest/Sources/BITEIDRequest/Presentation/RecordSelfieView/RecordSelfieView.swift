import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - RecordSelfieView

struct RecordSelfieView: View {

  // MARK: Internal

  var body: some View {
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)

      switch viewModel.state {
      case .loading:
        LoadingView(
          primary: L10n.tkLoaderInitializationPrimary,
          secondary: L10n.tkLoaderInitializationSecondary,
          action: LoadingView.Action(
            action: viewModel.cancelInitialization,
            buttonText: L10n.tkGlobalCancel))
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
    .disablePhoneLock()
    .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
    .font(.custom.body)
    .animation(.easeInOut(duration: 0.4), value: viewModel.state)
    .onDisappear(perform: viewModel.stop)
    .navigationTitle(L10n.tkEidRequestRecordSelfieTitle)
    .defaultEidRequestToolbar()
    .navigationBarBackButtonHidden()
    .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @Orientation private var orientation
  @InjectedObject(\.recordSelfieViewModel) private var viewModel

  @ViewBuilder
  private func popupView(_ notification: AVBeamNotification?) -> some View {
    if let message = notification?.localizedDescription, !message.isEmpty {
      Text(message)
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
        .accessibilityPriorityFocus()
        .accessibilityLabel(L10n.tkEidRequestRecordSelfiePictureFrameAlt)
        .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)

      if orientation.isLandscape {
        HStack {
          Spacer()
          recordButtonView()
        }
      }
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
        recordButtonView()
      }
    }
  }

  private func recordButtonView() -> some View {
    RecordingButton(state: $viewModel.buttonState, onTapInitial: viewModel.startRecordSelfie, onTapRecord: viewModel.stopRecordSelfie)
      .accessibilityLabel(L10n.tkEidRequestRecordSelfieRecordButtonAlt)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }
}

#Preview {
  RecordSelfieView()
}
