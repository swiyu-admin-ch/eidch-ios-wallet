import BITCredentialShared
import BITEntities
import Foundation


public struct EIDRequestCase: Codable, Identifiable {

  // MARK: Lifecycle

  public init(
    id: String,
    createdAt: Date = Date(),
    rawMRZ: [String],
    documentNumber: String,
    selectedDocumentType: IdentityType = .identityCard,
    lastName: String,
    firstName: String,
    state: EIDRequestState? = nil,
    files: [EIDRequestCaseFile] = [],
    deferredCredential: DeferredCredential? = nil)
  {
    self.id = id
    self.createdAt = createdAt
    self.rawMRZ = rawMRZ.joined(separator: Self.mrzSeparator)
    self.documentNumber = documentNumber
    self.selectedDocumentType = selectedDocumentType
    self.lastName = lastName
    self.firstName = firstName
    self.state = state
    self.deferredCredential = deferredCredential
  }

  public init(_ entity: EIDRequestCaseEntity) throws {
    let mrz = entity.rawMRZ
      .split(separator: Self.mrzSeparator)
      .map(String.init)

    try self.init(
      id: entity.id,
      createdAt: entity.createdAt,
      rawMRZ: mrz,
      documentNumber: entity.documentNumber,
      selectedDocumentType: IdentityType(rawValue: entity.selectedDocumentType) ?? .identityCard,
      lastName: entity.lastName,
      firstName: entity.firstName,
      state: entity.state.map(EIDRequestState.init),
      deferredCredential: entity.credential.flatMap(DeferredCredential.init))
  }

  // MARK: Public

  public let id: String
  public var state: EIDRequestState?
  public let lastName: String
  public let firstName: String
  public let createdAt: Date
  public let selectedDocumentType: IdentityType
  public var deferredCredential: DeferredCredential?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case id = "caseId"
    case rawMRZ
    case documentNumber
    case selectedDocumentType
    case lastName
    case firstName
    case createdAt
    case state
    case deferredCredential
  }

  let rawMRZ: String
  let documentNumber: String

  // MARK: Private

  private static let mrzSeparator = ";"

}

// MARK: Equatable

extension EIDRequestCase: Equatable {
  public static func == (lhs: EIDRequestCase, rhs: EIDRequestCase) -> Bool {
    lhs.id == rhs.id &&
      lhs.rawMRZ == rhs.rawMRZ &&
      lhs.lastName == rhs.lastName &&
      lhs.state == rhs.state &&
      lhs.documentNumber == rhs.documentNumber &&
      lhs.createdAt == rhs.createdAt &&
      lhs.firstName == rhs.firstName &&
      lhs.selectedDocumentType == rhs.selectedDocumentType &&
      lhs.deferredCredential == rhs.deferredCredential
  }
}
