import BITCore
import BITJWT
import BITSdJWT
import Foundation

public typealias IdentityTrustStatement = JWS<IdentityTrustStatementJWT>

// MARK: - IdentityTrustStatementJWT

public struct IdentityTrustStatementJWT: TrustStatementJWT, Equatable, Changeable {

  public let subject: String?
  public let jti: UUID
  public let issuedAt: Date?
  public let expiredAt: Date?
  public let status: VcSdJwtTokenStatus?
  public var entityNames: LocalizedDisplay<String>
  public let isStateActor: Bool
  public let registryIds: [RegistryId]?

  public var type: String? {
    "swiyu-identity-trust-statement+jwt"
  }

  /// Gets the localized entity name considering the order of the given language codes
  public func getLocalizedEntityName(considering languageCodes: [String]) -> String {
    entityNames.getPreferredDisplay(considering: languageCodes) ?? CodingKeys.entityName.rawValue
  }
}

// MARK: Codable

extension IdentityTrustStatementJWT: Codable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    subject = try container.decode(String.self, forKey: .subject)
    jti = try container.decode(UUID.self, forKey: .jti)
    issuedAt = try container.decode(Date.self, forKey: .issuedAt)
    expiredAt = try container.decode(Date.self, forKey: .expiredAt)
    status = try container.decode(VcSdJwtTokenStatus.self, forKey: .status)
    isStateActor = try container.decode(Bool.self, forKey: .isStateActor)
    registryIds = try container.decodeIfPresent([RegistryId].self, forKey: .registryIds)

    let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
    entityNames = try LocalizedDisplay<String>(from: dynamicContainer, withBaseKey: CodingKeys.entityName.rawValue) ?? LocalizedDisplay(values: [:])
  }

  // MARK: Public

  public func encode(to encoder: Encoder) throws {
    abort() // will be implemented if we actually need it
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case jti
    case issuedAt = "iat"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case status
    case entityName = "entity_name"
    case isStateActor = "is_state_actor"
    case registryIds = "registry_ids"
  }

}

// MARK: IdentityTrustStatementJWT.RegistryId

extension IdentityTrustStatementJWT {
  public struct RegistryId: Codable, Equatable {
    public let type: String
    public let value: String
  }
}

extension IdentityTrustStatementJWT {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }

  public var activatedAt: Date? {
    nil
  }
}
