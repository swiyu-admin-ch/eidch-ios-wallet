import BITCrypto
import BITJWT
import BITVault
import Foundation

// MARK: - KeyAttestation

/// Key Attestation JWT
public typealias KeyAttestation = JWS<KeyAttestationJWT>

// MARK: - KeyAttestationJWT

public struct KeyAttestationJWT: JWT, Codable, Equatable {

  // MARK: Public

  public let type: String? = "key-attestation+jwt"
  public let expiredAt: Date?
  public let issuedAt: Date?

  public var activatedAt: Date? {
    issuedAt // key attestation is valid from issuance date
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuedAt = "iat"
    case expiredAt = "exp"
    case keyStorage = "key_storage"
    case attestedKeys = "attested_keys"
  }

  let keyStorage: [KeyStorageSecurityLevel]
  let attestedKeys: [JWK]
}

extension KeyAttestationJWT {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }

  public var subject: String? {
    nil
  }
}
