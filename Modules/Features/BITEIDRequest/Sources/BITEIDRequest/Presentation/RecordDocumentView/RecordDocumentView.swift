import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - RecordDocumentView

struct RecordDocumentView: View {

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
        cameraView()
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

  @Environment(\.navigator) private var navigator

  @State private var size = CGSize.zero
  @State private var rotationAngle: Double = 0
  @State private var currentDisplayState = RecordDocumentViewModel.ScanningState.recto
  @State private var scale = 1.0

  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  @InjectedObservable(\.recordDocumentViewModel) private var viewModel: RecordDocumentViewModel

  @Orientation private var orientation

  private let defaultScale = 1.0
  private let axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (x: 0, y: 1, z: 0)
  private let animationDuration: TimeInterval = 0.4
  private let animatedScale: CGFloat = 0.95
  private let animatedRotationAngle: Double = 90
  private let oppositeRotationAngle: Double = 180
  private let rotationVisibilityRange: Range<Double> = 90..<270
  private let defaultRotationAngle: Double = 0
}

extension RecordDocumentView {
  private func cameraView() -> some View {
    ZStack(alignment: .center) {
      GLViewWrapper(viewModel.avBeam.getGLView)
        .background(ThemingAssets.Background.secondary.swiftUIColor)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()

      ZStack {
        viewModel.overlayImage.front
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.x4)
          .scaleEffect(scale)
          .rotation3DEffect(
            .degrees(rotationAngle),
            axis: axis)
          .opacity(rotationVisibilityRange.contains(rotationAngle) ? 0 : 1)
          .accessibilityLabel(L10n.tkEidRequestRecordDocumentOverlayFrontAlt)

        viewModel.overlayImage.back
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.x4)
          .scaleEffect(scale)
          .rotation3DEffect(
            .degrees(rotationAngle + oppositeRotationAngle),
            axis: axis)
          .opacity(rotationVisibilityRange.contains(rotationAngle) ? 1 : 0)
          .accessibilityLabel(L10n.tkEidRequestRecordDocumentOverlayBackAlt)

        if orientation.isLandscape {
          recordButtonView()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, .x4)
        }
      }
      .onChange(of: viewModel.scanningState) { _, newState in
        if newState != currentDisplayState {
          currentDisplayState = newState

          withAnimation(.easeInOut(duration: animationDuration * 2)) {
            rotationAngle = (newState == .verso) ? oppositeRotationAngle : defaultRotationAngle
            scale = animatedScale
          }

          DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation(.easeInOut(duration: animationDuration)) {
              scale = defaultScale
            }
          }
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
    RecordingButton(state: $viewModel.buttonState, onTapInitial: viewModel.startRecordDocument, onTapRecord: viewModel.stopRecordDocument)
      .accessibilityLabel(viewModel.buttonStateAccessibilityLabel)
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
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

extension RecordDocumentView {
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

#Preview {
  RecordDocumentView()
}
