// swiftlint:disable force_unwrapping
#if DEBUG
import BITCrypto
import Foundation
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITVault

extension FetchCredentialContext {
  enum Mock {

    // MARK: Internal

    static let sample = make()
    static let sampleWithoutHolderBinding = make(holderBindings: nil)
    static let sampleBatch = make(holderBindings: [
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256, keyAttestationJWS: "attestationJWS-1"),
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()), keyAttestationJWS: nil),
    ])
    static let sampleWithSoftwareHolderBinding = make(holderBindings: HolderBinding.Mock.softwareKey)

    // MARK: Private

    private static let mockEndpointsUrl = URL(string: "http://some.endpoint")!
    private static let issuerUrl = URL(string: "https://issuer.domain.ch")!

    // swiftlint:enable all

    private static func make(
      format: CredentialFormat = .vcSdJwt,
      holderBindings: [HolderBinding]? = HolderBinding.Mock.attestedHardwareKey)
      -> FetchCredentialContext
    {
      FetchCredentialContext(
        credentialConfigurationId: "configuration_id",
        format: format,
        selectedCredential: CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported(format: CredentialFormat.vcSdJwt, vct: "vct"),
        credentialIssuer: issuerUrl,
        holderBindings: holderBindings,
        authorization: IssuanceAuthorization(accessToken: AccessToken.Mock.sample),
        nonce: Nonce.Mock.default,
        credentialEndpoint: mockEndpointsUrl,
        credentialEncryptionContext: .Mock.sample,
        deferredCredentialEndpoint: URL(string: "mock_deferred_credential_endpoint"))
    }
  }
}
#endif
