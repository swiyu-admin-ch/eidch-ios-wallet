import BITCrypto
import BITJWT
import BITVault
import Foundation

// MARK: - KeyAttestation

/// Key Attestation JWT
public typealias KeyAttestation = JWS<KeyAttestationPayload>

// MARK: - KeyAttestationPayload

public struct KeyAttestationPayload: JWTValidityPayload, Codable, Equatable {

  // MARK: Public

  public let type: String? = "key-attestation+jwt"
  public let expiredAt: Date?

  public var activatedAt: Date? {
    issuedAt // key attestation is valid from issuance date
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case keyStorage = "key_storage"
    case attestedKeys = "attested_keys"
  }

  let issuer: String
  let issuedAt: Date
  let keyStorage: [KeyStorageSecurityLevel]
  let attestedKeys: [JWK]
}
