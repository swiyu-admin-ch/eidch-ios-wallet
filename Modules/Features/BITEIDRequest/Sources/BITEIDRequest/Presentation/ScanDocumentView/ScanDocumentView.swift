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
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
        .ignoresSafeArea(edges: .bottom)

      switch viewModel.state {
      case .camera:
        scannerView()
          .transition(.opacity)
      case .loading:
        loadingView()
          .transition(.opacity)
          .task {
            viewModel.initializeSDK()
          }
      }
    }
    .cameraPermission()
    .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
    .font(.custom.body)
    .animation(.easeInOut(duration: 0.4), value: viewModel.state)
    .readSize { size in
      self.size = size
      let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      viewModel.scanFrame = frame
    }
    .onDisappear(perform: {
      viewModel.stop()
    })
    .defaultEidRequestToolbar()
    .navigationBarBackButtonHidden()
    .navigate(to: $viewModel.destination)
  }

  // MARK: Private

  @Orientation private var orientation

  @State private var size = CGSize.zero
  @State private var rotationAngle: Double = 0
  @State private var currentDisplayState = ScanDocumentViewModel.ScanningState.recto
  @State private var scale = 1.0
  @State private var scaleAnimationTask: Task<Void, Never>?

  @InjectedObject(\.scanDocumentViewModel) private var viewModel: ScanDocumentViewModel

  private let defaultScale = 1.0
  private let axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (x: 0, y: 1, z: 0)
  private let animationDuration: TimeInterval = 0.4
  private let animatedScale: CGFloat = 0.95
  private let oppositeRotationAngle: Double = 180
  private let defaultRotationAngle: Double = 0
  private let cameraBlur = 50.0

  private var isBackOverlayVisible: Bool {
    rotationAngle > 90 && rotationAngle < 270
  }

  @ViewBuilder
  private func loadingView() -> some View {
    VStack {
      ProgressView()
      Text(L10n.tkEidRequestSdkInitializationPrimary)
    }
  }

  @ViewBuilder
  private func scannerView() -> some View {
    ZStack(alignment: .center) {
      GLViewWrapper(viewModel.avBeam.getGLView)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .blur(radius: orientation.isLandscape ? 0 : cameraBlur)

      cameraOverlay()
    }
    .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
    .ignoresSafeArea(edges: [.bottom, .horizontal])
    .popup(item: $viewModel.introductionPopupState, itemView: introductionPopupView) {
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
    .navigationTitle(viewModel.title)
  }

  @ViewBuilder
  private func cameraOverlay() -> some View {
    if orientation.isLandscape {
      cameraLandscapeOverlay()
    } else {
      VStack(spacing: .x1) {
        Assets.cameraRotate.swiftUIImage
          .resizable()
          .frame(width: 180, height: 180)
        Text(L10n.tkEidRequestDocumentScanRotateCameraHint)
          .font(.custom.bodyEmphasized)
          .foregroundStyle(.white)
      }
    }
  }

  @ViewBuilder
  private func cameraLandscapeOverlay() -> some View {
    ZStack {
      viewModel.overlayImage.front
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.x4)
        .scaleEffect(scale)
        .rotation3DEffect(
          .degrees(rotationAngle),
          axis: axis)
        .opacity(isBackOverlayVisible ? 0 : 1)

      viewModel.overlayImage.back
        .resizable()
        .aspectRatio(contentMode: .fit)
        .padding(.x4)
        .scaleEffect(scale)
        .rotation3DEffect(
          .degrees(rotationAngle + 180),
          axis: axis)
        .opacity(isBackOverlayVisible ? 1 : 0)
    }
    .onReceive(viewModel.$scanningState) { newState in
      if newState != currentDisplayState {
        currentDisplayState = newState

        scaleAnimationTask?.cancel()
        withAnimation(.easeInOut(duration: animationDuration * 2)) {
          rotationAngle = (newState == .verso) ? oppositeRotationAngle : defaultRotationAngle
          scale = animatedScale
        }

        scaleAnimationTask = Task {
          // Buy some time to let the previous animation to reach its end
          try? await Task.sleep(nanoseconds: UInt64(animationDuration * 1_000_000_000))

          guard !Task.isCancelled else { return }
          withAnimation(.easeInOut(duration: animationDuration)) {
            scale = defaultScale
          }
        }
      }
    }
  }

}

extension ScanDocumentView {

  @ViewBuilder
  private func introductionPopupView(_ state: ScanDocumentViewModel.ScanningState) -> some View {
    Notification(
      title: state.popupTitle,
      titleColor: ThemingAssets.Label.primary.swiftUIColor,
      content: state.popupContent,
      contentColor: ThemingAssets.Label.primary.swiftUIColor,
      closeAction: {
        viewModel.introductionPopupState = nil
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

#if DEBUG
#Preview {
  ScanDocumentView()
}
#endif
