import Foundation

public struct MockAnyCredentialConfigurationSupported: CredentialMetadata.AnyCredentialConfigurationSupported {

  // MARK: Lifecycle

  init() {}

  public init(from decoder: any Decoder) throws {}

  // MARK: Public

  public var format = "format"

  public var scope: String?

  public var cryptographicBindingMethodsSupported: [CredentialMetadata.CryptographicBindingMethod]?

  public var credentialSigningAlgValuesSupported: [String]?

  public var display: [CredentialMetadata.CredentialSupportedDisplay]?

  public var proofTypesSupported = [CredentialMetadata.ProofType]()

  public var orderClaims: [String]?

  public var claims = [CredentialMetadata.Claim]()

}
