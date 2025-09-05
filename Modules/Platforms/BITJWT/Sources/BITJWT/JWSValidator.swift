import Factory
import Foundation

// MARK: - JWSValidatorProtocol

public protocol JWSValidatorProtocol {
  func validate(_ jws: JWS<some JWTValidityPayload>, issuerDid: String, activationBuffer: TimeInterval) async throws -> Bool
}

extension JWSValidatorProtocol {
  public func validate(_ jws: JWS<some JWTValidityPayload>, issuerDid: String, activationBuffer: TimeInterval = 0) async throws -> Bool {
    try await validate(jws, issuerDid: issuerDid, activationBuffer: activationBuffer)
  }
}

// MARK: - JWSValidator

public struct JWSValidator: JWSValidatorProtocol {

  // MARK: Public

  public func validate(_ jws: JWS<some JWTValidityPayload>, issuerDid: String, activationBuffer: TimeInterval) async throws -> Bool {
    let currentDate = Container.shared.currentDate()
    if let activatedAt = jws.payload.activatedAt, activatedAt > currentDate.addingTimeInterval(activationBuffer) {
      return false
    }
    if let expiredAt = jws.payload.expiredAt, expiredAt < currentDate {
      return false
    }
    return try await jwsSignatureValidator.validate(jws, issuerDid: issuerDid)
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
}
