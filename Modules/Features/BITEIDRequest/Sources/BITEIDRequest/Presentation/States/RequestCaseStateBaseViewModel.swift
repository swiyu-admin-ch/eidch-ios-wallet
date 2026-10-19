import BITEIDRequestShared
import Foundation

// MARK: - RequestCaseStateBaseViewModel

@MainActor
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

  public nonisolated let id: String

  // MARK: Internal

  nonisolated let pushId: String?
  nonisolated let fullName: String

  var isLegalRepresentantConsentVerified: Bool {
    switch legalRepresentantConsent {
    case .notRequired,
         .verified: true
    case
      .notVerified: false
    }
  }

  // MARK: Private

  private nonisolated let legalRepresentantConsent: LegalRepresentantConsent

}

// MARK: Hashable

extension RequestCaseStateBaseViewModel: Hashable {

  public nonisolated static func == (lhs: RequestCaseStateBaseViewModel, rhs: RequestCaseStateBaseViewModel) -> Bool {
    lhs.id == rhs.id &&
      lhs.fullName == rhs.fullName &&
      lhs.pushId == rhs.pushId &&
      lhs.legalRepresentantConsent == rhs.legalRepresentantConsent
  }

  public nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(fullName)
    hasher.combine(pushId)
    hasher.combine(legalRepresentantConsent)
  }

}
