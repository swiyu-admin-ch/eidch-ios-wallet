import BITCredentialShared

public struct CredentialDetailInput: Hashable {
  public let credential: any CredentialProtocol

  public init(credential: any CredentialProtocol) {
    self.credential = credential
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.credential.id == rhs.credential.id
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(credential.id)
  }
}
