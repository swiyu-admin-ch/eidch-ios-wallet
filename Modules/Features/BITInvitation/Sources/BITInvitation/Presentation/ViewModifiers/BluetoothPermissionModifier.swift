import BITCore
import BITL10n
import BITTheming
import CoreBluetooth
import Factory
import SwiftUI

// MARK: - BluetoothPermissionModifier

struct BluetoothPermissionModifier: ViewModifier {

  // MARK: Lifecycle

  init(isEnabled: Bool = true, _ handler: ((BluetoothPermissionStatus) -> Void)? = nil) {
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
      .onChange(of: isEnabled) { isEnabled in
        if isEnabled {
          refreshPermissionStateIfNeeded(isEnabled: isEnabled)
        } else {
          isPermissionPresented = false
        }
      }
      .onChange(of: state) { newState in
        isPermissionPresented = newState != .authorized
        handler?(newState)
      }
  }

  // MARK: Private

  @Environment(\.dismiss) private var dismiss
  @Environment(\.openURL) private var openURL

  @State private var isPermissionPresented = false
  @State private var requestPermissionTask: Task<Void, Never>?
  @State private var state = BluetoothPermissionStatus.requestPermission

  @Injected(\.requestBluetoothPermissionUseCase) private var requestBluetoothPermissionUseCase: RequestBluetoothPermissionUseCaseProtocol

  private let isEnabled: Bool
  private var handler: ((BluetoothPermissionStatus) -> Void)?

  @ViewBuilder
  private var permissionView: some View {
    switch state {
    case .requestPermission:
      notDeterminedView
    case .goToSettings:
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
        image: Assets.bluetooth.swiftUIImage,
        contents: [
          .title(L10n.tkReceiveBluetoothPermissionPrimary),
          .body(L10n.tkReceiveBluetoothPermissionSecondary),
        ],
        actions: [
          .primary(state.label) { _ in
            openSettings()
          },
        ])
        .toolbar { CloseButtonToolbar(action: { dismiss() }) }
    }
  }

  private var notDeterminedView: some View {
    NavigationStack {
      InformationView2(
        image: Assets.bluetooth.swiftUIImage,
        contents: [
          .title(L10n.tkReceiveBluetoothPermissionPrimary),
          .body(L10n.tkReceiveBluetoothPermissionSecondary),
        ],
        actions: [
          .primary(state.label) { _ in
            requestPermission()
          },
        ])
        .toolbar { CloseButtonToolbar(action: { dismiss() }) }
    }
  }

  private func refreshPermissionStateIfNeeded(isEnabled: Bool) {
    guard isEnabled else { return }
    state = CBManager.authorization.permissionStatus
    isPermissionPresented = state != .authorized
  }

  private func requestPermission() {
    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)
    requestPermissionTask?.cancel()
    requestPermissionTask = Task {
      for await updatedStatus in requestBluetoothPermissionUseCase() {
        state = updatedStatus

        if updatedStatus != .requestPermission {
          NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
        }
      }
    }
  }

  private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}

// MARK: - View Extension

extension View {
  func bluetoothPermission(_ handler: ((BluetoothPermissionStatus) -> Void)? = nil) -> some View {
    modifier(BluetoothPermissionModifier(handler))
  }

  func bluetoothPermission(trigger: Bool, _ handler: ((BluetoothPermissionStatus) -> Void)? = nil) -> some View {
    modifier(BluetoothPermissionModifier(isEnabled: trigger, handler))
  }
}
