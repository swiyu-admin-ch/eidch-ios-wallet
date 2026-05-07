import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - ScanDocumentView

struct ScanDocumentView: View {

  // MARK: Internal

  var body: some View {
    GeometryReader { geo in
      content()
        .cameraPermission { state in
          if state == .authorized {
            viewModel.checkInitializationState()
          }
        }
        .disablePhoneLock()
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .font(.custom.body)
        .animation(.easeInOut(duration: 0.4), value: viewModel.state)
        .readSize { size in
          self.size = size
          let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
          viewModel.scanFrame = frame
        }
        .suspendInactivityTimeout()
        .onDisappear {
          viewModel.stop()
        }
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
      case .camera:
        scannerView()
          .transition(.opacity)
      case .loading:
        LoadingView(
          primary: L10n.tkLoaderInitializationPrimary,
          secondary: L10n.tkLoaderInitializationSecondary,
          action: LoadingView.Action(
            action: { viewModel.cancelInitialization(navigator) },
            buttonText: L10n.tkGlobalCancel))
          .transition(.opacity)
      }
    }
  }

  // MARK: Private

  @State private var size = CGSize.zero

  @Environment(\.navigator) private var navigator

  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  @InjectedObservable(\.scanDocumentViewModel) private var viewModel: ScanDocumentViewModel

  @Orientation private var orientation

  private var imageOverlayOrientation: Double {
    if !orientation.isLandscape {
      return 90
    }

    return 0
  }

  private var isBackOverlayVisible: Bool {
    viewModel.scanningState == .verso
  }

  private func scannerView() -> some View {
    ZStack(alignment: .center) {
      GLViewWrapper(viewModel.avBeam.getGLView)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()

      cameraOverlay()

      if orientation.isLandscape {
        recordingButtonView()
          .frame(maxWidth: .infinity, alignment: .trailing)
          .padding(.trailing, .x10)
      }
    }
    .ignoresSafeArea(edges: orientation.isLandscape ? [.horizontal] : [])
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        recordingButtonView()
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
  }

  private func recordingButtonView() -> some View {
    RecordingButton(state: $viewModel.buttonState, onTapInitial: viewModel.startScan, onTapRecord: viewModel.stopScan)
      .accessibilityLabel(viewModel.buttonStateAccessibilityLabel)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }

  private func cameraOverlay() -> some View {
    ZStack {
      viewModel.overlayImage.front
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.x4)
        .rotationEffect(.degrees(imageOverlayOrientation))
        .opacity(isBackOverlayVisible ? 0 : 1)
        .accessibilityLabel(L10n.tkEidRequestScanDocumentOverlayFrontAlt)

      viewModel.overlayImage.back
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.x4)
        .rotationEffect(.degrees(imageOverlayOrientation))
        .opacity(isBackOverlayVisible ? 1 : 0)
        .accessibilityLabel(L10n.tkEidRequestScanDocumentOverlayFrontAlt)
    }
  }
}

extension ScanDocumentView {
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

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    if viewModel.state == .camera {
      ToolbarItem(placement: .principal) {
        Text(viewModel.title)
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

#if DEBUG
#Preview {
  ScanDocumentView()
}
#endif
