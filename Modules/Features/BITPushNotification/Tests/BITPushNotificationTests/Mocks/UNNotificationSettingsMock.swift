import Foundation
import UserNotifications

// swiftlint:disable force_try force_unwrapping

final class UNNotificationSettingsMock: UNNotificationSettings {

  // MARK: Lifecycle

  init(authorizationStatus: UNAuthorizationStatus) {
    authorizationStatusMock = authorizationStatus

    let archiver = NSKeyedArchiver(requiringSecureCoding: false)
    archiver.finishEncoding()
    let unarchiver = try! NSKeyedUnarchiver(forReadingFrom: archiver.encodedData)

    super.init(coder: unarchiver)!
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override var authorizationStatus: UNAuthorizationStatus {
    authorizationStatusMock
  }

  // MARK: Private

  private let authorizationStatusMock: UNAuthorizationStatus
}
