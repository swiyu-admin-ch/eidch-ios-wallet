import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - DeferredCredentialRequestBodyGeneratorProtocol

@Spyable
public protocol DeferredCredentialRequestBodyGeneratorProtocol {
  func generate(transactionId: String, credentialEncryptionContext: CredentialEncryptionContext?) throws -> DeferredCredentialRequestBody
}

// MARK: - DeferredCredentialRequestBodyGenerator

struct DeferredCredentialRequestBodyGenerator: DeferredCredentialRequestBodyGeneratorProtocol {

  // MARK: Internal

  func generate(transactionId: String, credentialEncryptionContext: CredentialEncryptionContext?) throws -> DeferredCredentialRequestBody {
    let request = try createDeferredCredentialRequest(transactionId: transactionId, encryptionContext: credentialEncryptionContext)
    guard let encryptionContext = credentialEncryptionContext else {
      return .json(request)
    }

    let data = try JSONEncoder().encode(request)
    let jwe = try jweEncrypter.encrypt(
      data: data,
      publicKey: encryptionContext.issuerPublicKey,
      encryptionAlgorithm: encryptionContext.credentialRequestEncryptionAlgorithm,
      compressionAlgorithm: encryptionContext.credentialRequestEncryptionZipValue)

    return .jwe(jwe)
  }

  // MARK: Private

  @Injected(\.jweEncrypter) private var jweEncrypter: JWEEncrypterProtocol

  private func createDeferredCredentialRequest(transactionId: String, encryptionContext: CredentialEncryptionContext?) throws -> DeferredCredentialRequest {

    var credentialResponseEncryption: CredentialResponseEncryption?
    if let encryptionContext {
      credentialResponseEncryption = try CredentialResponseEncryption(from: encryptionContext)
    }

    return DeferredCredentialRequest(
      transactionId: transactionId,
      credentialResponseEncryption: credentialResponseEncryption)
  }
}
