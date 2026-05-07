import BITEntities
import Foundation
import Spyable

// MARK: - ActivityActorDisplayFactoryProtocol

@Spyable
public protocol ActivityActorDisplayFactoryProtocol {
  func callAsFunction(_ entity: ActivityActorDisplayEntity) -> ActivityActorDisplay
}

// MARK: - ActivityActorDisplayFactory

struct ActivityActorDisplayFactory: ActivityActorDisplayFactoryProtocol {
  func callAsFunction(_ entity: ActivityActorDisplayEntity) -> ActivityActorDisplay {
    ActivityActorDisplay(
      name: entity.name,
      locale: entity.locale,
      image: entity.image)
  }
}
