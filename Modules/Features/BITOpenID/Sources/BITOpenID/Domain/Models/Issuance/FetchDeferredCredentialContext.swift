import BITAnyCredentialFormat
import BITCore
import Foundation
import Security

public struct FetchDeferredCredentialContext: Changeable {

  // MARK: Lifecycle

  public init(
    format: CredentialFormat,
    authorization: IssuanceAuthorization,
    deferredCredentialEndpoint: URL,
    credentialEncryptionContext: CredentialEncryptionContext)
  {
    self.format = format
    self.authorization = authorization
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
    self.credentialEncryptionContext = credentialEncryptionContext
  }

  // MARK: Public

  public var authorization: IssuanceAuthorization
  public let format: CredentialFormat
  public let deferredCredentialEndpoint: URL
  public let credentialEncryptionContext: CredentialEncryptionContext
}
