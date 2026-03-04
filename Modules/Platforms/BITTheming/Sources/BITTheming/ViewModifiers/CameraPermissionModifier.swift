import AVFoundation
import BITCore
import BITL10n
import SwiftUI

// MARK: - CameraPermissionModifier

struct CameraPermissionModifier: ViewModifier {

  // MARK: Internal

  func body(content: Content) -> some View {
    let transition = AnyTransition.asymmetric(
      insertion: .identity,
      removal: .push(from: .trailing)).combined(with: .opacity)

    Group {
      if state == .authorized {
        content
          .transition(transition)
      } else {
        permissionView()
          .transition(transition)
      }
    }
    .animation(.easeInOut, value: state)
  }

  // MARK: Private

  @Environment(\.openURL) private var openURL

  @State private var state = AVCaptureDevice.authorizationStatus(for: .video)

  @ViewBuilder
  private func permissionView() -> some View {
    switch state {
    case .notDetermined:
      notDeterminedView()
    case .denied,
         .restricted:
      deniedView()
    case .authorized:
      EmptyView()
    @unknown default:
      notDeterminedView()
    }
  }

  private func deniedView() -> some View {
    InformationView(
      image: ThemingAssets.camera.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkReceiveCameraaccessneeded3Title,
          secondary: L10n.tkReceiveCameraaccessneeded3Body)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalTothesettings,
          primaryButtonAction: { openLink(UIApplication.openSettingsURLString) })
      })
  }

  private func notDeterminedView() -> some View {
    InformationView(
      image: ThemingAssets.camera.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkReceiveCameraaccessneeded1Title,
          secondary: L10n.tkReceiveCameraaccessneeded1Body)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGlobalContinue,
          primaryButtonAction: { Task { await requestPermission() } })
      })
  }

  private func openLink(_ urlString: String) {
    guard let url = URL(string: urlString) else { return }
    openURL(url)
  }

  private func requestPermission() async {
    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
    let status = await AVCaptureDevice.requestAccess(for: .video)
    NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
    state = status ? .authorized : .denied
  }
}

// MARK: - View Extension

extension View {
  public func cameraPermission() -> some View {
    modifier(CameraPermissionModifier())
  }
}
