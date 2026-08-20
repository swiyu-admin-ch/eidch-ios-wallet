// swiftlint:disable force_try
#if DEBUG
import Foundation
@testable import BITCore
@testable import BITCrypto

// MARK: CredentialIssuerMetadata.CredentialResponseEncryption.Mock

extension CredentialIssuerMetadata.CredentialResponseEncryption: Mockable {

  struct Mock {
    static let sample = CredentialIssuerMetadata.CredentialResponseEncryption(
      supportedAlgorithmValues: [.ECDH_ES],
      supportedEncryptionAlgorithms: [.A256GCM],
      supportedZipValues: [.deflate],
      encryptionRequired: false)

    static func build(
      supportedAlgorithmValues: [KeyManagementAlgorithm] = [.ECDH_ES],
      supportedEncryptionAlgorithms: [EncryptionAlgorithm] = [.A256GCM],
      supportedZipValues: [CompressionAlgorithm] = [.deflate],
      encryptionRequired: Bool = false)
      -> CredentialIssuerMetadata.CredentialResponseEncryption
    {
      CredentialIssuerMetadata.CredentialResponseEncryption(
        supportedAlgorithmValues: supportedAlgorithmValues,
        supportedEncryptionAlgorithms: supportedEncryptionAlgorithms,
        supportedZipValues: supportedZipValues,
        encryptionRequired: encryptionRequired)
    }
  }
}

extension CredentialResponseEncryption: Mockable {

  struct Mock {
    static let sample = try! CredentialResponseEncryption(
      keyPair: .Mock.ES256,
      enc: EncryptionAlgorithm.A256GCM.rawValue,
      zip: CompressionAlgorithm.deflate.rawValue)
  }

}
#endif
