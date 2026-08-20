import Spyable
import UserNotifications

// MARK: - PushNotificationCenterRepositoryProtocol

@Spyable
protocol PushNotificationCenterRepositoryProtocol {
  func notificationSettings() async -> UNNotificationSettings
  func requestAuthorization(options: UNAuthorizationOptions) async throws -> Bool
  func setBadgeCount(_ count: Int) async throws
}

// MARK: - UNUserNotificationCenter + PushNotificationCenterRepositoryProtocol

extension UNUserNotificationCenter: PushNotificationCenterRepositoryProtocol {}
