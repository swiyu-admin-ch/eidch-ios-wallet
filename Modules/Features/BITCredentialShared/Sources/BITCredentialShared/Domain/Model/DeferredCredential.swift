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
    accessToken: String,
    endpoint: String,
    format: String,
    selectedConfigurationId: String? = nil,
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [],
    pollingInterval: Int = Self.defaultPollingInterval,
    keyBinding: CredentialKeyBinding? = nil,
    rawCredentialData: RawCredentialData? = nil,
    polledAt: Date? = nil)
  {
    self.id = id
    self.transactionId = transactionId
    self.accessToken = accessToken
    self.createdAt = createdAt
    self.endpoint = endpoint
    self.progressionState = progressionState
    self.pollingInterval = pollingInterval
    self.polledAt = polledAt
    self.format = format
    self.issuerDisplays = issuerDisplays
    self.displays = displays
    self.rawCredentialData = rawCredentialData
    self.keyBinding = keyBinding
    self.selectedConfigurationId = selectedConfigurationId
  }

  public init(_ entity: CredentialEntity) throws {
    guard let deferredCredential = entity.deferredCredential else {
      throw CredentialError.invalidEntity
    }

    let issuerDisplays = Array(entity.issuerDisplays.map(CredentialIssuerDisplay.init))
    let displays = Array(entity.displays.map(CredentialDisplay.init))

    self.init(
      id: entity.id,
      transactionId: deferredCredential.id,
      createdAt: entity.createdAt,
      progressionState: DeferredCredential.ProgressionState(deferredCredential.progressState),
      accessToken: deferredCredential.accessToken,
      endpoint: deferredCredential.endpoint,
      format: entity.format,
      selectedConfigurationId: entity.selectedConfigurationId,
      issuerDisplays: issuerDisplays,
      displays: displays,
      pollingInterval: entity.deferredCredential?.pollingInterval ?? Self.defaultPollingInterval,
      keyBinding: entity.keyBinding.flatMap(CredentialKeyBinding.init),
      rawCredentialData: entity.rawCredentialData.flatMap(RawCredentialData.init),
      polledAt: entity.deferredCredential?.polledAt)
  }

  public init(_ deferredCredentialRequest: DeferredCredentialRequest) {
    self.init(
      transactionId: deferredCredentialRequest.transactionId,
      accessToken: deferredCredentialRequest.accessToken,
      endpoint: deferredCredentialRequest.endpoint,
      format: deferredCredentialRequest.format)
  }

  // MARK: Public

  public static let defaultPollingInterval = 5

  public let format: String
  public let selectedConfigurationId: String?
  public let createdAt: Date
  public let issuerDisplays: [CredentialIssuerDisplay]
  public let displays: [CredentialDisplay]

  public var pollingInterval: Int
  public var polledAt: Date?

  public let transactionId: String
  public let accessToken: String
  public let endpoint: String

  public var keyBinding: CredentialKeyBinding?
  public var rawCredentialData: RawCredentialData?

  public let progressionState: ProgressionState

  public var id: UUID

}

// MARK: Equatable

extension DeferredCredential: Equatable {

  public static func == (lhs: DeferredCredential, rhs: DeferredCredential) -> Bool {
    lhs.format == rhs.format &&
      lhs.createdAt == rhs.createdAt &&
      lhs.issuerDisplays.allSatisfy(rhs.issuerDisplays.contains) && rhs.issuerDisplays.allSatisfy(lhs.issuerDisplays.contains) &&
      lhs.displays.allSatisfy(rhs.displays.contains) && rhs.displays.allSatisfy(lhs.displays.contains) &&
      lhs.progressionState == rhs.progressionState &&
      lhs.pollingInterval == rhs.pollingInterval &&
      lhs.polledAt == rhs.polledAt &&
      lhs.accessToken == rhs.accessToken &&
      lhs.endpoint == rhs.endpoint &&
      lhs.transactionId == rhs.transactionId &&
      lhs.selectedConfigurationId == rhs.selectedConfigurationId
  }
}

// MARK: DeferredCredential.ProgressionState

extension DeferredCredential {

  public enum ProgressionState: String, Codable {
    case inProgress
    case invalid

    // MARK: Lifecycle

    init(_ state: DeferredCredentialEntity.ProgressionState) {
      switch state {
      case .inProgress:
        self = .inProgress
      case .invalid:
        self = .invalid
      }
    }
  }
}
