import BITEIDRequestShared
import BITL10n
import BITPushNotification
import Factory
import NavigatorUI
import SwiftUI

struct PushPermissionView: View {

  // MARK: Lifecycle

  init(_ requestCase: EIDRequestCase) {
    _viewModel = State(initialValue: Container.shared.pushPermissionViewModel(requestCase))
  }

  // MARK: Internal

  var body: some View {
    BITPushNotification.PushPermissionView(
      permissionNotDeterminedTitle: L10n.tkPushNotificationPermissionTitle,
      permissionNotDeterminedBody: L10n.tkPushNotificationPermissionBody,
      permissionDeniedTitle: L10n.tkPushNotificationPermissionDeniedTitle,
      permissionDeniedBody: L10n.tkPushNotificationPermissionDeniedBody,
      primaryButtonNotDeterminatedTitle: L10n.tkGlobalContinue,
      primaryButtonDeniedTitle: L10n.tkGlobalTothesettings,
      onSkipAction: {
        Task {
          await viewModel.continueNavigation(withPush: false)
        }
      },
      onErrorAction: viewModel.presentError,
      onGrantPermissionAction: {
        Task {
          await viewModel.continueNavigation(withPush: true)
        }
      },
      onDeniedPermissionAction: openSettings,
      onCloseAction: close)
      .navigate(to: $viewModel.destination)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @State private var viewModel: PushPermissionViewModel

  @Environment(\.openURL) private var openURL

  @Injected(\.eidRequestFlowCoordinator) private var coordinator: EIDRequestFlowCoordinatorProtocol

  private func close() {
    coordinator.cleanup()
    navigator.dismiss()
  }

  private func openSettings() {
    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
    openURL(url)
  }
}
