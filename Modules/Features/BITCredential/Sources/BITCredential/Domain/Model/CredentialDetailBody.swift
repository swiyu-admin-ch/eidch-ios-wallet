import BITCore
import BITCredentialShared
import BITL10n
import BITOpenID
import Foundation

// MARK: - CredentialDetailBody

public struct CredentialDetailBody: Equatable {

  // MARK: Lifecycle

  public init(display: Self.Display, claims: [Self.Claim], status: CredentialStatus) {
    self.display = display
    self.claims = claims
    self.status = status
  }

  public init(from originalCredential: Credential) {
    let credential = originalCredential
    var claims: [Self.Claim] = []
    for claim in credential.claims {
      let displayName = claim.preferredDisplay?.name ?? claim.key
      let valueType = ValueType(rawValue: claim.valueType)

      claims.append(Self.Claim(id: claim.id, key: displayName, value: claim.value, type: valueType))
    }

    let issuerDisplayName = credential.preferredDisplay?.name ?? L10n.tkGlobalNotAssigned
    self.init(display: Display(id: credential.id, name: issuerDisplayName), claims: claims, status: credential.status)
  }

  // MARK: Public

  public var display: Self.Display
  public var claims: [Self.Claim]
  public var status: CredentialStatus

}

// MARK: CredentialDetailBody.Claim

extension CredentialDetailBody {
  public struct Claim: Identifiable, Equatable {
    public var id: UUID
    public var key: String
    public var value: String
    public var type: ValueType?

    public init(id: UUID, key: String, value: String, type: ValueType? = nil) {
      self.id = id
      self.key = key
      self.value = value
      self.type = type
    }
  }
}

extension CredentialDetailBody.Claim {

  public var imageData: Data? {
    guard let type else {
      return nil
    }

    return type.isImage ? Data(base64Encoded: value) : nil
  }
}

// MARK: - CredentialDetailBody.Display

extension CredentialDetailBody {
  public struct Display: Equatable {
    public var id: UUID
    public var name: String
  }
}
