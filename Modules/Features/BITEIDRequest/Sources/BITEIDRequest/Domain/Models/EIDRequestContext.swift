import BITEIDRequestShared

class EIDRequestContext {

  // MARK: Lifecycle

  init(hasLegalRepresentant: Bool = false, identityType: IdentityType? = nil, caseId: String? = nil, autoVerificationResponse: AutoVerificationResponse? = nil) {
    self.hasLegalRepresentant = hasLegalRepresentant
    self.identityType = identityType
    self.caseId = caseId
    self.autoVerificationResponse = autoVerificationResponse
  }

  // MARK: Internal

  var hasLegalRepresentant = false
  var identityType: IdentityType?
  var caseId: String?
  var autoVerificationResponse: AutoVerificationResponse?

}
