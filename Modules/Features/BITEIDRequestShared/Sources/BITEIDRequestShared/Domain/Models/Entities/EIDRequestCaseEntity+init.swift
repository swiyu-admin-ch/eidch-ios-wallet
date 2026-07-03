import BITEntities

extension EIDRequestCaseEntity {

  // MARK: Lifecycle

  public convenience init(_ requestCase: EIDRequestCase) {
    self.init()
    id = requestCase.id
    setValues(from: requestCase)
  }

  // MARK: Public

  public func setValues(from requestCase: EIDRequestCase) {
    rawMRZ = requestCase.rawMRZ

    if let requestCaseState = requestCase.state, requestCaseState.id != state?.id {
      state = EIDRequestStateEntity(requestCaseState)
    }

    documentNumber = requestCase.documentNumber
    selectedDocumentType = requestCase.selectedDocumentType.rawValue
    firstName = requestCase.firstName
    lastName = requestCase.lastName
    createdAt = requestCase.createdAt
    filesSubmitted = requestCase.filesSubmitted
    pushId = requestCase.pushId

    if let credential = requestCase.deferredCredential, credential.id != self.credential?.id {
      self.credential = CredentialEntity(deferredCredential: credential)
    }
  }
}
