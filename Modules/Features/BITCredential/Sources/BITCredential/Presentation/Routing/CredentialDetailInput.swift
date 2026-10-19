import BITCredentialShared
import Foundation

public struct CredentialDetailInput: Hashable, Sendable {
  public let credentialId: UUID

  public init(credentialId: UUID) {
    self.credentialId = credentialId
  }

  public init(credential: any CredentialProtocol) {
    self.init(credentialId: credential.id)
  }
}
