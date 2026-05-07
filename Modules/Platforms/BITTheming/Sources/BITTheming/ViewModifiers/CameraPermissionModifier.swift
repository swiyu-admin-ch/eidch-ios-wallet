import AVFoundation
import BITCore
import BITL10n
import SwiftUI

// MARK: - CameraPermissionModifier

struct CameraPermissionModifier: ViewModifier {

  // MARK: Lifecycle

  init(isEnabled: Bool = true, _ handler: ((AVAuthorizationStatus) -> Void)? = nil) {
    self.isEnabled = isEnabled
    self.handler = handler
  }

  // MARK: Internal

  func body(content: Content) -> some View {
    let transition = AnyTransition.asymmetric(
      insertion: .identity,
      removal: .push(from: .trailing)).combined(with: .opacity)

    content
      .fullScreenCover(isPresented: $isPermissionPresented) {
        permissionView
          .transition(transition)
      }
      .animation(.easeInOut, value: state)
      .onAppear {
        refreshPermissionStateIfNeeded(isEnabled: isEnabled)
      }
      .onChange(of: isEnabled) { _, isEnabled in
        if isEnabled {
          refreshPermissionStateIfNeeded(isEnabled: isEnabled)
        } else {
          isPermissionPresented = false
        }
      }
      .onChange(of: state) { _, newState in
        isPermissionPresented = newState != .authorized
        handler?(newState)
      }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  @State private var isPermissionPresented = false
  @State private var state = AVAuthorizationStatus.notDetermined

  private let isEnabled: Bool
  private var handler: ((AVAuthorizationStatus) -> Void)?

  @ViewBuilder
  private var permissionView: some View {
    switch state {
    case .notDetermined:
      notDeterminedView
    case .denied,
         .restricted:
      deniedView
    case .authorized:
      EmptyView()
    @unknown default:
      notDeterminedView
    }
  }

  private var deniedView: some View {
    NavigationStack {
      InformationView2(
        image: ThemingAssets.camera.swiftUIImage,
        contents: [
          .title(L10n.tkReceiveCameraaccessneeded3Title),
          .body(L10n.tkReceiveCameraaccessneeded3Body),
        ],
        actions: [
          .primary(L10n.tkGlobalTothesettings) { _ in
            openLink(UIApplication.openSettingsURLString)
          },
        ])
        .toolbar { CloseButtonToolbar(action: { dismiss() }) }
    }
  }

  private var notDeterminedView: some View {
    NavigationStack {
      InformationView2(
        image: ThemingAssets.camera.swiftUIImage,
        contents: [
          .title(L10n.tkReceiveCameraaccessneeded1Title),
          .body(L10n.tkReceiveCameraaccessneeded1Body),
        ],
        actions: [
          .primary(L10n.tkGlobalContinue) { _ in
            Task { await requestPermission() }
          },
        ])
        .toolbar { CloseButtonToolbar(action: { dismiss() }) }
    }
  }

  private func openLink(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    openURL(url)
  }

  @MainActor
  private func requestPermission() async {
    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
    _ = await AVCaptureDevice.requestAccess(for: .video)
    NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
    state = AVCaptureDevice.authorizationStatus(for: .video)
  }

  private func refreshPermissionStateIfNeeded(isEnabled: Bool) {
    guard isEnabled else { return }
    state = AVCaptureDevice.authorizationStatus(for: .video)
    isPermissionPresented = state != .authorized
  }
}

// MARK: - View Extension

extension View {
  public func cameraPermission(_ handler: ((AVAuthorizationStatus) -> Void)? = nil) -> some View {
    modifier(CameraPermissionModifier(handler))
  }

  public func cameraPermission(trigger: Bool, _ handler: ((AVAuthorizationStatus) -> Void)? = nil) -> some View {
    modifier(CameraPermissionModifier(isEnabled: trigger, handler))
  }
}
