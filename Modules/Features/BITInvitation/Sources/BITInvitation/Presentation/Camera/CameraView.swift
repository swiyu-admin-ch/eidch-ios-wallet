import BITL10n
import BITNavigation
import BITQRCode
import BITTheming
import Factory
import PopupView
import SwiftUI

// MARK: - CameraView

struct CameraView: View {

  // MARK: Lifecycle

  init() {
    _viewModel = State(wrappedValue: Container.shared.cameraViewModel())
  }

  // MARK: Internal

  var body: some View {
    GeometryReader { geo in
      content()
        .cameraPermission { state in
          Task {
            if state == .authorized {
              await viewModel.onAppear()
            }
          }
        }
        .bluetoothPermission(trigger: viewModel.isBluetoothPermissionRequired) { state in
          Task {
            if state == .authorized {
              await viewModel.onAppear()
            }
          }
        }
        .onAppear {
          guard voiceOverEnabled else { return }
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            focus = .camera

            var announcement = AttributedString(L10n.tkQrscannerCameraFeedAlt)
            announcement.accessibilitySpeechAnnouncementPriority = .high
            AccessibilityNotification.Announcement(announcement).post()
          }
        }
        .suspendInactivityTimeout()
        .disablePhoneLock()
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
        .onChange(of: viewModel.onDismiss) { _, newValue in
          if newValue {
            viewModel.resetProximityEngagementIfNeeded()
            navigator.returnToCheckpointSafely(Checkpoints.home, value: .acceptCredential)
          }
        }
        .navigate(to: $viewModel.destination)
        .navigationBarBackButtonHidden()
        .toolbar { toolbarContent() }
        .transparentToolbarBackground(isActive: true, topInset: geo.safeAreaInsets.top)
        .accessibilityElement(children: .contain)
    }
  }

  // MARK: Private

  private enum FocusableElement {
    case tip, close, flashlight, camera, flashlightTip, loadingTip
  }

  @Environment(\.navigator) private var navigator
  @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

  @AccessibilityFocusState private var focus: FocusableElement?

  @State private var viewModel: CameraViewModel

  private let tipViewMaxWidth: CGFloat = 350

  @Orientation private var orientation

  private func content() -> some View {
    scannerView()
      .ignoresSafeArea(edges: orientation.isLandscape ? [.horizontal] : [])
  }
}

// MARK: - Components

extension CameraView {
  private func scannerView() -> some View {
    CameraPreview(
      session: viewModel.cameraManager.session,
      object: viewModel.cameraManager.capturedObject,
      centerFocusAreaOnLeftHalfInLandscape: true,
      viewModel.didMoveFocusArea(to:))
      .ignoresSafeArea()
      .contentShape(
        .accessibility,
        RoundedRectangle(cornerRadius: .x6, style: .continuous)
          .inset(by: .x3))
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(L10n.tkQrscannerScanningTitle)
      .accessibilitySortPriority(AccessibilityPriority.x7.rawValue)
      .accessibilityFocused($focus, equals: .camera)
  }

  private func progressView() -> some View {
    ProgressViewLabelBadge(
      text: L10n.tkGlobalPleasewait,
      background: ThemingAssets.Background.tertiary.swiftUIColor,
      foreground: ThemingAssets.Label.primary.swiftUIColor,
      accessibilityLabel: L10n.tkQrscannerProcessingAlt)
      .accessibilityFocused($focus, equals: .loadingTip)
  }

  private func torchTipView() -> some View {
    LabelBadge(text: L10n.tkQrscannerLightonTitle, backgroundColor: ThemingAssets.Brand.Bright.navyBlue.swiftUIColor, image: "sun.min")
  }

  private func helpTipView() -> some View {
    tipView(primary: L10n.tkQrscannerScanningTitle, secondary: L10n.tkQrscannerScanningBody, icon: Assets.qrcode.swiftUIImage, close: viewModel.closeTipView)
      .frame(maxWidth: orientation.isPortrait ? .infinity : tipViewMaxWidth)
      .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
  }

  @ViewBuilder
  private func errorView(_ error: Error) -> some View {
    let invitationError = error as? InvitationError ?? .invalidQRCode
    tipView(primary: invitationError.primaryText, secondary: invitationError.secondaryText, icon: invitationError.icon, close: viewModel.closeErrorView)
      .frame(maxWidth: orientation.isPortrait ? .infinity : tipViewMaxWidth)
      .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
  }

  private func tipView(primary: String?, secondary: String?, tertiary: String? = nil, icon: Image?, close: @escaping () -> Void) -> some View {
    Notification(
      image: icon,
      imageColor: ThemingAssets.Label.primary.swiftUIColor,
      title: primary,
      titleColor: ThemingAssets.Label.primary.swiftUIColor,
      content: secondary ?? String(),
      contentColor: ThemingAssets.Label.secondary.swiftUIColor,
      closeAction: close,
      background: ThemingAssets.Background.tertiary.swiftUIColor,
      closeButtonStyle: .secondary)
      .accessibilityFocused($focus, equals: .tip)
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: { viewModel.toggleTorch() }, label: {
        viewModel.isTorchEnabled ? Assets.lightOn.swiftUIImage : Assets.lightOff.swiftUIImage
      })
      .colorScheme(.light)
      .contentShape(.accessibility, Circle().inset(by: .x1))
      .accessibilityLabel(viewModel.isTorchEnabled ? L10n.tkQrscannerLightonLabel : L10n.tkQrscannerLightoffLabel)
      .accessibilityFocused($focus, equals: .flashlight)
    }

    ToolbarItem(placement: .principal) {
      Text(L10n.tkQrscannerScanningTitle)
        .font(.custom.body)
        .fontWeight(.semibold)
        .foregroundStyle(ThemingAssets.Brand.Core.white.swiftUIColor)
        .colorScheme(.light)
        .lineLimit(1)
        .accessibilityAddTraits(.isHeader)
    }
  }
}
