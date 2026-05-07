import BITEntities
import Factory
import Foundation
import Spyable

// MARK: - ActivityListItemFactoryProtocol

@Spyable
public protocol ActivityListItemFactoryProtocol {
  func callAsFunction(_ entity: CredentialActivityEntity) -> ActivityListItem
}

// MARK: - ActivityListItemFactory

struct ActivityListItemFactory: ActivityListItemFactoryProtocol {

  // MARK: Internal

  func callAsFunction(_ entity: CredentialActivityEntity) -> ActivityListItem {
    ActivityListItem(
      id: entity.id,
      type: ActivityType(rawValue: entity.type) ?? .issuance,
      createdAt: entity.createdAt,
      actorDisplay: entity.actorDisplays.findDisplayWithFallback().map(displayFactory.callAsFunction))
  }

  // MARK: Private

  @Injected(\.activityActorDisplayFactory) private var displayFactory
}
