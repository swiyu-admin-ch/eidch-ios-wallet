import BITAnyCredentialFormat
import Foundation

public struct MockAnyCredentialConfigurationSupported: CredentialIssuerMetadata.AnyCredentialConfigurationSupported, Sendable {

  // MARK: Lifecycle

  init() {}

  public init(from decoder: any Decoder) throws {}

  // MARK: Public

  public var format = CredentialFormat.vcSdJwt

  public var scope: String?

  public var protectedIssuanceAuthorizationTrustStatement: ProtectedIssuanceAuthorizationTrustStatement?

  public var cryptographicBindingMethodsSupported: [CredentialIssuerMetadata.CryptographicBindingMethod]?

  public var credentialSigningAlgValuesSupported: [String]?

  public var proofTypesSupported = [CredentialIssuerMetadata.ProofType]()

  public var credentialMetadata: CredentialIssuerMetadata.CredentialMetadata?

  public var credentialRefreshDisabled = false

}
