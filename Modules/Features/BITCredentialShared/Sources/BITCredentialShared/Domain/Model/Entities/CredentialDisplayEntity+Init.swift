import BITEntities
import Foundation

extension CredentialDisplayEntity {

  // MARK: Lifecycle

  public convenience init(display: CredentialDisplay) {
    self.init()
    id = display.id
    setValues(from: display)
  }

  // MARK: Internal

  func setValues(from display: CredentialDisplay) {
    locale = display.locale
    name = display.name
    logoAltText = display.logoAltText
    logoData = display.logoBase64
    summary = display.summary
    backgroundColor = display.backgroundColor
    theme = display.theme
  }

}
