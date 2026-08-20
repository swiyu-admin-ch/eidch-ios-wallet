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
        let status = anyStatus as? VcSdJwtTokenStatus,
        let statusUri = URL(string: status.statusList.uri),
        try isTrustedStatusListUri(statusUri, issuer: issuer),
        let statusJws = try? await repository.fetchCredentialStatus(from: statusUri),
        try await isValidStatusJws(statusJws, issuer: issuer, statusListUri: status.statusList.uri)
      else { return .unknown }

      let statusCode = try tokenStatusListDecoder.decode(statusJws, index: status.statusList.index)
      return statusCode.credentialStatus
    } catch {
      return .unknown
    }
  }

  // MARK: Private

  @Injected(\.openIDRepository) private var repository: OpenIDRepositoryProtocol
  @Injected(\.tokenStatusListDecoder) private var tokenStatusListDecoder: TokenStatusListDecoderProtocol
  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
  @Injected(\.statusRegistryMapping) private var statusRegistryMapping: [String: String]

  private func isTrustedStatusListUri(_ url: URL, issuer: String) throws -> Bool {
    guard
      let statusListHost = url.host(),
      let issuerBaseRegistry = try didResolverHelper.getURL(from: issuer).host(),
      let trustedStatusListHost = statusRegistryMapping[issuerBaseRegistry]
    else {
      return false
    }
    return trustedStatusListHost == statusListHost
  }

  private func isValidStatusJws(_ jws: JWS<TokenStatusList>, issuer: String, statusListUri: String) async throws -> Bool {
    let did = try didResolverHelper.getDid(from: jws.header.keyIdentifier)
    guard
      jws.payload.subject == statusListUri,
      did == issuer
    else {
      return false
    }
    try await jwsValidator.validate(jws)
    return true
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
