#if DEBUG
import BITCrypto
import Foundation

public actor JWSSignatureValidatorMock<U: JWT>: JWSSignatureValidatorProtocol {

  public init() {}

  // MARK: Asynchronous validation (actor-isolated)

  public private(set) var validateReceivedJws: JWS<U>?
  public private(set) var validateCallsCount = 0
  public nonisolated(unsafe) var validateThrowableError: Error?

  public private(set) var validateDetachedJWSReceivedArguments: (detachedJWS: DetachedJWS, payload: Data)?
  public private(set) var validateDetachedJWSCallsCount = 0
  public nonisolated(unsafe) var validateDetachedJWSThrowableError: Error?

  public var validateDetachedJWSCalled: Bool {
    validateDetachedJWSCallsCount > 0
  }

  public func validate(_ jws: JWS<some JWT>) async throws {
    validateCallsCount += 1
    validateReceivedJws = jws as? JWS<U>
    if let validateThrowableError {
      throw validateThrowableError
    }
  }

  public func validate(_ detachedJWS: DetachedJWS, payload: Data) async throws {
    validateDetachedJWSCallsCount += 1
    validateDetachedJWSReceivedArguments = (detachedJWS, payload)
    if let validateDetachedJWSThrowableError {
      throw validateDetachedJWSThrowableError
    }
  }

  // MARK: Synchronous validation (nonisolated)

  public private(set) nonisolated(unsafe) var validateWithJwkReceivedJws: JWS<U>?
  public private(set) nonisolated(unsafe) var validateWithJwkReceivedJwk: JWK?
  public private(set) nonisolated(unsafe) var validateWithJwkCallsCount = 0
  public nonisolated(unsafe) var validateWithJwkThrowableError: Error?

  public nonisolated func validate(_ jws: JWS<some JWT>, with jwk: JWK) throws {
    validateWithJwkCallsCount += 1
    validateWithJwkReceivedJws = jws as? JWS<U>
    validateWithJwkReceivedJwk = jwk
    if let validateWithJwkThrowableError {
      throw validateWithJwkThrowableError
    }
  }
}
#endif
