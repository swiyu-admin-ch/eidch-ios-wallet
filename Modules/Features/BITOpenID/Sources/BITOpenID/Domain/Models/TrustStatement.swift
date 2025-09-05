import BITCrypto
import BITJWT
import BITSdJWT
import Foundation

public typealias TrustStatement = SdJWS<TrustStatementPayload>

// MARK: - TrustStatementPayload

public struct TrustStatementPayload: JWTValidityPayload, Codable, Equatable {

  // MARK: Public

  public let type: String? = "vc+sd-jwt"

  public let vct: String
  public let issuer: String
  public let subject: String?
  public let issuedAt: Date
  public let statusList: VcSdJwtTokenStatusList

  public let activatedAt: Date?
  public let expiredAt: Date?

  public let _entityNames: [String: String]?
  public let _registryIds: [RegistryId]?
  public let _isStateActor: Bool?

  public var entityNames: [String: String] {
    _entityNames ?? [:]
  }

  public var isStateActor: Bool {
    _isStateActor ?? false
  }

  public var registryIds: [RegistryId] {
    _registryIds ?? []
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case vct
    case issuer = "iss"
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

// MARK: TrustStatementPayload.RegistryId

extension TrustStatementPayload {
  public struct RegistryId: Codable, Equatable {
    public let type: String
    public let value: String
  }
}

extension TrustStatement {
  /// Gets the localized entity name considering the order of the given language codes
  public func getLocalizedEntityName(considering languageCodes: [String]) -> String {
    languageCodes
      .lazy
      .flatMap { code in
        self.resolvedPayload.entityNames.filter { locale, _ in
          locale.hasPrefix("\(code)")
        }.values
      }.first ?? TrustStatementPayload.CodingKeys._entityNames.rawValue
  }
}
