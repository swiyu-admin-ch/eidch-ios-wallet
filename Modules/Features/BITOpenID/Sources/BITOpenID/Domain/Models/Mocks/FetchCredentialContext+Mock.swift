#if DEBUG
import Foundation
@testable import BITTestingCore
@testable import BITVault

extension FetchCredentialContext {

  struct Mock {

    // MARK: Internal

    static let sample = make(format: "some-format")
    static let sampleVcSdJwt = make(format: "vc+sd-jwt")
    static let vcSdJwtUnsupportedMetadataType = make(format: "vc+sd-jwt", selectedCredential: MockAnyCredentialConfigurationSupported())
    static let sampleVcSdJwtWithoutHolderBinding = make(format: "vc+sd-jwt", holderBindingContext: nil)
    static let sampleVcSdJwtWithoutKeyAttestation = make(format: "vc+sd-jwt", holderBindingContext: HolderBindingContext.Mock.softwareKey)

    // MARK: Private

    // swiftlint:disable all
    private static let mockEndpointsUrl = URL(string: "http://some.endpoint")!
    private static let mockJwksUrl = URL(string: "http://some.jwks")!

    // swiftlint:enable all

    private static func make(
      format: String,
      invalid: Bool = false,
      selectedCredential: (any CredentialMetadata.AnyCredentialConfigurationSupported)? = nil,
      holderBindingContext: HolderBindingContext? = .Mock.attestedHardwareKey)
      -> FetchCredentialContext
    {
      let credentialConfig: any CredentialMetadata.AnyCredentialConfigurationSupported
      if let selectedCredential {
        credentialConfig = selectedCredential
      } else {
        guard let mockCredentialsSupported: any CredentialMetadata.AnyCredentialConfigurationSupported = CredentialMetadata.Mock.sample.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value else {
          fatalError("Mock of CredentialMetadata doesn't contain valid credentialConfigurationSupported")
        }
        credentialConfig = mockCredentialsSupported
      }

      return FetchCredentialContext(
        credentialConfigurationId: "elfa-sdjwt",
        format: format,
        selectedCredential: credentialConfig,
        credentialIssuer: "credential-issuer",
        holderBindingContext: holderBindingContext,
        accessToken: AccessToken.Mock.sample,
        nonce: Nonce.Mock.default,
        credentialEndpoint: mockEndpointsUrl,
        deferredCredentialEndpoint: URL(string: "mock_deferred_credential_endpoint"))
    }
  }
}
#endif
