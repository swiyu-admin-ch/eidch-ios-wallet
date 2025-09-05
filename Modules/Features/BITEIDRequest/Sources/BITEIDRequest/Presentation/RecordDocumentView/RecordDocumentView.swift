import BITAVWrapper
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - RecordDocumentView

struct RecordDocumentView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.recordDocumentViewModel(router))
  }

  // MARK: Internal

  var body: some View {
    VStack {
      switch viewModel.state {
      case .sdkInitializing:
        loadingView()
      case .ready:
        cameraView()
      case .error(let error):
        Text(error.localizedDescription)
      }
    }
    .task {
      await viewModel.setup()
    }
    .readSize { size in
      self.size = size
    }
    .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  @State private var size = CGSize.zero
  @State private var rotationAngle: Double = 0
  @State private var currentDisplayState = RecordDocumentViewModel.ScanningState.recto
  @State private var scale = 1.0

  @StateObject private var viewModel: RecordDocumentViewModel

  private let defaultScale = 1.0
  private let axis: (x: CGFloat, y: CGFloat, z: CGFloat) = (x: 0, y: 1, z: 0)
  private let animationDuration: TimeInterval = 0.4
  private let animatedScale: CGFloat = 0.95
  private let animatedRotationAngle: Double = 90
  private let rotationAngleOpposite: Double = 180
  private let rotationVisibilityRange: Range<Double> = 90..<270
  private let defaultRotationAngle: Double = 0

  @ViewBuilder
  private func introductionPopupView(_ state: RecordDocumentViewModel.ScanningState) -> some View {
    Notification(
      title: state.popupTitle,
      titleColor: ThemingAssets.Label.primary.swiftUIColor,
      content: state.popupContent,
      contentColor: ThemingAssets.Label.primary.swiftUIColor,
      closeAction: viewModel.closeIntroductionPopup,
      background: ThemingAssets.Background.secondary.swiftUIColor, closeButtonStyle: .bezeledLight)
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

extension RecordDocumentView {
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

        viewModel.overlayImage.back
          .resizable()
          .aspectRatio(contentMode: .fit)
          .padding(.x4)
          .scaleEffect(scale)
          .rotation3DEffect(
            .degrees(rotationAngle + rotationAngleOpposite),
            axis: axis)
          .opacity(rotationVisibilityRange.contains(rotationAngle) ? 1 : 0)
      }
      .onReceive(viewModel.$scanningState) { newState in
        if newState != currentDisplayState {
          currentDisplayState = newState

          withAnimation(.easeInOut(duration: animationDuration * 2)) {
            if newState == .verso {
              rotationAngle = rotationAngleOpposite
            } else {
              rotationAngle = defaultRotationAngle
            }
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
    .task {
      await viewModel.startRecordDocument()
    }
    .onDisappear(perform: {
      viewModel.stop()
    })
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
}

#Preview {
  RecordDocumentView(router: EIDRequestRouter())
}
