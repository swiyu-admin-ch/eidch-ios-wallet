#if DEBUG

public class JWSSignatureValidatorMock<U: JWT>: JWSSignatureValidatorProtocol {

  public var validateIssuerDidReceivedJws: JWS<U>?
  public var validateIssuerDidReceivedDid: String?
  public var validateIssuerDidCallsCount = 0

  public var validateIssuerDidThrowableError: Error?

  public func validate(_ jws: some JWS<some Codable & Equatable>, issuerDid: String) async throws {
    validateIssuerDidCallsCount += 1
    validateIssuerDidReceivedJws = jws as? JWS<U>
    validateIssuerDidReceivedDid = issuerDid
    if let throwingError = validateIssuerDidThrowableError {
      throw throwingError
    }
  }

}
#endif
