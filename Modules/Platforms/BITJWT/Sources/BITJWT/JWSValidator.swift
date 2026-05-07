import Factory
import Foundation

// MARK: - JWSValidatorError

public enum JWSValidatorError: Error, Equatable {
  case notYetActivated
  case issuedAtInFuture
  case expired
  case invalidKeyIdentifier
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

    let keyIdentifierDid = try getIssuerDid(from: jws.header.keyIdentifier)
    if let issuer = jws.payload.issuer {
      guard issuer == keyIdentifierDid else { throw JWSValidatorError.invalidKeyIdentifier }
      try await jwsSignatureValidator.validate(jws, issuerDid: issuer)
    } else {
      try await jwsSignatureValidator.validate(jws, issuerDid: keyIdentifierDid)
    }
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol

  private func getIssuerDid(from keyIdentifier: String?) throws -> String {
    guard
      let keyIdentifier,
      let issuerDid = keyIdentifier.split(separator: "#").first else
    {
      throw JWSValidatorError.invalidKeyIdentifier
    }
    return String(issuerDid)
  }
}
