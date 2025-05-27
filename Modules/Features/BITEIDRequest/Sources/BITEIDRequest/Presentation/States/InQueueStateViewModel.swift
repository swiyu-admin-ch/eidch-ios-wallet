import Foundation

public class InQueueStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  init(requestCase: EIDRequestCase) throws {
    guard let onlineSessionStartOpenAt = requestCase.state?.onlineSessionStartOpenAt else {
      throw RequestCaseViewStateError.invalidState
    }

    self.onlineSessionStartOpenAt = onlineSessionStartOpenAt

    try super.init(requestCase: requestCase)
  }

  // MARK: Internal

  let onlineSessionStartOpenAt: Date

  var formattedDate: String {
    onlineSessionStartOpenAt.longDateFormat
  }
}
