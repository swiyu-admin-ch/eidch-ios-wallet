import BITCore
import Foundation

// MARK: - NotificationLocalizationServiceProtocol

public protocol NotificationLocalizationServiceProtocol {
  func localize(from data: [String: Any], considering languageCodes: [UserLanguageCode]) -> LocalizedNotificationContent?
}

// MARK: - NotificationLocalizationService

struct NotificationLocalizationService: NotificationLocalizationServiceProtocol {
  func localize(from data: [String: Any], considering languageCodes: [UserLanguageCode]) -> LocalizedNotificationContent? {
    guard
      let payloadData = try? JSONSerialization.data(withJSONObject: data),
      let content = try? JSONDecoder().decode(LocalizedNotificationPayload.self, from: payloadData)
    else {
      return nil
    }

    let notificationContent = LocalizedNotificationContent(
      title: content.title?.getPreferredDisplay(considering: languageCodes),
      body: content.body?.getPreferredDisplay(considering: languageCodes))

    guard notificationContent.title != nil || notificationContent.body != nil else {
      return nil
    }

    return notificationContent
  }
}
