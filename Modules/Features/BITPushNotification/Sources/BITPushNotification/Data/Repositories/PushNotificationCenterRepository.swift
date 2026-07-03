import Spyable
import UserNotifications

// MARK: - PushNotificationCenterRepositoryProtocol

@Spyable
protocol PushNotificationCenterRepositoryProtocol {
  func notificationSettings() async -> UNNotificationSettings
  func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
}

// MARK: - UNUserNotificationCenter + PushNotificationCenterRepositoryProtocol

extension UNUserNotificationCenter: PushNotificationCenterRepositoryProtocol {}
