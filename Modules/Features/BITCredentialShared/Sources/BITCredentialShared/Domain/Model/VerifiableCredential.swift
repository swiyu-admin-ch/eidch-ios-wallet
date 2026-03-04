import BITAnyCredentialFormat
import BITEntities
import BITOpenID
import Factory
import Foundation

// MARK: - VerifiableCredential

public struct VerifiableCredential: Codable, CredentialProtocol {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    createdAt: Date = Date(),
    progressionState: ProgressState = .unaccepted,
    payload: CredentialPayload,
    status: CredentialStatus = .unknown,
    clusters: [CredentialClaimCluster] = [],
    format: String,
    issuerUrl: String,
    selectedConfigurationId: String? = nil,
    issuer: String,
    keyBinding: CredentialKeyBinding? = nil,
    rawCredentialData: RawCredentialData? = nil,
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [],
    validFrom: Date? = nil,
    validUntil: Date? = nil)
  {
    self.id = id
    self.createdAt = createdAt
    self.progressionState = progressionState
    self.payload = payload
    self.issuer = issuer
    self.status = status
    self.clusters = clusters
    self.validFrom = validFrom
    self.validUntil = validUntil
    self.format = format
    self.issuerUrl = issuerUrl
    self.selectedConfigurationId = selectedConfigurationId
    self.keyBinding = keyBinding
    self.rawCredentialData = rawCredentialData
    self.issuerDisplays = issuerDisplays
    self.displays = displays

    environment = TrustEnvironment(did: issuer)
  }

  public init(_ entity: CredentialEntity) throws {
    guard let verifiableCredential = entity.verifiableCredential else {
      throw CredentialError.invalidEntity
    }

    self.init(
      id: entity.id,
      createdAt: entity.createdAt,
      progressionState: ProgressState(verifiableCredential.progressionState),
      payload: verifiableCredential.payload,
      status: CredentialStatus(verifiableCredential.status),
      clusters: Array(verifiableCredential.clusters.map(CredentialClaimCluster.init)),
      format: entity.format,
      issuerUrl: entity.issuerUrl,
      selectedConfigurationId: entity.selectedConfigurationId,
      issuer: verifiableCredential.issuer,
      keyBinding: entity.keyBinding.flatMap(CredentialKeyBinding.init),
      rawCredentialData: entity.rawCredentialData.flatMap(RawCredentialData.init),
      issuerDisplays: Array(entity.issuerDisplays.map(CredentialIssuerDisplay.init)),
      displays: Array(entity.displays.map(CredentialDisplay.init)),
      validFrom: entity.verifiableCredential?.validFrom,
      validUntil: entity.verifiableCredential?.validUntil)
  }

  // MARK: Public

  public let clusters: [CredentialClaimCluster]
  public let payload: CredentialPayload
  public var status: CredentialStatus

  public var validFrom: Date?
  public let validUntil: Date?

  public var format: String
  public var issuerUrl: String
  public var selectedConfigurationId: String?

  public var keyBinding: CredentialKeyBinding? = nil
  public var issuerDisplays: [CredentialIssuerDisplay]
  public var displays: [CredentialDisplay]
  public var environment = TrustEnvironment.external

  public let id: UUID
  public let createdAt: Date

  public var progressionState: ProgressState
  public let rawCredentialData: RawCredentialData?

  public let issuer: String

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case id
    case createdAt
    case progressionState
    case payload
    case issuer
    case status
    case clusters
    case validFrom
    case validUntil
    case format
    case issuerUrl
    case selectedConfigurationId
    case keyBinding
    case rawCredentialData
    case issuerDisplays
    case displays
  }

}

// MARK: Equatable

extension VerifiableCredential: Equatable {

  public static func == (lhs: VerifiableCredential, rhs: VerifiableCredential) -> Bool {
    lhs.id == rhs.id &&
      lhs.createdAt == rhs.createdAt &&
      lhs.progressionState == rhs.progressionState &&
      lhs.payload == rhs.payload &&
      lhs.issuer == rhs.issuer &&
      lhs.status == rhs.status &&
      lhs.validFrom == rhs.validFrom &&
      lhs.validUntil == rhs.validUntil &&
      lhs.keyBinding == rhs.keyBinding &&
      lhs.rawCredentialData == rhs.rawCredentialData &&
      lhs.format == rhs.format &&
      lhs.issuerUrl == rhs.issuerUrl &&
      lhs.selectedConfigurationId == rhs.selectedConfigurationId &&
      lhs.clusters.allSatisfy(rhs.clusters.contains) && rhs.clusters.allSatisfy(lhs.clusters.contains) &&
      lhs.issuerDisplays.allSatisfy(rhs.issuerDisplays.contains) && rhs.issuerDisplays.allSatisfy(lhs.issuerDisplays.contains) &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains)
  }
}

// MARK: VerifiableCredential.ProgressState

extension VerifiableCredential {

  public enum ProgressState: String, Codable {
    case accepted
    case unaccepted

    // MARK: Lifecycle

    init(_ state: VerifiableCredentialEntity.ProgressionState) {
      switch state {
      case .accepted:
        self = .accepted
      case .unaccepted:
        self = .unaccepted
      }
    }
  }
}

// MARK: Hashable

extension VerifiableCredential: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(createdAt)
    hasher.combine(payload)
    hasher.combine(issuer)
    hasher.combine(status)
    hasher.combine(validFrom)
    hasher.combine(validUntil)
  }
}
