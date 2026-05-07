import Foundation

extension CredentialIssuerMetadata {

  /// Helper struct to decode the final dictionary of `[String: any AnyCredentialConfigurationSupported]`
  struct CredentialConfigurationSupportedWrapper: Decodable {
    let anyCredentialConfigurationSupported: (any AnyCredentialConfigurationSupported)?

    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()

      do {
        anyCredentialConfigurationSupported = try container.decode(VcSdJwtCredentialConfigurationSupported.self)
      } catch AnyCredentialConfigurationSupportedError.invalidProofType {
        throw AnyCredentialConfigurationSupportedError.invalidProofType
      } catch AnyCredentialConfigurationSupportedError.invalidCryptographicBindingMethod {
        throw AnyCredentialConfigurationSupportedError.invalidCryptographicBindingMethod
      } catch {
        // Unknown credential configuration type
        anyCredentialConfigurationSupported = nil
      }
    }
  }

}
