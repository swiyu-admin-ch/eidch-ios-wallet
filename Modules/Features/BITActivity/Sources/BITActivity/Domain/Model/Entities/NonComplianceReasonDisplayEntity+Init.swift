import BITEntities
import Foundation

extension NonComplianceReasonDisplayEntity {

  public convenience init(_ display: NonComplianceReasonDisplay) {
    self.init()
    locale = display.locale
    value = display.value
  }
}
