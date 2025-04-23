import BITEntities
import Foundation

extension EIDRequestCaseEntity {

  // MARK: Lifecycle

  convenience init(_ eIDRequestCase: EIDRequestCase) throws {
    self.init()
    id = eIDRequestCase.id
    try setValues(from: eIDRequestCase)
  }

  // MARK: Internal

  func setValues(from eIDRequestCase: EIDRequestCase) throws {
    rawMRZ = eIDRequestCase.rawMRZ

    if let eIDRequestCaseState = eIDRequestCase.state {
      state = EIDRequestStateEntity(eIDRequestCaseState)
    }

    documentNumber = eIDRequestCase.documentNumber
    firstName = eIDRequestCase.firstName
    lastName = eIDRequestCase.lastName
    createdAt = eIDRequestCase.createdAt
  }
}
