import BITL10n
import BITQRCode
import BITTheming
import Factory
import PopupView
import SwiftUI

// MARK: - CameraView

struct CameraView: View {

  // MARK: Lifecycle

  init(router: InvitationRouterRoutes, delegate: InvitationDelegate? = nil) {
    _viewModel = StateObject(wrappedValue: Container.shared.cameraViewModel((router, delegate)))
  }

  // MARK: Internal

  var body: some View {
    content()
      .onAppear {
        UIAccessibility.post(notification: .screenChanged, argument: L10n.tkQrscannerScanningTitle)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          focus = .camera
        }
      }
      .popup(isPresented: $viewModel.isTorchEnabled) {
        torchTipView()
      } customize: {
        $0.type(.floater())
          .closeOnTap(false)
          .appearFrom(.bottomSlide)
          .dismissCallback {
            focus = .flashlight
          }
      }
      .popup(isPresented: $viewModel.isTipPresented) {
        if orientation.isPortrait {
          helpTipView()
        } else {
          HStack {
            Spacer()
            helpTipView()
          }
        }
      } customize: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          focus = .tip
        }
        return $0.type(.floater())
          .appearFrom(.bottomSlide)
          .dismissCallback {
            focus = .camera
          }
      }
      .popup(isPresented: $viewModel.isLoading) {
        progressView()
      } customize: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          focus = .loadingTip
        }
        return $0.type(.floater())
          .appearFrom(.centerScale)
          .position(.center)
      }
      .popup(isPresented: $viewModel.isErrorPopupPresented) {
        if let error = viewModel.error {
          if orientation.isPortrait {
            errorView(error)
          } else {
            HStack {
              Spacer()
              errorView(error)
            }
          }
        }
      } customize: {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          focus = .tip
        }
        return $0.type(.floater())
          .appearFrom(.bottomSlide)
          .autohideIn(voiceOverEnabled ? nil : 7)
          .dismissCallback {
            focus = .camera
          }
      }
      .task {
        await viewModel.onAppear()
      }
      .navigationBarBackButtonHidden()
      .toolbar { toolbarContent() }
      .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private enum Constants {
    static let tipViewMaxWidth: CGFloat = 350
  }

  private enum FocusableElement {
    case tip, close, flashlight, camera, flashlightTip, loadingTip
  }

  @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

  @AccessibilityFocusState private var focus: FocusableElement?
  @StateObject private var viewModel: CameraViewModel

  @Orientation private var orientation

  @ViewBuilder
  private func content() -> some View {
    scannerView()
      .ignoresSafeArea(edges: orientation.isLandscape ? [.horizontal] : [])
  }

}

// MARK: - Components

extension CameraView {
  @ViewBuilder
  private func scannerView() -> some View {
    CameraPreview(session: viewModel.session, object: viewModel.cameraManager.capturedObject, viewModel.didMoveFocusArea(to:))
      .clipShape(RoundedCorner(radius: .x6, corners: [.topLeft, .topRight]))
      .padding(.top, .x2)
      .ignoresSafeArea(edges: [.bottom])
      .accessibilityLabel(L10n.tkQrscannerScanningTitle)
      .accessibilityElement(children: .contain)
      .accessibilitySortPriority(100)
      .accessibilityFocused($focus, equals: .camera)
  }

  @ViewBuilder
  private func progressView() -> some View {
    ProgressViewLabelBadge(
      text: L10n.tkGlobalPleasewait,
      background: ThemingAssets.Background.tertiary.swiftUIColor,
      foreground: ThemingAssets.Label.primary.swiftUIColor,
      accessibilityLabel: L10n.tkQrscannerProcessingAlt)
      .accessibilityFocused($focus, equals: .loadingTip)
  }

  @ViewBuilder
  private func torchTipView() -> some View {
    LabelBadge(text: L10n.tkQrscannerLightonTitle, backgroundColor: ThemingAssets.Brand.Bright.navyBlue.swiftUIColor, image: "sun.min")
  }

  @ViewBuilder
  private func helpTipView() -> some View {
    tipView(primary: L10n.tkQrscannerScanningTitle, secondary: L10n.tkQrscannerScanningBody, icon: Assets.qrcode.swiftUIImage, close: viewModel.closeTipView)
      .frame(maxWidth: orientation.isPortrait ? .infinity : Constants.tipViewMaxWidth)
      .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
  }

  @ViewBuilder
  private func errorView(_ error: InvitationError) -> some View {
    tipView(primary: error.primaryText, secondary: error.secondaryText, icon: error.icon, close: viewModel.closeErrorView)
      .frame(maxWidth: orientation.isPortrait ? .infinity : Constants.tipViewMaxWidth)
      .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
  }

  @ViewBuilder
  private func tipView(primary: String, secondary: String, tertiary: String? = nil, icon: Image, close: @escaping() -> Void) -> some View {
    Notification(
      image: icon,
      imageColor: ThemingAssets.Label.primary.swiftUIColor,
      title: primary,
      titleColor: ThemingAssets.Label.primary.swiftUIColor,
      content: secondary,
      contentColor: ThemingAssets.Label.secondary.swiftUIColor,
      closeAction: close,
      background: ThemingAssets.Background.tertiary.swiftUIColor,
      closeButtonStyle: .secondary)
      .accessibilityFocused($focus, equals: .tip)
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
      Button(action: { viewModel.toggleTorch() }, label: {
        viewModel.isTorchEnabled ? Assets.lightOn.swiftUIImage : Assets.lightOff.swiftUIImage
      })
      .accessibilityLabel(viewModel.isTorchEnabled ? L10n.tkQrscannerLightonLabel : L10n.tkQrscannerLightoffLabel)
      .accessibilitySortPriority(20)
      .accessibilityFocused($focus, equals: .flashlight)
    }

    ToolbarItem(placement: .topBarTrailing) {
      Button(action: viewModel.close, label: {
        ThemingAssets.close.swiftUIImage
      })
      .accessibilitySortPriority(10)
      .accessibilityFocused($focus, equals: .close)
      .accessibilityLabel(L10n.tkQrscannerButtonCloseAlt)
    }
  }
}
