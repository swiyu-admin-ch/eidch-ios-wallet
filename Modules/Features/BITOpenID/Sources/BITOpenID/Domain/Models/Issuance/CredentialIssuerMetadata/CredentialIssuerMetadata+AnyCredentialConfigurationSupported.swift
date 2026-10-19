import BITAnyCredentialFormat
import Foundation

extension CredentialIssuerMetadata {

  // MARK: Public

  /// This protocol is needed in order to make the `credential_configurations_supported`property  format agnostic
  public protocol AnyCredentialConfigurationSupported: Equatable, Sendable {
    var format: CredentialFormat { get }
    var scope: String? { get }
    var protectedIssuanceAuthorizationTrustStatement: ProtectedIssuanceAuthorizationTrustStatement? { get }
    var cryptographicBindingMethodsSupported: [CryptographicBindingMethod]? { get }
    var credentialSigningAlgValuesSupported: [String]? { get }
    var proofTypesSupported: [ProofType] { get }
    var credentialMetadata: CredentialMetadata? { get }
    var credentialRefreshDisabled: Bool { get }

    init(from decoder: Decoder) throws
  }

  // MARK: Internal

  enum AnyCredentialConfigurationSupportedError: Error {
    case invalidProofType
    case invalidCryptographicBindingMethod
  }

}
