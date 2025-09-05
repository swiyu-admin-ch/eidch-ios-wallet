import BITEIDRequestShared
import Foundation

struct EIDRequestResponse: Decodable, Equatable {

  // MARK: Internal

  let caseId: String
  let identityNumber: String
  let lastName: String
  let firstName: String

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case caseId
    case lastName = "surname"
    case firstName = "givenNames"
    case birthdate = "dateOfBirth"
    case identityType
    case identityNumber
    case validUntil
    case hasLegalRepresentant = "legalRepresentant"
    case email
  }

  private let birthdate: Date
  private let identityType: IdentityType
  private let validUntil: Date
  private let hasLegalRepresentant: Bool
  private let email: String?

}
