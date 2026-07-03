public struct LocalizedNotificationContent {

  // MARK: Lifecycle

  public init(title: String?, body: String?) {
    self.title = title
    self.body = body
  }

  // MARK: Public

  public let title: String?
  public let body: String?
}
