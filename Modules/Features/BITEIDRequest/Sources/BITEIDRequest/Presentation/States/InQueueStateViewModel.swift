import Foundation

public class InQueueStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  override init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    guard let onlineSessionStartOpenAt = requestCase.state?.onlineSessionStartOpenAt else {
      throw RequestCaseViewStateError.invalidState
    }

    self.onlineSessionStartOpenAt = onlineSessionStartOpenAt

    try super.init(requestCase: requestCase, delegate: delegate)
  }

  // MARK: Internal

  let onlineSessionStartOpenAt: Date

  var formattedDate: String {
    onlineSessionStartOpenAt.longDateFormat
  }

  func primaryAction() {
    delegate?.didTapObtainConsent(caseId: requestCaseId)
  }

}
