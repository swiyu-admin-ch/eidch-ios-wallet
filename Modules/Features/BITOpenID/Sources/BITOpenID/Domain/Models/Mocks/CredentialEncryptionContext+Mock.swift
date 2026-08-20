#if DEBUG
import BITCrypto
import Foundation
@testable import BITCore
@testable import BITVault

extension CredentialEncryptionContext {
  enum Mock {

    static let sample = CredentialEncryptionContext(
      issuerPublicKey: .Mock.validSample,
      credentialRequestEncryptionAlgorithm: .A256GCM,
      credentialRequestEncryptionZipValue: .deflate,
      responseKeyPair: .Mock.ES256,
      credentialResponseEncryptionAlgorithm: .A256GCM,
      credentialResponseEncryptionZipValue: .deflate)
  }
}
#endif
