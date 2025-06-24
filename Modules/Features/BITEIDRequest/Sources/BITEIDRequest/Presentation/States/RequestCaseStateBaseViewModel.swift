public class RequestCaseStateBaseViewModel {

  // MARK: Lifecycle

  public init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    requestCaseId = requestCase.id
    fullName = "\(requestCase.firstName) \(requestCase.lastName)"
    self.delegate = delegate

    guard let consent = requestCase.state?.legalRepresentantConsent else {
      legalRepresentantConsent = .notRequired
      return
    }

    legalRepresentantConsent = consent
  }

  // MARK: Public

  public weak var delegate: RequestCaseViewStateDelegate?

  // MARK: Internal

  let fullName: String
  let requestCaseId: String

  var isLegalRepresentantConsentVerified: Bool {
    switch legalRepresentantConsent {
    case .notRequired,
         .verified: true
    case
      .notVerified: false
    }
  }

  // MARK: Private

  private let legalRepresentantConsent: LegalRepresentantConsent

}
