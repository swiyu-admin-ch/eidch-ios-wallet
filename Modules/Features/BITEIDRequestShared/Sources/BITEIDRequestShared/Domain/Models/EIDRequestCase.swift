import BITCredentialShared
import BITEntities
import Foundation


public struct EIDRequestCase: Decodable, Identifiable {

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
    walletPairingId: String? = nil,
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
    self.walletPairingId = walletPairingId
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
      walletPairingId: entity.walletPairingId,
      deferredCredential: entity.deferredCredential.map(DeferredCredential.init))
  }

  // MARK: Public

  public let id: String
  public var state: EIDRequestState?
  public let lastName: String
  public let firstName: String
  public let createdAt: Date
  public let selectedDocumentType: IdentityType

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
    case walletPairingId
    case deferredCredential
  }

  let rawMRZ: String
  let documentNumber: String
  let walletPairingId: String?
  let deferredCredential: DeferredCredential?

  // MARK: Private

  private static let mrzSeparator = ";"

}

extension EIDRequestCaseEntity {

  // MARK: Lifecycle

  public convenience init(_ requestCase: EIDRequestCase) {
    self.init()
    id = requestCase.id
    setValues(from: requestCase)
  }

  // MARK: Public

  public func setValues(from requestCase: EIDRequestCase) {
    rawMRZ = requestCase.rawMRZ

    if let requestCaseState = requestCase.state {
      state = EIDRequestStateEntity(requestCaseState)
    }

    documentNumber = requestCase.documentNumber
    selectedDocumentType = requestCase.selectedDocumentType.rawValue
    firstName = requestCase.firstName
    lastName = requestCase.lastName
    createdAt = requestCase.createdAt
    walletPairingId = requestCase.walletPairingId

    if let deferredCredential = requestCase.deferredCredential {
      self.deferredCredential = DeferredCredentialEntity(deferredCredential)
    }
  }
}


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
      lhs.walletPairingId == rhs.walletPairingId &&
      lhs.deferredCredential == rhs.deferredCredential
  }
}
