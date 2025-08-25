import BITAnyCredentialFormat
import BITCore
import BITCrypto
import BITEntities
import BITVault
import Factory
import Foundation

// MARK: - CredentialError

public enum CredentialError: Error {
  case selectedCredentialNotFound
  case invalidDisplay
  case invalidPayload
}

// MARK: - Credential

public struct Credential: Identifiable, Codable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    status: CredentialStatus = .unknown,
    keyBinding: CredentialKeyBinding? = nil,
    payload: CredentialPayload,
    rawCredentialData: RawCredentialData? = nil,
    format: String,
    issuer: String,
    validFrom: Date? = nil,
    validUntil: Date? = nil,
    createdAt: Date = Date(),
    updatedAt: Date? = nil,
    clusters: [CredentialClaimCluster] = [],
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [])
  {
    self.id = id
    self.status = status
    self.keyBinding = keyBinding
    self.payload = payload
    self.rawCredentialData = rawCredentialData
    self.format = format
    self.issuer = issuer
    self.validFrom = validFrom
    self.validUntil = validUntil
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.clusters = clusters
    self.issuerDisplays = issuerDisplays
    self.displays = displays

    environment = .none
    if let regex = try? Regex(demoCredentialPattern), !issuer.matches(of: regex).isEmpty {
      environment = .demo
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    try self.init(
      id: container.decode(UUID.self, forKey: .id),
      status: container.decode(CredentialStatus.self, forKey: .status),
      keyBinding: container.decodeIfPresent(CredentialKeyBinding.self, forKey: .keyBinding),
      payload: container.decode(Data.self, forKey: .payload),
      rawCredentialData: container.decodeIfPresent(RawCredentialData.self, forKey: .rawCredentialData),
      format: container.decode(String.self, forKey: .format),
      issuer: container.decode(String.self, forKey: .issuer),
      validFrom: container.decodeIfPresent(Date.self, forKey: .validFrom),
      validUntil: container.decodeIfPresent(Date.self, forKey: .validUntil),
      createdAt: container.decode(Date.self, forKey: .createdAt),
      updatedAt: container.decodeIfPresent(Date.self, forKey: .updatedAt),
      clusters: container.decode([CredentialClaimCluster].self, forKey: .clusters),
      issuerDisplays: container.decode([CredentialIssuerDisplay].self, forKey: .issuerDisplays),
      displays: container.decode([CredentialDisplay].self, forKey: .displays))
  }

  public init(_ entity: CredentialEntity) {
    let clusters = Array(entity.clusters.map(CredentialClaimCluster.init))
    let issuerDisplays = Array(entity.issuerDisplays.map(CredentialIssuerDisplay.init))
    let displays = Array(entity.displays.map(CredentialDisplay.init))

    self.init(
      id: entity.id,
      status: CredentialStatus(rawValue: entity.status) ?? .unknown,
      keyBinding: entity.keyBinding.flatMap(CredentialKeyBinding.init),
      payload: entity.payload,
      rawCredentialData: entity.rawCredentialData.flatMap(RawCredentialData.init),
      format: entity.format,
      issuer: entity.issuer,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      clusters: clusters,
      issuerDisplays: issuerDisplays,
      displays: displays)
  }

  // MARK: Public

  public var id = UUID()
  public var status = CredentialStatus.unknown
  public var keyBinding: CredentialKeyBinding? = nil
  public var payload: CredentialPayload
  public var rawCredentialData: RawCredentialData? = nil
  public var format: String
  public var issuer: String

  public var validFrom: Date? = nil
  public var validUntil: Date? = nil
  public var createdAt = Date()
  public var updatedAt: Date? = nil

  public var clusters: [CredentialClaimCluster] = []
  public var issuerDisplays: [CredentialIssuerDisplay] = []
  public var displays: [CredentialDisplay] = []

  public var environment: CredentialEnvironment? = .none

  // MARK: Private

  private enum CodingKeys: CodingKey {
    case id
    case status
    case keyBinding
    case payload
    case rawCredentialData
    case format
    case issuer
    case validFrom
    case validUntil
    case createdAt
    case updatedAt
    case clusters
    case issuerDisplays
    case displays
  }

  @Injected(\.demoCredentialPattern) private var demoCredentialPattern: String
}

// MARK: Equatable

extension Credential: Equatable {

  public static func == (lhs: Credential, rhs: Credential) -> Bool {
    lhs.id == rhs.id &&
      lhs.status == rhs.status &&
      lhs.keyBinding == rhs.keyBinding &&
      lhs.payload == rhs.payload &&
      lhs.rawCredentialData == rhs.rawCredentialData &&
      lhs.format == rhs.format &&
      lhs.issuer == rhs.issuer &&
      lhs.validFrom == rhs.validFrom &&
      lhs.validUntil == rhs.validUntil &&
      lhs.createdAt == rhs.createdAt &&
      lhs.updatedAt == rhs.updatedAt &&
      lhs.clusters.allSatisfy(rhs.clusters.contains) && rhs.clusters.allSatisfy(lhs.clusters.contains) &&
      lhs.issuerDisplays.allSatisfy(rhs.issuerDisplays.contains) && rhs.issuerDisplays.allSatisfy(lhs.issuerDisplays.contains) &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains)
  }
}
