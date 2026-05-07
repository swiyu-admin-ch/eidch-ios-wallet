import Foundation

public struct MockAnyCredentialConfigurationSupported: CredentialIssuerMetadata.AnyCredentialConfigurationSupported {

  // MARK: Lifecycle

  init() {}

  public init(from decoder: any Decoder) throws {}

  // MARK: Public

  public var format = "format"

  public var scope: String?

  public var cryptographicBindingMethodsSupported: [CredentialIssuerMetadata.CryptographicBindingMethod]?

  public var credentialSigningAlgValuesSupported: [String]?

  public var proofTypesSupported = [CredentialIssuerMetadata.ProofType]()

  public var credentialMetadata: CredentialIssuerMetadata.CredentialMetadata?

}
