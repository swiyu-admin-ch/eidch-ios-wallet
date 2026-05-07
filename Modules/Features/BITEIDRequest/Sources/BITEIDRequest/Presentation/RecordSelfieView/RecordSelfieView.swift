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
    GeometryReader { geo in
      content()
        .suspendInactivityTimeout()
        .onDisappear {
          viewModel.stop()
        }
        .cameraPermission { state in
          if state == .authorized {
            viewModel.checkInitializationState()
          }
        }
        .disablePhoneLock()
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .font(.custom.body)
        .animation(.easeInOut(duration: 0.4), value: viewModel.state)
        .toolbar { toolbarContent() }
        .navigationBarBackButtonHidden()
        .navigate(to: $viewModel.destination)
        .transparentToolbarBackground(isActive: true, topInset: geo.safeAreaInsets.top)
    }
  }

  func content() -> some View {
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
            action: { viewModel.cancelInitialization(navigator) },
            buttonText: L10n.tkGlobalCancel))
          .transition(.opacity)
      case .camera:
        cameraView()
          .transition(.opacity)
      }
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  @InjectedObservable(\.recordSelfieViewModel) private var viewModel: RecordSelfieViewModel

  @Orientation private var orientation

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
      GLViewWrapper(viewModel.avBeam.getGLView, orientation: orientation)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()

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
    .ignoresSafeArea(edges: orientation.isLandscape ? [.horizontal] : [])
    .popup(isPresented: $viewModel.isNotificationPresented, view: {
      popupView(viewModel.notification)
    }) {
      $0.appearFrom(.topSlide)
        .position(.top)
        .closeOnTap(false)
        .closeOnTapOutside(false)
        .type(.floater(verticalPadding: .x8, horizontalPadding: .x4, useSafeAreaInset: true))
    }
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        recordButtonView()
      }
    }
  }

  private func recordButtonView() -> some View {
    RecordingButton(state: $viewModel.buttonState, onTapInitial: viewModel.startRecordSelfie, onTapRecord: viewModel.stopRecordSelfie)
      .accessibilityLabel(viewModel.buttonStateAccessibilityLabel)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    if viewModel.state == .camera {
      ToolbarItem(placement: .principal) {
        Text(L10n.tkEidRequestRecordSelfieTitle)
          .font(.custom.body)
          .fontWeight(.semibold)
          .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
          .colorScheme(.light)
          .lineLimit(1)
      }
    }

    ToolbarItem(placement: .topBarTrailing) {
      Button(action: close, label: {
        viewModel.state == .camera ? Assets.closeCamera.swiftUIImage : ThemingAssets.close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
      .accessibilityIdentifier("closeButton")
    }
  }

  private func close() {
    coordinator.cleanup()
    navigator.dismiss()
  }

}

#Preview {
  RecordSelfieView()
}
