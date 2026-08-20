#if DEBUG
import Foundation
@testable import BITCore

extension NonComplianceReasonDisplayEntity: Mockable {
  public struct Mock {
    public static func create(locale: UserLocale? = nil, value: String = "value", createParent: Bool = true) throws -> NonComplianceReasonDisplayEntity {
      let entity = NonComplianceReasonDisplayEntity()
      entity.locale = locale
      entity.value = value

      if createParent {
        _ = try CredentialActivityEntity.Mock.create(nonComplianceReasonDisplays: [entity])
      }
      return entity
    }
  }
}
#endif
