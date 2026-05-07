import BITEntities

extension CredentialAuthenticationEntity {

  // MARK: Lifecycle

  public convenience init(_ authentication: CredentialAuthentication) {
    self.init()
    setValues(from: authentication)
  }

  // MARK: Internal

  func setValues(from authentication: CredentialAuthentication) {
    accessToken = authentication.accessToken
    tokenType = authentication.tokenType.rawValue
    refreshToken = authentication.refreshToken
    dpopBinding = authentication.dpopBinding
      .map(DPoPBindingEntity.init)
      .map { $0.upserted(in: realm) }
  }
}
