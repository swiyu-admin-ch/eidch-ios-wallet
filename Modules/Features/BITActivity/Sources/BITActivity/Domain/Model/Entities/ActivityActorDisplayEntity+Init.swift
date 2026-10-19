import BITEntities
import Foundation

extension ActivityActorDisplayEntity {

  public convenience init(_ display: ActivityActorDisplay) {
    self.init()
    locale = display.locale ?? .defaultLocaleIdentifier
    name = display.name
    imageHash = ImageEntity.contentHash(of: display.image)
  }
}
