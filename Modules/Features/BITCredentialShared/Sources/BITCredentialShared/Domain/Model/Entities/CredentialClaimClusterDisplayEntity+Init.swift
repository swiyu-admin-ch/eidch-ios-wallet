import BITEntities
import Foundation

extension CredentialClaimClusterDisplayEntity {

  // MARK: Lifecycle

  public convenience init(display: ClusterDisplay) {
    self.init()
    id = display.id
    setValues(from: display)
  }

  // MARK: Internal

  func setValues(from display: ClusterDisplay) {
    locale = display.locale ?? .defaultLocaleIdentifier
    name = display.name
  }

}
