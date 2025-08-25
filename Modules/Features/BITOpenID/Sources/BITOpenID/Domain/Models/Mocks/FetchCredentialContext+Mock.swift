#if DEBUG
import Foundation
@testable import BITTestingCore
@testable import BITVault

extension FetchCredentialContext {

  struct Mock {

    // MARK: Internal

    static let sample = make(format: "some-format")
    static let sampleVcSdJwt = make(format: "vc+sd-jwt")
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
      holderBindingContext: HolderBindingContext? = .Mock.attestedHardwareKey)
      -> FetchCredentialContext
    {
      guard let mockCredentialsSupported: any CredentialMetadata.AnyCredentialConfigurationSupported = CredentialMetadata.Mock.sample.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value else {
        fatalError("Mock of CredentialMetadata doesn't contain valid credentialConfigurationSupported")
      }

      return FetchCredentialContext(
        format: format,
        selectedCredential: mockCredentialsSupported,
        credentialOffers: ["credential-offer"],
        credentialIssuer: "credential-issuer",
        holderBindingContext: holderBindingContext,
        accessToken: AccessToken(cNonce: "cNonce", accessToken: "access-token"),
        credentialEndpoint: mockEndpointsUrl)
    }
  }
}
#endif
