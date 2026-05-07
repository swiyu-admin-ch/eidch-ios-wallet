import Foundation

// MARK: - ActivityListItem

public struct ActivityListItem: Identifiable, Codable, Equatable {

  // MARK: Public

  public let id: UUID
  public let type: ActivityType
  public let createdAt: Date
  public let actorDisplay: ActivityActorDisplay?
}
