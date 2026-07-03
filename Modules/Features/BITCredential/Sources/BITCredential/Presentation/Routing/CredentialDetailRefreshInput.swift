import BITCredentialShared

// MARK: - CredentialDetailRefreshInput

public struct CredentialDetailRefreshInput: Hashable {

  public init(credential: CredentialProtocol) {
    self.credential = credential
  }

  let credential: CredentialProtocol

  public func hash(into hasher: inout Hasher) {
    hasher.combine(credential.id)
  }

  public static func == (lhs: CredentialDetailRefreshInput, rhs: CredentialDetailRefreshInput) -> Bool {
    lhs.credential.id == rhs.credential.id
  }
}
