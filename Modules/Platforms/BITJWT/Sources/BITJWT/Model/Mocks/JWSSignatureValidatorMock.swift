#if DEBUG
import BITCrypto

public class JWSSignatureValidatorMock<U: JWT>: JWSSignatureValidatorProtocol {

  public var validateReceivedJws: JWS<U>?
  public var validateCallsCount = 0

  public var validateWithJwkReceivedJws: JWS<U>?
  public var validateWithJwkReceivedJwk: JWK?
  public var validateWithJwkCallsCount = 0

  public var validateThrowableError: Error?
  public var validateWithJwkThrowableError: Error?

  public func validate(_ jws: JWS<some JWT>) async throws {
    validateCallsCount += 1
    validateReceivedJws = jws as? JWS<U>
    if let throwingError = validateThrowableError {
      throw throwingError
    }
  }

  public func validate(_ jws: JWS<some JWT>, with jwk: JWK) throws {
    validateWithJwkCallsCount += 1
    validateWithJwkReceivedJws = jws as? JWS<U>
    validateWithJwkReceivedJwk = jwk
    if let throwingError = validateWithJwkThrowableError {
      throw throwingError
    }
  }

}
#endif
