import Foundation

extension CredentialMetadata {

  // MARK: Public

  /// This protocol is needed in order to make the `credential_configurations_supported`property  format agnostic
  public protocol AnyCredentialConfigurationSupported: Equatable {
    var format: String { get }
    var scope: String? { get }
    var cryptographicBindingMethodsSupported: [CryptographicBindingMethod]? { get }
    var credentialSigningAlgValuesSupported: [String]? { get }
    var display: [CredentialSupportedDisplay]? { get }
    var proofTypesSupported: [ProofType] { get }
    var orderClaims: [String]? { get }
    var claims: [Claim] { get }

    init(from decoder: Decoder) throws
  }

  // MARK: Internal

  enum AnyCredentialConfigurationSupportedError: Error {
    case invalidProofType
    case invalidCryptographicBindingMethod
  }

}
