import BITCredentialShared
import BITEntities
import Foundation


public struct EIDRequestCase: Codable, Identifiable, Equatable {

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
    deferredCredential: DeferredCredential? = nil,
    filesSubmitted: Bool = false,
    pushId: String? = nil)
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
    self.filesSubmitted = filesSubmitted
    self.pushId = pushId
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
      deferredCredential: entity.credential.flatMap(DeferredCredential.init),
      filesSubmitted: entity.filesSubmitted,
      pushId: entity.pushId)
  }

  // MARK: Public

  public let id: String
  public var state: EIDRequestState?
  public let lastName: String
  public let firstName: String
  public let createdAt: Date
  public let selectedDocumentType: IdentityType
  public var deferredCredential: DeferredCredential?
  public var filesSubmitted: Bool
  public var pushId: String?

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
    case filesSubmitted
    case pushId
  }

  let rawMRZ: String
  let documentNumber: String

  // MARK: Private

  private static let mrzSeparator = ";"

}

// MARK: Hashable

extension EIDRequestCase: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(rawMRZ)
    hasher.combine(lastName)
    hasher.combine(firstName)
    hasher.combine(documentNumber)
    hasher.combine(createdAt)
    hasher.combine(selectedDocumentType)
    hasher.combine(state)
    hasher.combine(filesSubmitted)
    hasher.combine(pushId)
  }
}
