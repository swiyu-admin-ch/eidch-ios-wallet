import Factory
import Observation
import UserNotifications

// MARK: - PushPermissionViewModel

@Observable @MainActor
final class PushPermissionViewModel {

  // MARK: Lifecycle

  init(onGrantedAction: @escaping () -> Void, onErrorAction: @escaping () -> Void) {
    self.onGrantedAction = onGrantedAction
    self.onErrorAction = onErrorAction
  }

  // MARK: Internal

  var isLoading = true
  var permissionStatus = UNAuthorizationStatus.notDetermined

  func refreshPermissionStatus() async {
    isLoading = true
    permissionStatus = await getPushPermissionStatusUseCase()
    isLoading = false
  }

  func requestPermission() async {
    do {
      if try await requestPushPermissionUseCase() {
        return onGrantedAction()
      }

      await refreshPermissionStatus()
    } catch {
      onErrorAction()
    }
  }

  // MARK: Private

  private let onErrorAction: () -> Void
  private let onGrantedAction: () -> Void

  @ObservationIgnored @Injected(\.requestPushPermissionUseCase) private var requestPushPermissionUseCase: RequestPushPermissionUseCaseProtocol
  @ObservationIgnored @Injected(\.getPushPermissionStatusUseCase) private var getPushPermissionStatusUseCase: GetPushPermissionStatusUseCaseProtocol
}
