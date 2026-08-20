import BITAnyCredentialFormat
import BITEntities
import BITOpenID
import Foundation

// MARK: - VerifiableCredential

public struct VerifiableCredential: Codable, CredentialProtocol {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    createdAt: Date = Date(),
    refreshedAt: Date? = nil,
    progressionState: ProgressState = .unaccepted,
    bundleItems: [BundleItem] = [],
    nextPresentableBundleItemId: UUID,
    clusters: [CredentialClaimCluster] = [],
    format: CredentialFormat,
    issuerUrl: URL,
    selectedConfigurationId: String? = nil,
    issuer: String,
    batchData: BatchData? = nil,
    authentication: CredentialAuthentication,
    rawCredentialData: RawCredentialData? = nil,
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [],
    validFrom: Date? = nil,
    validUntil: Date? = nil)
  {
    self.id = id
    self.createdAt = createdAt
    self.refreshedAt = refreshedAt
    self.progressionState = progressionState
    self.bundleItems = bundleItems
    self.nextPresentableBundleItemId = nextPresentableBundleItemId
    self.issuer = issuer
    self.clusters = clusters
    self.validFrom = validFrom
    self.validUntil = validUntil
    self.format = format
    self.issuerUrl = issuerUrl
    self.selectedConfigurationId = selectedConfigurationId
    self.batchData = batchData
    self.authentication = authentication
    self.rawCredentialData = rawCredentialData
    self.issuerDisplays = issuerDisplays
    self.displays = displays
    environment = TrustEnvironment(did: issuer)
  }

  public init(_ entity: CredentialEntity) throws {
    guard
      let verifiableCredential = entity.verifiableCredential,
      let issuerUrl = URL(string: entity.issuerUrl)
    else {
      throw CredentialError.invalidEntity
    }

    self.init(
      id: entity.id,
      createdAt: entity.createdAt,
      refreshedAt: verifiableCredential.refreshedAt,
      progressionState: ProgressState(verifiableCredential.progressionState),
      bundleItems: Array(verifiableCredential.bundleItems.map(BundleItem.init)),
      nextPresentableBundleItemId: verifiableCredential.nextPresentableBundleItemId,
      clusters: Array(verifiableCredential.clusters.map(CredentialClaimCluster.init)),
      format: CredentialFormat(rawValue: entity.format) ?? .vcSdJwt,
      issuerUrl: issuerUrl,
      selectedConfigurationId: entity.selectedConfigurationId,
      issuer: verifiableCredential.issuer,
      batchData: verifiableCredential.batchData.flatMap(BatchData.init),
      authentication: CredentialAuthentication(entity.authentication),
      rawCredentialData: entity.rawCredentialData.flatMap(RawCredentialData.init),
      issuerDisplays: Array(entity.issuerDisplays.map(CredentialIssuerDisplay.init)),
      displays: Array(entity.displays.map(CredentialDisplay.init)),
      validFrom: entity.verifiableCredential?.validFrom,
      validUntil: entity.verifiableCredential?.validUntil)
  }

  // MARK: Public

  public let clusters: [CredentialClaimCluster]
  public var bundleItems: [BundleItem]
  public var nextPresentableBundleItemId: UUID

  public var validFrom: Date?
  public let validUntil: Date?

  public var format: CredentialFormat
  public var issuerUrl: URL
  public var selectedConfigurationId: String?
  public var batchData: BatchData?
  public var authentication: CredentialAuthentication

  public var issuerDisplays: [CredentialIssuerDisplay]
  public var displays: [CredentialDisplay]
  public var environment = TrustEnvironment.external

  public let id: UUID
  public let createdAt: Date
  public let refreshedAt: Date?

  public var progressionState: ProgressState
  public let rawCredentialData: RawCredentialData?

  public let issuer: String

  public var keyBindings: [KeyBinding] {
    bundleItems.compactMap(\.keyBinding)
  }

  /// The bundle item that would be presented next.
  public var presentableBundleItem: BundleItem? {
    bundleItems.first { $0.id == nextPresentableBundleItemId }
  }

  public var resolvedClusters: [CredentialClaimCluster] {
    clusters.map { cluster in
      cluster.resolvePathTemplates(using: clusters)
    }
  }

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case id
    case createdAt
    case refreshedAt
    case progressionState
    case bundleItems
    case nextPresentableBundleItemId
    case issuer
    case clusters
    case validFrom
    case validUntil
    case format
    case issuerUrl
    case selectedConfigurationId
    case batchData
    case authentication
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
      lhs.refreshedAt == rhs.refreshedAt &&
      lhs.progressionState == rhs.progressionState &&
      lhs.bundleItems == rhs.bundleItems &&
      lhs.nextPresentableBundleItemId == rhs.nextPresentableBundleItemId &&
      lhs.issuer == rhs.issuer &&
      lhs.validFrom == rhs.validFrom &&
      lhs.validUntil == rhs.validUntil &&
      lhs.batchData == rhs.batchData &&
      lhs.authentication == rhs.authentication &&
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
    hasher.combine(refreshedAt)
    hasher.combine(bundleItems)
    hasher.combine(nextPresentableBundleItemId)
    hasher.combine(issuer)
    hasher.combine(validFrom)
    hasher.combine(validUntil)
    hasher.combine(batchData)
    hasher.combine(authentication)
  }
}

extension CredentialClaimCluster {

  fileprivate func resolvePathTemplates(using clusters: [CredentialClaimCluster]) -> Self {
    var copy = self
    copy.childClusters = childClusters.map { $0.resolvePathTemplates(using: clusters) }
    copy.displays = displays.map { $0.resolvePathTemplates(using: clusters, indices: path.allIndices) }
    return copy
  }
}

extension ClusterDisplay {

  fileprivate func resolvePathTemplates(using clusters: [CredentialClaimCluster], indices: [Int]) -> Self {
    var copy = self
    copy.name = name.resolvePathTemplates(using: clusters, indices: indices)
    return copy
  }
}
