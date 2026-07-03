import Factory
import Foundation
import Spyable
import UserNotifications

// MARK: - GetPushPermissionStatusUseCaseProtocol

@Spyable
public protocol GetPushPermissionStatusUseCaseProtocol {
  func callAsFunction() async -> UNAuthorizationStatus
}

// MARK: - GetPushPermissionStatusUseCase

struct GetPushPermissionStatusUseCase: GetPushPermissionStatusUseCaseProtocol {
  func callAsFunction() async -> UNAuthorizationStatus {
    await pushNotificationCenterRepository.notificationSettings().authorizationStatus
  }

  @Injected(\.pushNotificationCenterRepository) private var pushNotificationCenterRepository: PushNotificationCenterRepositoryProtocol
}
