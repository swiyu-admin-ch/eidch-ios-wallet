import Foundation

@MainActor
class QueueInformationViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, onlineSessionStartDate: Date) {
    self.router = router
    expectedOnlineSessionStart = onlineSessionStartDate.longDateFormat
  }

  // MARK: Internal

  var expectedOnlineSessionStart: String

  func primaryAction() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
