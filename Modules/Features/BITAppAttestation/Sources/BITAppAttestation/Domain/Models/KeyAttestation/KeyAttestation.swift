import BITCrypto
import BITJWT
import Foundation

// MARK: - KeyAttestation

/// Key Attestation JWT
public typealias KeyAttestation = JWS<KeyAttestationPayload>

// MARK: - KeyAttestationPayload

public struct KeyAttestationPayload: JWTPayload, Codable, Equatable {

  // MARK: Public

  public let type: String? = "key-attestation+jwt"

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case keyStorage = "key_storage"
    case attestedKeys = "attested_keys"
  }

  let expiredAt: Date
  let issuer: String
  let issuedAt: Date
  let keyStorage: [KeyAttestationKeyStorage]
  let attestedKeys: [JWK]
}
