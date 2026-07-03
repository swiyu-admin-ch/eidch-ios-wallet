import BITCore
import Factory
import Spyable
import UserNotifications

// MARK: - RequestPushPermissionUseCaseProtocol

@Spyable
public protocol RequestPushPermissionUseCaseProtocol {
  func callAsFunction() async throws -> Bool
}

// MARK: - RequestPushPermissionUseCase

struct RequestPushPermissionUseCase: RequestPushPermissionUseCaseProtocol {
  func callAsFunction() async throws -> Bool {
    defer {
      NotificationCenter.default.post(name: .permissionAlertFinished, object: nil)
    }

    NotificationCenter.default.post(name: .permissionAlertPresented, object: nil)

    return try await pushNotificationCenterRepository.requestAuthorization(options: [.alert, .badge, .sound])
  }

  @Injected(\.pushNotificationCenterRepository) private var pushNotificationCenterRepository: PushNotificationCenterRepositoryProtocol
}
