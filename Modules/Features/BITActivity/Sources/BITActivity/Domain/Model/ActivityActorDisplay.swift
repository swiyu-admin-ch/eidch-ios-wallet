import BITCore
import Foundation

// MARK: - ActivityActorDisplay

public struct ActivityActorDisplay: Codable, Equatable, DisplayLocalizable {

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

  // MARK: Public

  public let name: String?
  public let locale: UserLocale?
  public let image: Data?
}
