import BITCrypto
import BITJWT
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - DPoPGeneratorProtocol

@Spyable
public protocol DPoPGeneratorProtocol {
  func generate(
    method: String,
    url: URL,
    keyPair: VaultKeyPair,
    nonce: String?,
    accessToken: String?,
    keyAttestationJWS: String?) throws
    -> String
}

// MARK: - DPoPGeneratorError

enum DPoPGeneratorError: Error {
  case invalidTargetURI
  case invalidEncoding
}

// MARK: - DPoPGenerator

struct DPoPGenerator: DPoPGeneratorProtocol {

  // MARK: Internal

  func generate(
    method: String,
    url: URL,
    keyPair: VaultKeyPair,
    nonce: String?,
    accessToken: String?,
    keyAttestationJWS: String?) throws
    -> String
  {
    let jwt = try DPoPJWT(
      jwtIdentifier: UUID().uuidString,
      httpMethod: method.uppercased(),
      httpTargetURI: normalizeTargetURI(url),
      nonce: nonce,
      accessTokenHash: accessToken.flatMap(createAccessTokenHash),
      issuedAt: issuedAt())

    var additionalHeaderParameters: [String: Any] = ["profile_version": "swiss-profile-issuance:1.0.0"]
    if let keyAttestationJWS {
      additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue] = keyAttestationJWS
    }

    let data = try jwsEncoder.encode(jwt, using: keyPair, additionalHeaderParameters: additionalHeaderParameters)

    guard let proof = String(data: data, encoding: .utf8) else {
      throw DPoPGeneratorError.invalidEncoding
    }

    return proof
  }

  // MARK: Private

  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable

  private func issuedAt() -> Date {
    let timestamp = floor(Date().timeIntervalSince1970)
    return Date(timeIntervalSince1970: timestamp)
  }

  private func normalizeTargetURI(_ url: URL) throws -> String {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      throw DPoPGeneratorError.invalidTargetURI
    }

    components.query = nil
    components.fragment = nil

    guard let normalizedURL = components.url else {
      throw DPoPGeneratorError.invalidTargetURI
    }

    return normalizedURL.absoluteString
  }

  private func createAccessTokenHash(_ accessToken: String) -> String {
    let accessTokenData = Data(accessToken.utf8)

    #warning("Remove padded base64url ath workaround once the issuer accepts unpadded RFC 9449 values.")
    // return sha256Hasher.hash(accessTokenData).base64URLEncodedString()
    return base64URLEncodedStringWithPadding(sha256Hasher.hash(accessTokenData))
  }

  private func base64URLEncodedStringWithPadding(_ data: Data) -> String {
    data.base64EncodedString()
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
  }
}
