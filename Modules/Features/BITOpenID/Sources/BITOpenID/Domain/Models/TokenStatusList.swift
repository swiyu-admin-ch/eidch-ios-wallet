import BITJWT
import Foundation

// MARK: - TokenStatusList

/// This class contains all registered claims which are specified by https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-03.html#name-status-list-token
public struct TokenStatusList: JWTPayload, Codable, Equatable {

  // MARK: Lifecycle

  public init(
    issuer: String,
    subject: String,
    issuedAt: Date,
    expiredAt: Date? = nil,
    timeToLive: UInt? = nil,
    statusList: StatusList)
  {
    self.issuer = issuer
    self.subject = subject
    self.issuedAt = issuedAt
    self.expiredAt = expiredAt
    self.timeToLive = timeToLive
    self.statusList = statusList
  }

  // MARK: Public

  public let type: String? = "statuslist+jwt"

  public let issuer: String
  public let subject: String
  public let issuedAt: Date
  public let expiredAt: Date?
  public let timeToLive: UInt?
  public let statusList: StatusList

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuer = "iss"
    case subject = "sub"
    case issuedAt = "iat"
    case expiredAt = "exp"
    case timeToLive = "ttl"
    case statusList = "status_list"
  }
}

// MARK: TokenStatusList.StatusList

extension TokenStatusList {

  public struct StatusList: Codable, Equatable {
    public let bits: Int
    public let list: String
    public let aggregationUri: String? = nil

    enum CodingKeys: String, CodingKey {
      case bits
      case list = "lst"
      case aggregationUri = "aggregation_uri"
    }
  }
}
