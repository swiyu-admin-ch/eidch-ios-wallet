import BITCrypto
import BITJsonCanonicalizer
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
    requestBody: Data?,
    additionalHeaderParameters: [String: Any]) throws
    -> DPoP
}

extension DPoPGeneratorProtocol {

  public func generate(
    method: String,
    url: URL,
    keyPair: VaultKeyPair,
    nonce: String? = nil,
    accessToken: String? = nil,
    requestBody: Data? = nil,
    additionalHeaderParameters: [String: Any] = [:]) throws
    -> DPoP
  {
    try generate(
      method: method,
      url: url,
      keyPair: keyPair,
      nonce: nonce,
      accessToken: accessToken,
      requestBody: requestBody,
      additionalHeaderParameters: additionalHeaderParameters)
  }
}

// MARK: - DPoPGeneratorError

enum DPoPGeneratorError: Error {
  case invalidTargetURI
}

// MARK: - DPoPGenerator

struct DPoPGenerator: DPoPGeneratorProtocol {

  // MARK: Internal

  func generate(method: String, url: URL, keyPair: VaultKeyPair, nonce: String?, accessToken: String?, requestBody: Data?, additionalHeaderParameters: [String: Any]) throws -> DPoP {
    var requestBodyHash: String?

    if let requestBody {
      requestBodyHash = sha256Hasher.hash(requestBody).base64URLEncodedString()
    }

    let jwt = try DPoPJWT(
      httpMethod: method.uppercased(),
      httpTargetURI: normalizeTargetURI(url),
      nonce: nonce,
      accessTokenHash: accessToken.flatMap(createAccessTokenHash),
      requestBody: requestBodyHash)

    return try jwsEncoder.encode(jwt, keyPair: keyPair, additionalHeaderParameters: additionalHeaderParameters)
  }

  // MARK: Private

  @Injected(\.sha256Hasher) private var sha256Hasher: Hashable
  @Injected(\.jwsEncoder) private var jwsEncoder: JWSEncoderProtocol
  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol

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
    return sha256Hasher.hash(accessTokenData).base64URLEncodedString()
  }
}
