import Foundation

public class ReadyForOnlineSessionStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  override init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    guard let onlineSessionStartTimeoutAt = requestCase.state?.onlineSessionStartTimeoutAt else {
      throw RequestCaseViewStateError.invalidState
    }

    self.onlineSessionStartTimeoutAt = onlineSessionStartTimeoutAt

    try super.init(requestCase: requestCase, delegate: delegate)
  }

  // MARK: Internal

  let onlineSessionStartTimeoutAt: Date

  var formattedDate: String {
    onlineSessionStartTimeoutAt.longDateFormat
  }

  func primaryAction() {
    delegate?.didStartAutoVerification()
  }
}
