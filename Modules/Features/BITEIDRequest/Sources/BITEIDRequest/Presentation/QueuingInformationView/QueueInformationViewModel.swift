import Foundation

class QueueInformationViewModel {

  // MARK: Lifecycle

  init(onlineSessionStartDate: Date) {
    expectedOnlineSessionStart = onlineSessionStartDate.longDateFormat
  }

  // MARK: Internal

  var expectedOnlineSessionStart: String

}
