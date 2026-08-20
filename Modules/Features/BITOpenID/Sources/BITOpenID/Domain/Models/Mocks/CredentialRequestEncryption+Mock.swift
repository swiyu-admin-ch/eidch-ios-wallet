#if DEBUG
import Foundation
@testable import BITCore
@testable import BITCrypto

// MARK: CredentialIssuerMetadata.CredentialRequestEncryption.Mock

extension CredentialIssuerMetadata.CredentialRequestEncryption: Mockable {

  struct Mock {
    static let sample = CredentialIssuerMetadata.CredentialRequestEncryption(
      jwks: CredentialIssuerMetadata.CredentialRequestEncryption.JWKs(keys: [.Mock.validSample]),
      supportedEncryptionAlgorithms: [.A256GCM],
      supportedZipValues: [.deflate],
      encryptionRequired: false)

    static func build(
      jwks: [JWK] = [JWK.Mock.build()],
      supportedEncryptionAlgorithms: [EncryptionAlgorithm] = [.A256GCM],
      supportedZipValues: [CompressionAlgorithm] = [.deflate],
      encryptionRequired: Bool = false)
      -> CredentialIssuerMetadata.CredentialRequestEncryption
    {
      CredentialIssuerMetadata.CredentialRequestEncryption(
        jwks: CredentialIssuerMetadata.CredentialRequestEncryption.JWKs(keys: jwks),
        supportedEncryptionAlgorithms: supportedEncryptionAlgorithms,
        supportedZipValues: supportedZipValues,
        encryptionRequired: encryptionRequired)
    }
  }

}
#endif
