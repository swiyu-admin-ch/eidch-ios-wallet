import BITCrypto
import BITEntities
import BITJWT
import Foundation

// MARK: - ClientAttestation

/// Client Attestation JWT
/// https://datatracker.ietf.org/doc/html/draft-ietf-oauth-attestation-based-client-auth-05
public typealias ClientAttestation = JWS<ClientAttestationJWT>

// MARK: - ClientAttestationJWT

public struct ClientAttestationJWT: JWT, Codable, Equatable {

  // MARK: Public

  public let type: String? = "oauth-client-attestation+jwt"
  public let expiredAt: Date?
  public let activatedAt: Date?
  public let subject: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case subject = "sub"
    case bindingKey = "cnf"
    case walletName = "wallet_name"
  }

  let bindingKey: BindingKey
  let walletName: String
}

extension ClientAttestation {

  // MARK: Lifecycle

  convenience init(_ entity: ClientAttestationEntity) throws {
    guard let data = entity.attestation.data(using: .utf8) else {
      throw ClientAttestationJWTError.invalidRawData
    }

    let payload = try JWSDecoder().decode(ClientAttestationJWT.self, from: data)

    self.init(payload: payload.payload, rawPayload: payload.rawPayload, rawJWS: entity.attestation, header: payload.header)
  }

  // MARK: Internal

  enum ClientAttestationJWTError: Error {
    case invalidRawData
  }
}

extension ClientAttestationJWT {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }

  public var issuedAt: Date? {
    nil
  }
}
