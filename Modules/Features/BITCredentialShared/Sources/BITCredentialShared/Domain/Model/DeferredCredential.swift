import BITEntities
import BITOpenID
import Foundation

// MARK: - DeferredCredential

public struct DeferredCredential: Codable, CredentialProtocol {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    transactionId: String,
    createdAt: Date = Date(),
    progressionState: ProgressionState = .inProgress,
    endpoint: String,
    format: String,
    issuerUrl: String,
    selectedConfigurationId: String? = nil,
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [],
    pollingInterval: Int = Self.defaultPollingInterval,
    keyBindings: [KeyBinding] = [],
    rawCredentialData: RawCredentialData? = nil,
    polledAt: Date? = nil,
    authentication: CredentialAuthentication)
  {
    self.id = id
    self.transactionId = transactionId
    self.createdAt = createdAt
    self.endpoint = endpoint
    self.progressionState = progressionState
    self.pollingInterval = pollingInterval
    self.polledAt = polledAt
    self.format = format
    self.issuerUrl = issuerUrl
    self.issuerDisplays = issuerDisplays
    self.displays = displays
    self.rawCredentialData = rawCredentialData
    self.keyBindings = keyBindings
    self.selectedConfigurationId = selectedConfigurationId
    self.authentication = authentication
  }

  public init(_ entity: CredentialEntity) throws {
    guard
      let deferredCredential = entity.deferredCredential,
      let progressState = DeferredCredential.ProgressionState(rawValue: deferredCredential.progressState)
    else {
      throw CredentialError.invalidEntity
    }

    let issuerDisplays = Array(entity.issuerDisplays.map(CredentialIssuerDisplay.init))
    let displays = Array(entity.displays.map(CredentialDisplay.init))

    self.init(
      id: entity.id,
      transactionId: deferredCredential.id,
      createdAt: entity.createdAt,
      progressionState: progressState,
      endpoint: deferredCredential.endpoint,
      format: entity.format,
      issuerUrl: entity.issuerUrl,
      selectedConfigurationId: entity.selectedConfigurationId,
      issuerDisplays: issuerDisplays,
      displays: displays,
      pollingInterval: entity.deferredCredential?.pollingInterval ?? Self.defaultPollingInterval,
      keyBindings: Array(entity.deferredCredential?.keyBindings.map(KeyBinding.init) ?? []),
      rawCredentialData: entity.rawCredentialData.flatMap(RawCredentialData.init),
      polledAt: entity.deferredCredential?.polledAt,
      authentication: CredentialAuthentication(entity.authentication))
  }

  // MARK: Public

  public enum ProgressionState: String, Codable {
    case inProgress
    case invalid
  }

  public static let defaultPollingInterval = 5

  public let format: String
  public let issuerUrl: String
  public let selectedConfigurationId: String?
  public let createdAt: Date
  public let issuerDisplays: [CredentialIssuerDisplay]
  public let displays: [CredentialDisplay]

  public var pollingInterval: Int
  public var polledAt: Date?

  public let transactionId: String
  public let authentication: CredentialAuthentication
  public let endpoint: String

  public var keyBindings: [KeyBinding]
  public var rawCredentialData: RawCredentialData?
  public var progressionState: ProgressionState

  public var id: UUID
}

// MARK: Equatable

extension DeferredCredential: Equatable {
  public static func == (lhs: DeferredCredential, rhs: DeferredCredential) -> Bool {
    lhs.format == rhs.format &&
      lhs.issuerUrl == rhs.issuerUrl &&
      lhs.createdAt == rhs.createdAt &&
      lhs.issuerDisplays.allSatisfy(rhs.issuerDisplays.contains) && rhs.issuerDisplays.allSatisfy(lhs.issuerDisplays.contains) &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains) &&
      lhs.progressionState == rhs.progressionState &&
      lhs.pollingInterval == rhs.pollingInterval &&
      lhs.polledAt == rhs.polledAt &&
      lhs.authentication == rhs.authentication &&
      lhs.endpoint == rhs.endpoint &&
      lhs.transactionId == rhs.transactionId &&
      lhs.selectedConfigurationId == rhs.selectedConfigurationId
  }
}

// MARK: Hashable

extension DeferredCredential: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(format)
    hasher.combine(createdAt)
    hasher.combine(progressionState)
    hasher.combine(pollingInterval)
    hasher.combine(polledAt)
    hasher.combine(authentication)
    hasher.combine(transactionId)
    hasher.combine(selectedConfigurationId)
    hasher.combine(endpoint)
  }
}
