import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - VersionEnforcementSignatureValidatorProtocol

@Spyable
protocol VersionEnforcementSignatureValidatorProtocol: Sendable {
  func validate(_ payload: Data, detachedJWS: String) async throws
}

// MARK: - VersionEnforcementSignatureValidatorError

enum VersionEnforcementSignatureValidatorError: Error {
  case unsupportedAlgorithm
  case untrustedSigner
}

// MARK: - VersionEnforcementSignatureValidator

struct VersionEnforcementSignatureValidator: VersionEnforcementSignatureValidatorProtocol {

  // MARK: Internal

  func validate(_ payload: Data, detachedJWS rawDetachedJWS: String) async throws {
    let detachedJWS = try DetachedJWS(rawJWS: rawDetachedJWS)

    guard supportedAlgorithms.contains(detachedJWS.header.algorithm) else {
      throw VersionEnforcementSignatureValidatorError.unsupportedAlgorithm
    }

    let signerDid = try didResolverHelper.getDid(from: detachedJWS.header.keyIdentifier)

    guard trustedDids.contains(signerDid) else {
      throw VersionEnforcementSignatureValidatorError.untrustedSigner
    }

    try await signatureValidator.validate(detachedJWS, payload: payload)
  }

  // MARK: Private

  @Injected(\.versionEnforcementTrustedDids) private var trustedDids: [String]
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
  @Injected(\.jwsSignatureValidator) private var signatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.supportedSignatureValidationAlgorithms) private var supportedAlgorithms: [JWTAlgorithm]
}
