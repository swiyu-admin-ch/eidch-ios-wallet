import BITCrypto
import Foundation
import JWSETKit

// MARK: - JWSHeaderError

public enum JWSHeaderError: Error {
  case algorithmNotFound
}

// MARK: - JWSHeader

/// This class represents the header of a signed JWT (JWS) which is specified by https://www.rfc-editor.org/rfc/rfc7515.html
public final class JWSHeader: Equatable, Sendable {

  // MARK: Lifecycle

  public init(
    algorithm: JWTAlgorithm,
    type: String? = nil,
    keyIdentifier: String? = nil,
    jwk: JWK? = nil,
    profileVersion: String? = nil)
  {
    self.algorithm = algorithm
    self.type = type
    self.keyIdentifier = keyIdentifier
    self.jwk = jwk
    self.profileVersion = profileVersion
  }

  convenience init(from jws: JSONWebSignaturePlain) throws {
    guard
      let algorithm = jws.header.algorithm,
      let jwtAlgorithm = JWTAlgorithm(rawValue: algorithm.rawValue)
    else { throw JWSHeaderError.algorithmNotFound }

    try self.init(
      algorithm: jwtAlgorithm,
      type: jws.header.type?.rawValue,
      keyIdentifier: jws.header.keyId,
      jwk: jws.header.key.map { try BITCrypto.JWK(webKey: $0) },
      profileVersion: jws.profileVersion)
  }

  // MARK: Public

  /// Header algorithm value aka `alg` in a JWSHeader
  public let algorithm: JWTAlgorithm

  /// Header type value aka `typ` in a JWSHeader
  public let type: String?

  /// The key ID is a hint indicating which key was used to secure the JWS
  public let keyIdentifier: String?

  /// The key info
  public let jwk: JWK?

  /// Swiss profile trust version
  public let profileVersion: String?

  // MARK: Equatable

  public static func == (lhs: JWSHeader, rhs: JWSHeader) -> Bool {
    lhs.algorithm == rhs.algorithm &&
      lhs.type == rhs.type &&
      lhs.keyIdentifier == rhs.keyIdentifier &&
      lhs.jwk == rhs.jwk &&
      lhs.profileVersion == rhs.profileVersion
  }
}

extension BITCrypto.JWK {
  fileprivate init(webKey: some JSONWebKey) throws {
    let data = try JSONEncoder().encode(AnyJSONWebKey(webKey))
    self = try JSONDecoder().decode(BITCrypto.JWK.self, from: data)
  }
}

extension JSONWebSignaturePlain {
  fileprivate var profileVersion: String? {
    header["profile_version"]
  }
}
