import BITCore
import Foundation
import RealmSwift

public class NonComplianceReasonDisplayEntity: EmbeddedObject, DisplayLocalizable {
  @Persisted public var locale: String?
  @Persisted public var value: String
}
