import BITCrypto
import BITVault
import Foundation

public struct CredentialResponseEncryption: Codable, Equatable {

  // MARK: Lifecycle

  public init(keyPair: VaultKeyPair, enc: String, zip: String?) throws {
    jwk = try JWK(from: keyPair)
    self.enc = enc
    self.zip = zip
    #warning("Required by Generic Issuer, but will be removed, not OID4VCI compliant")
    alg = keyPair.algorithm.rawValue
  }

  // MARK: Public

  public let jwk: BITCrypto.JWK
  public let enc: String
  public let zip: String?
  public let alg: String?
}
