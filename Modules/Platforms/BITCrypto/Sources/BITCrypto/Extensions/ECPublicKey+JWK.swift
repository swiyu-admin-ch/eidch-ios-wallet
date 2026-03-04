import JOSESwift

extension ECPublicKey {

  // MARK: Lifecycle

  init(_ jwk: BITCrypto.JWK) throws {
    guard let crv = ECCurveType(rawValue: jwk.crv) else {
      throw ECPublicKeyError.unsupportedRecipientKeyCurve
    }

    self.init(crv: crv, x: jwk.x, y: jwk.y)
  }

  // MARK: Internal

  enum ECPublicKeyError: Error {
    case unsupportedRecipientKeyCurve
  }
}
