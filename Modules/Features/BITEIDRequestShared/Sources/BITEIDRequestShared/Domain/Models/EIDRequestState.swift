import BITEntities
import Foundation


enum EIDRequestStateError: Error {
  case invalidState
}


public struct EIDRequestState: Codable {

  // MARK: Lifecycle

  public init(id: UUID = UUID(), status: EIDRequestStatus, lastPolledAt: Date = Date()) {
    self.id = id
    state = status.state
    self.lastPolledAt = lastPolledAt
    onlineSessionStartOpenAt = status.queueInformation?.onlineSessionStartOpenAt
    onlineSessionStartTimeoutAt = status.onlineSessionStartCloseAt
    legalRepresentantConsent = LegalRepresentantConsent(status.legalRepresentant)
  }

  public init(
    id: UUID = UUID(),
    state: EIDRequestStatus.State,
    legalRepresentantConsent: LegalRepresentantConsent,
    lastPolledAt: Date = Date(),
    onlineSessionStartOpenAt: Date? = nil,
    onlineSessionStartTimeoutAt: Date? = nil)
  {
    self.id = id
    self.state = state
    self.lastPolledAt = lastPolledAt
    self.onlineSessionStartOpenAt = onlineSessionStartOpenAt
    self.onlineSessionStartTimeoutAt = onlineSessionStartTimeoutAt
    self.legalRepresentantConsent = legalRepresentantConsent
  }

  public init(_ entity: EIDRequestStateEntity) {
    let state = EIDRequestStatus.State(entity.state)

    self.init(
      id: entity.id,
      state: state,
      legalRepresentantConsent: LegalRepresentantConsent(entity.legalRepresentantConsent),
      lastPolledAt: entity.lastPolledAt,
      onlineSessionStartOpenAt: entity.onlineSessionStartOpenAt,
      onlineSessionStartTimeoutAt: entity.onlineSessionStartTimeoutAt)
  }

  public init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let rawState = try container.decode(String.self, forKey: .state)

    guard let state = EIDRequestStatus.State(rawValue: rawState) else {
      throw EIDRequestStateError.invalidState
    }

    id = try container.decode(UUID.self, forKey: .id)
    self.state = state
    lastPolledAt = try container.decode(Date.self, forKey: .lastPolledAt)
    onlineSessionStartOpenAt = try container.decodeIfPresent(Date.self, forKey: .onlineSessionStartOpenAt)
    onlineSessionStartTimeoutAt = try container.decodeIfPresent(Date.self, forKey: .onlineSessionStartTimeoutAt)
    legalRepresentantConsent = try container.decode(LegalRepresentantConsent.self, forKey: .legalRepresentantConsent)
  }

  // MARK: Public

  public let state: EIDRequestStatus.State
  public let onlineSessionStartTimeoutAt: Date?
  public let onlineSessionStartOpenAt: Date?
  public let legalRepresentantConsent: LegalRepresentantConsent

  // MARK: Internal

  enum CodingKeys: CodingKey {
    case id
    case state
    case lastPolledAt
    case onlineSessionStartOpenAt
    case onlineSessionStartTimeoutAt
    case legalRepresentantConsent
  }

  let id: UUID
  let lastPolledAt: Date
}

// MARK: Equatable

extension EIDRequestState: Equatable {
  public static func == (lhs: EIDRequestState, rhs: EIDRequestState) -> Bool {
    lhs.id == rhs.id &&
      lhs.state == rhs.state &&
      lhs.lastPolledAt == rhs.lastPolledAt &&
      lhs.onlineSessionStartOpenAt == rhs.onlineSessionStartOpenAt &&
      lhs.onlineSessionStartTimeoutAt == rhs.onlineSessionStartTimeoutAt &&
      lhs.legalRepresentantConsent == rhs.legalRepresentantConsent
  }
}
