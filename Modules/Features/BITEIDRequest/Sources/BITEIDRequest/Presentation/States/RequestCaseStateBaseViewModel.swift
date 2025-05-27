public class RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  public init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    requestCaseId = requestCase.id
    fullName = "\(requestCase.firstName) \(requestCase.lastName)"
    self.delegate = delegate
  }

  // MARK: Public

  public weak var delegate: RequestCaseViewStateDelegate?

  // MARK: Internal

  let fullName: String
  let requestCaseId: String
}
