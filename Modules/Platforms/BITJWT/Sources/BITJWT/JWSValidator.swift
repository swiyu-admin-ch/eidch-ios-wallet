import Factory
import Foundation

// MARK: - JWSValidatorError

public enum JWSValidatorError: Error, Equatable {
  case notYetActivated
  case issuedAtInFuture
  case expired
}

// MARK: - JWSValidatorProtocol

public protocol JWSValidatorProtocol {
  func validate(_ jws: JWS<some JWT>, activationBuffer: TimeInterval) async throws
}

extension JWSValidatorProtocol {
  public func validate(_ jws: JWS<some JWT>, activationBuffer: TimeInterval = 0) async throws {
    try await validate(jws, activationBuffer: activationBuffer)
  }
}

// MARK: - JWSValidator

public struct JWSValidator: JWSValidatorProtocol {

  // MARK: Public

  public func validate(_ jws: JWS<some JWT>, activationBuffer: TimeInterval) async throws {
    let currentDate = Container.shared.currentDate()
    if let activatedAt = jws.payload.activatedAt, activatedAt > currentDate.addingTimeInterval(activationBuffer) {
      throw JWSValidatorError.notYetActivated
    }
    if let issuedAt = jws.payload.issuedAt, issuedAt >= currentDate.addingTimeInterval(activationBuffer) {
      throw JWSValidatorError.issuedAtInFuture
    }
    if jws.payload.isExpired {
      throw JWSValidatorError.expired
    }

    try await jwsSignatureValidator.validate(jws)
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
}
