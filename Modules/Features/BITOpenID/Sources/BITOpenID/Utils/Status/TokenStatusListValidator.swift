import BITAnyCredentialFormat
import BITCrypto
import BITJWT
import BITSdJWT
import Factory
import Foundation

// MARK: - TokenStatusListValidator

/// A structure representing a validator that checks the revocation and suspension status of a credential.
/// This structure is based on the Token Status List specification.
/// https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-03.html
///
struct TokenStatusListValidator: AnyStatusCheckValidatorProtocol {

  // MARK: Internal

  func validate(_ anyStatus: any AnyStatus, issuer: String) async -> VcStatus {
    do {
      guard
        let statusList = anyStatus as? VcSdJwtTokenStatusList,
        let statusUri = URL(string: statusList.statusList.uri),
        let statusJws = try? await repository.fetchCredentialStatus(from: statusUri),
        try await isValidStatusJws(statusJws, issuer: issuer, statusListUri: statusUri.absoluteString)
      else { return .unknown }

      let statusCode = try tokenStatusListDecoder.decode(statusJws, index: statusList.statusList.index)
      return statusCode.credentialStatus
    } catch {
      return .unknown
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.tokenStatusListDecoder) private var tokenStatusListDecoder: TokenStatusListDecoderProtocol
  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol

  private func isValidStatusJws(_ jws: JWS<TokenStatusList>, issuer: String, statusListUri: String) async throws -> Bool {
    guard
      jws.payload.subject == statusListUri,
      jws.payload.issuer == issuer
    else {
      return false
    }
    guard try await jwsSignatureValidator.validate(jws, did: issuer) else {
      return false
    }
    guard let expiredAt = jws.payload.expiredAt else { return true }
    return expiredAt > Date()
  }
}

extension StatusCode {
  var credentialStatus: VcStatus {
    switch self {
    case 0: .valid
    case 1: .revoked
    case 2: .suspended
    default: .unsupported
    }
  }
}
