#if DEBUG
import BITCrypto
import Foundation
@testable import BITCore
@testable import BITVault

extension FetchCredentialContext {
  enum Mock {

    // MARK: Internal

    static let sample = make(format: "some-format")
    static let sampleVcSdJwt = make(format: "vc+sd-jwt")
    static let sampleVcSdJwtBatch = make(format: "vc+sd-jwt", holderBindings: [
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256, keyAttestationJWS: "attestationJWS-1"),
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()), keyAttestationJWS: nil),
    ])
    static let vcSdJwtUnsupportedMetadataType = make(format: "vc+sd-jwt", selectedCredential: MockAnyCredentialConfigurationSupported())
    static let sampleVcSdJwtWithoutHolderBinding = make(format: "vc+sd-jwt", holderBindings: nil)
    static let sampleVcSdJwtWithoutKeyAttestation = make(format: "vc+sd-jwt", holderBindings: HolderBinding.Mock.softwareKey)
    static let sampleCredentialEncryption = make(format: "vc+sd-jwt", credentialEncryptionContext: makeCredentialEncryptionContext())
    static let sampleCredentialEncryptionNoResponseEncryption = make(format: "vc+sd-jwt", credentialEncryptionContext: makeCredentialEncryptionContext(responseKeyPair: nil))

    // MARK: Private

    // swiftlint:disable all
    private static let mockEndpointsUrl = URL(string: "http://some.endpoint")!
    private static let mockJwksUrl = URL(string: "http://some.jwks")!

    // swiftlint:enable all

    private static func make(
      format: String,
      invalid: Bool = false,
      selectedCredential: (any CredentialIssuerMetadata.AnyCredentialConfigurationSupported)? = nil,
      holderBindings: [HolderBinding]? = HolderBinding.Mock.attestedHardwareKey,
      credentialEncryptionContext: CredentialEncryptionContext? = nil)
      -> FetchCredentialContext
    {
      let credentialConfig: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported
      if let selectedCredential {
        credentialConfig = selectedCredential
      } else {
        guard let mockCredentialsSupported: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported = CredentialIssuerMetadata.Mock.sample.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value else {
          fatalError("Mock of CredentialIssuerMetadata doesn't contain valid credentialConfigurationSupported")
        }
        credentialConfig = mockCredentialsSupported
      }

      return FetchCredentialContext(
        credentialConfigurationId: "elfa-sdjwt",
        format: format,
        selectedCredential: credentialConfig,
        credentialIssuer: "credential-issuer",
        holderBindings: holderBindings,
        authorization: IssuanceAuthorization(accessToken: AccessToken.Mock.sample),
        nonce: Nonce.Mock.default,
        credentialEndpoint: mockEndpointsUrl,
        credentialEncryptionContext: credentialEncryptionContext,
        deferredCredentialEndpoint: URL(string: "mock_deferred_credential_endpoint"))
    }

    private static func makeCredentialEncryptionContext(responseKeyPair: VaultKeyPair? = VaultKeyPair.Mock.ES256) -> CredentialEncryptionContext {
      let issuerPublicKey = JWK.Mock.validSample

      return CredentialEncryptionContext(
        issuerPublicKey: issuerPublicKey,
        credentialRequestEncryptionAlgorithm: .A128GCM,
        credentialRequestEncryptionZipValue: .deflate,
        responseKeyPair: responseKeyPair,
        credentialResponseEncryptionAlgorithm: .A128GCM,
        credentialResponseEncryptionZipValue: .deflate)
    }
  }
}
#endif
