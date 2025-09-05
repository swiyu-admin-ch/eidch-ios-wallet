#if DEBUG
import Foundation
import XCTest

public class JWSValidatorMock<U: Codable & Equatable>: JWSValidatorProtocol {

  public var validateIssuerDidActivationBufferReturnValue = false

  public var validateIssuerDidActivationBufferReceivedJws: JWS<U>?
  public var validateIssuerDidActivationBufferReceivedDid: String?
  public var validateIssuerDidActivationBufferReceivedActivationBuffer: TimeInterval?
  public var validateIssuerDidActivationBufferCallsCount = 0

  public var validateIssuerDidActivationBufferThrowableError: Error?

  public func validate(_ jws: some JWS<some Codable & Equatable>, issuerDid: String, activationBuffer: TimeInterval) async throws -> Bool {
    validateIssuerDidActivationBufferCallsCount += 1
    validateIssuerDidActivationBufferReceivedJws = jws as? JWS<U>
    validateIssuerDidActivationBufferReceivedDid = issuerDid
    validateIssuerDidActivationBufferReceivedActivationBuffer = activationBuffer
    if let throwingError = validateIssuerDidActivationBufferThrowableError {
      throw throwingError
    }
    return validateIssuerDidActivationBufferReturnValue
  }

}
#endif
