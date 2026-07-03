import BITCore
import BITPushNotification
import Factory
import UserNotifications

final class NotificationServiceExtension: UNNotificationServiceExtension {

  // MARK: Internal

  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void)
  {
    self.contentHandler = contentHandler
    bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

    guard
      let bestAttemptContent,
      let data = bestAttemptContent.userInfo["data"] as? [String: Any],
      let localization = notificationLocalizationService.localize(from: data, considering: preferredUserLanguageCodes)
    else {
      return contentHandler(request.content)
    }

    if let title = localization.title {
      bestAttemptContent.title = title
    }

    if let body = localization.body {
      bestAttemptContent.body = body
    }

    contentHandler(bestAttemptContent)
  }

  override func serviceExtensionTimeWillExpire() {
    guard let contentHandler, let bestAttemptContent else {
      return
    }

    contentHandler(bestAttemptContent)
  }

  // MARK: Private

  private var contentHandler: ((UNNotificationContent) -> Void)?
  private var bestAttemptContent: UNMutableNotificationContent?

  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @Injected(\.notificationLocalizationService) private var notificationLocalizationService: NotificationLocalizationServiceProtocol
}
