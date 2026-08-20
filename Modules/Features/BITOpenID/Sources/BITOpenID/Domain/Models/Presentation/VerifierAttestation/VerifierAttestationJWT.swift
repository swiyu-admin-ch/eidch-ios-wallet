import BITCrypto
import BITJWT
import Foundation

// MARK: - VerifierAttestationJWS

public typealias VerifierAttestationJWS = JWS<VerifierAttestationJWT>

// MARK: - VerifierAttestationJWT

/// Verifier Attestation JWT carried in the `jwt` header parameter of an OpenID4VP request that uses
/// the `verifier_attestation` Client Identifier Prefix. Its `typ` is `verifier-attestation+jwt`.
/// https://openid.net/specs/openid-4-verifiable-presentations-1_0.html#name-verifier-attestation-jwt
public struct VerifierAttestationJWT: JWT, Codable, Equatable {

  // MARK: Public

  public static let expectedType = "verifier-attestation+jwt"

  public let type: String? = VerifierAttestationJWT.expectedType
  public let issuer: String?
  public let subject: String?
  public let audience: String? = nil
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let activatedAt: Date?

  // MARK: Internal

  struct Confirmation: Codable, Equatable {
    let jwk: JWK
  }

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case activatedAt = "nbf"
    case cnf
    case redirectUris = "redirect_uris"
  }

  let cnf: Confirmation
  let redirectUris: [String]?

}
