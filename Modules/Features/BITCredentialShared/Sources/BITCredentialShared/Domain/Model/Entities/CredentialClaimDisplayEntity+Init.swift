import BITEntities
import Foundation

extension CredentialClaimDisplayEntity {

  // MARK: Lifecycle

  public convenience init(display: CredentialClaimDisplay) {
    self.init()
    id = display.id
    setValues(from: display)
  }

  // MARK: Internal

  func setValues(from display: CredentialClaimDisplay) {
    locale = display.locale ?? .defaultLocaleIdentifier
    name = display.name
    value = display.value
  }

}
