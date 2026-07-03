import BITCredentialShared
import Foundation

public struct CredentialDetailInput: Hashable {
  public let credentialId: UUID

  public init(credentialId: UUID) {
    self.credentialId = credentialId
  }

  public init(credential: any CredentialProtocol) {
    self.init(credentialId: credential.id)
  }
}
