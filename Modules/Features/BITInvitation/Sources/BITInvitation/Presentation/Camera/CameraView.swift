import BITL10n
import BITNavigation
import BITQRCode
import BITTheming
import Factory
import PopupView
import SwiftUI

// MARK: - CameraView

struct CameraView: View {

  // MARK: Internal

  var body: some View {
    GeometryReader { geo in
      content
        .cameraPermission { state in
          Task {
            await viewModel.onCameraPermissionChange(state)
          }
        }
        .bluetoothPermission(trigger: viewModel.isBluetoothPermissionRequired) { state in
          Task {
            if state == .authorized {
              await viewModel.onAppear()
            }
          }
        }
        .popup(isPresented: $viewModel.isTorchEnabled) {
          torchTipView
        } customize: {
          $0.type(.floater())
            .closeOnTap(false)
            .appearFrom(.bottomSlide)
            .dismissCallback {
              focus = .flashlight
            }
        }
        .popup(item: $viewModel.notificationState, itemView: notificationView, customize: customizeNotification)
        .onChange(of: viewModel.notificationState, focusOnNotificationIfNeeded)
        .popup(isPresented: $viewModel.isLoading) {
          progressView
        } customize: {
          $0.type(.floater())
            .appearFrom(.centerScale)
            .position(.bottom)
        }
        .onChange(of: viewModel.onDismiss) { _, newValue in
          if newValue {
            viewModel.resetProximityEngagementIfNeeded()
            navigator.returnToHomeSafely(with: .acceptCredential)
          }
        }
        .navigate(to: $viewModel.destination)
        .navigationBarBackButtonHidden()
        .navigationTitle(L10n.tkQrscannerScanningTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .transparentToolbarBackground(isActive: true, topInset: geo.safeAreaInsets.top)
        .accessibilityElement(children: .contain)
    }
  }

  // MARK: Private

  private enum FocusableElement {
    case tip, close, flashlight, flashlightTip
  }

  @Environment(\.navigator) private var navigator
  @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

  @AccessibilityFocusState private var focus: FocusableElement?

  private let tipViewMaxWidth: CGFloat = 350

  @Orientation private var orientation
  @InjectedObservable(\.cameraViewModel) private var viewModel

  private var content: some View {
    scannerView
      .ignoresSafeArea(edges: orientation.isLandscape ? [.horizontal] : [])
  }

  private func focusOnNotificationIfNeeded(oldValue: CameraViewModel.NotificationState?, newState: CameraViewModel.NotificationState?) {
    guard let newState else { return }
    Task { @MainActor in
      try await Task.sleep(seconds: 0.3)
      guard !Task.isCancelled, viewModel.notificationState == newState else { return }
      focus = .tip
    }
  }
}

// MARK: - Components

extension CameraView {
  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: { viewModel.toggleTorch() }, label: {
        Image(systemName: viewModel.isTorchEnabled ? "flashlight.on.fill" : "flashlight.off.fill")
      })
      .contentShape(.accessibility, Circle().inset(by: .x1))
      .accessibilityLabel(viewModel.isTorchEnabled ? L10n.tkQrscannerLightonLabel : L10n.tkQrscannerLightoffLabel)
      .accessibilityFocused($focus, equals: .flashlight)
    }
  }

  private var scannerView: some View {
    CameraPreview(
      session: viewModel.cameraManager.session,
      object: viewModel.cameraManager.capturedObject,
      centerFocusAreaOnLeftHalfInLandscape: true,
      viewModel.didMoveFocusArea(to:))
      .ignoresSafeArea()
      .accessibilityHidden(true)
  }

  private var progressView: some View {
    ProgressViewLabelBadge(
      text: L10n.tkGlobalPleasewait,
      background: ThemingAssets.Background.tertiary.swiftUIColor,
      foreground: ThemingAssets.Label.primary.swiftUIColor)
      .accessibilityHidden(true)
  }

  private var torchTipView: some View {
    LabelBadge(text: L10n.tkQrscannerLightonTitle, backgroundColor: ThemingAssets.Brand.Bright.navyBlue.swiftUIColor, image: "sun.min")
  }

}

// MARK: - Notification Popups

extension CameraView {
  private var helpTipView: some View {
    tipView(
      primary: L10n.tkQrscannerScanningTitle,
      secondary: L10n.tkQrscannerScanningBody,
      icon: Assets.qrcode.swiftUIImage,
      close: viewModel.closeTipView)
      .frame(maxWidth: orientation.isPortrait ? .infinity : tipViewMaxWidth)
      .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
  }

  @ViewBuilder
  private func notificationView(_ notification: CameraViewModel.NotificationState) -> some View {
    if orientation.isPortrait {
      notificationContent(notification)
    } else {
      HStack {
        Spacer()
        notificationContent(notification)
      }
    }
  }

  @ViewBuilder
  private func notificationContent(_ notification: CameraViewModel.NotificationState) -> some View {
    switch notification {
    case .tip: helpTipView
    case .failure(let error): errorView(error)
    }
  }

  private func errorView(_ error: Error) -> some View {
    let invitationError = error as? InvitationError ?? .invalidQRCode()
    return tipView(
      primary: invitationError.primaryText,
      secondary: invitationError.secondaryText,
      icon: invitationError.icon,
      close: viewModel.closeErrorView)
      .frame(maxWidth: orientation.isPortrait ? .infinity : tipViewMaxWidth)
      .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
  }

  private func tipView(
    primary: String?,
    secondary: String?,
    tertiary: String? = nil,
    icon: Image?,
    close: @escaping () -> Void)
    -> some View
  {
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

  private func customizeNotification<PopupContent: View>(_ parameters: Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters {
    switch viewModel.notificationState {
    case .none:
      parameters

    case .tip:
      parameters
        .type(.floater())
        .appearFrom(.bottomSlide)

    case .failure:
      parameters
        .type(.floater())
        .appearFrom(.bottomSlide)
        .autohideIn(voiceOverEnabled ? nil : 7)
    }
  }

}
