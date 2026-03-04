import BITCrypto
import Factory
import Foundation

// MARK: - CredentialRequestBodyGenerator

struct CredentialRequestBodyGenerator: CredentialRequestBodyGeneratorProtocol {

  // MARK: Internal

  func generate(for context: FetchCredentialContext, proofs: CredentialRequest.Proofs?) throws -> CredentialRequestBody {
    let request = try createCredentialRequest(for: context, proofs: proofs)
    guard let encryptionContext = context.credentialEncryptionContext else {
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

  private func createCredentialRequest(for context: FetchCredentialContext, proofs: CredentialRequest.Proofs?) throws -> CredentialRequest {

    var credentialResponseEncryption: CredentialResponseEncryption?
    if let encryptionContext = context.credentialEncryptionContext {
      credentialResponseEncryption = try CredentialResponseEncryption(from: encryptionContext)
    }

    return CredentialRequest(
      credentialConfigurationId: context.credentialConfigurationId,
      proofs: proofs,
      credentialResponseEncryption: credentialResponseEncryption)
  }
}
