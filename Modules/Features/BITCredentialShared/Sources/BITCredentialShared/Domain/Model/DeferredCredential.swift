import BITEntities
import Foundation

// MARK: - DeferredCredential

public struct DeferredCredential: Codable, CredentialProtocol {

  // MARK: Lifecycle

  public init(
    transactionId: String,
    createdAt: Date = Date(),
    progressionState: ProgressionState = .invalid,
    accessToken: String,
    endpoint: String,
    format: String,
    issuerDisplays: [CredentialIssuerDisplay] = [],
    displays: [CredentialDisplay] = [],
    pollingInterval: Int = Self.defaultPollingInterval,
    keyBinding: CredentialKeyBinding? = nil,
    rawCredentialData: RawCredentialData? = nil,
    polledAt: Date? = nil)
  {
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
  }

  public init(_ entity: CredentialEntity) throws {
    guard let deferredCredential = entity.deferredCredential else {
      throw CredentialError.invalidEntity
    }

    let issuerDisplays = Array(entity.issuerDisplays.map(CredentialIssuerDisplay.init))
    let displays = Array(entity.displays.map(CredentialDisplay.init))

    self.init(
      transactionId: entity.id.uuidString,
      createdAt: entity.createdAt,
      progressionState: DeferredCredential.ProgressionState(deferredCredential.progressState),
      accessToken: deferredCredential.accessToken,
      endpoint: deferredCredential.endpoint,
      format: entity.format,
      issuerDisplays: issuerDisplays,
      displays: displays,
      pollingInterval: entity.deferredCredential?.pollingInterval ?? Self.defaultPollingInterval,
      keyBinding: entity.keyBinding.flatMap(CredentialKeyBinding.init),
      rawCredentialData: entity.rawCredentialData.flatMap(RawCredentialData.init),
      polledAt: entity.deferredCredential?.polledAt)
  }

  // MARK: Public

  public static let defaultPollingInterval = 24 * 60 * 60

  public let format: String
  public let createdAt: Date
  public var issuerDisplays: [CredentialIssuerDisplay]
  public var displays: [CredentialDisplay]

  public var id: UUID {
    UUID(uuidString: transactionId) ?? UUID()
  }

  // MARK: Internal

  let transactionId: String
  let accessToken: String
  let endpoint: String
  let progressionState: ProgressionState
  let pollingInterval: Int
  let polledAt: Date?
  let keyBinding: CredentialKeyBinding?
  let rawCredentialData: RawCredentialData?
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
      lhs.transactionId == rhs.transactionId
  }
}

// MARK: DeferredCredential.ProgressionState

extension DeferredCredential {

  public enum ProgressionState: String, Codable {
    case inProgress
    case invalid

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
