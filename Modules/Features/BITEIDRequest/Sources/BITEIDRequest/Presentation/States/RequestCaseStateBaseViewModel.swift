import BITEIDRequestShared
import Foundation

// MARK: - RequestCaseStateBaseViewModel

public class RequestCaseStateBaseViewModel: Identifiable {

  // MARK: Lifecycle

  public init(requestCase: EIDRequestCase, delegate: RequestCaseViewStateDelegate? = nil) throws {
    fullName = "\(requestCase.firstName) \(requestCase.lastName)"
    id = requestCase.id
    pushId = requestCase.pushId
    self.delegate = delegate

    guard let consent = requestCase.state?.legalRepresentantConsent else {
      legalRepresentantConsent = .notRequired
      return
    }

    legalRepresentantConsent = consent
  }

  // MARK: Public

  public weak var delegate: RequestCaseViewStateDelegate?

  public let id: String

  // MARK: Internal

  let pushId: String?
  let fullName: String

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

// MARK: Hashable

extension RequestCaseStateBaseViewModel: Hashable {

  public static func == (lhs: RequestCaseStateBaseViewModel, rhs: RequestCaseStateBaseViewModel) -> Bool {
    lhs.id == rhs.id &&
      lhs.fullName == rhs.fullName &&
      lhs.pushId == rhs.pushId &&
      lhs.legalRepresentantConsent == rhs.legalRepresentantConsent
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(fullName)
    hasher.combine(pushId)
    hasher.combine(legalRepresentantConsent)
  }

}
