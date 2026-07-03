import Foundation

extension Notification.Name {

  public static let receivedMessages = Notification.Name("ReceivedMessages")
  public static let startPollingMessages = Notification.Name("StartPollingMessages")
  public static let logout = Notification.Name("Logout")
  public static let didLogin = Notification.Name("DidLogin")
  public static let didLoginClose = Notification.Name("DidLoginClose")
  public static let loginRequired = Notification.Name("LoginRequired")
  public static let willEnterForeground = Notification.Name("willEnterForeground")
  public static let didEnterBackground = Notification.Name("didEnterBackground")
  public static let userInactivityTimeout = Notification.Name("userInactivityTimeout")
  public static let pauseUserInactivityTimeout = Notification.Name("pauseUserInactivityTimeout")
  public static let resumeUserInactivityTimeout = Notification.Name("resumeUserInactivityTimeout")

  public static let permissionAlertPresented = Notification.Name("permissionAlertPresented")
  public static let permissionAlertFinished = Notification.Name("permissionAlertFinished")
  public static let windowDidUpdateFocus = Notification.Name("windowDidUpdateFocus")
  public static let windowPressesBegan = Notification.Name("windowPressesBegan")
}
