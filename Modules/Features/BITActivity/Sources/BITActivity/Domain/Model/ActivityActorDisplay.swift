import BITCore
import BITEntities
import Foundation

// MARK: - ActivityActorDisplay

public struct ActivityActorDisplay: Codable, DisplayLocalizable {

  // MARK: Lifecycle

  public init(
    name: String? = nil,
    locale: UserLocale? = nil,
    image: Data? = nil)
  {
    self.name = name
    self.locale = locale
    self.image = image
  }

  public init(_ entity: ActivityActorDisplayEntity) {
    self.init(
      name: entity.name,
      locale: entity.locale,
      image: entity.image)
  }

  // MARK: Public

  public var name: String?
  public var locale: UserLocale?
  public var image: Data?
}

// MARK: Equatable

extension ActivityActorDisplay: Equatable {

}
