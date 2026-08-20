import BITCrypto
import BITJWT
import BITSdJWT
import Foundation

public typealias IdentityTrustStatementV1 = SdJWS<IdentityTrustStatementV1JWT>

// MARK: - IdentityTrustStatementV1JWT

public struct IdentityTrustStatementV1JWT: TrustStatementV1JWT, Codable, Equatable {

  // MARK: Public

  public let type: String? = VcSdJwt.legacyType

  public let vct: String
  public let subject: String?
  public let issuedAt: Date?
  public let statusList: VcSdJwtTokenStatus

  public let activatedAt: Date?
  public let expiredAt: Date?

  public let _entityNames: [String: String]?
  public let _registryIds: [RegistryId]?
  public let _isStateActor: Bool?

  public var acceptedTypes: [String]? {
    [VcSdJwt.legacyType, VcSdJwt.currentType]
  }

  public var entityNames: [String: String] {
    _entityNames ?? [:]
  }

  public var isStateActor: Bool {
    _isStateActor ?? false
  }

  public var registryIds: [RegistryId] {
    _registryIds ?? []
  }

  /// Gets the localized entity name considering the order of the given language codes
  public func getLocalizedEntityName(considering languageCodes: [String]) -> String {
    languageCodes
      .flatMap { code in
        entityNames.filter { locale, _ in
          locale.hasPrefix("\(code)")
        }.values
      }.first ?? CodingKeys._entityNames.rawValue
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vct
    case subject = "sub"
    case issuedAt = "iat"
    case statusList = "status"
    case activatedAt = "nbf"
    case expiredAt = "exp"
    case _entityNames = "entityName"
    case _registryIds = "registryIds"
    case _isStateActor = "isStateActor"
  }
}

// MARK: IdentityTrustStatementV1JWT.RegistryId

extension IdentityTrustStatementV1JWT {
  public struct RegistryId: Codable, Equatable {
    public let type: String
    public let value: String
  }
}

extension IdentityTrustStatementV1JWT {
  public var issuer: String? {
    nil
  }

  public var audience: String? {
    nil
  }
}

// MARK: Swift.Hashable

extension IdentityTrustStatementV1JWT: Swift.Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(type)
    hasher.combine(vct)
    hasher.combine(subject)
    hasher.combine(issuedAt)
    hasher.combine(activatedAt)
    hasher.combine(expiredAt)
  }
}
