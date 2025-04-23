import BITAnyCredentialFormat
import BITSdJWT

// MARK: - VcSdJwtCredentialJsonGenerator

struct VcSdJwtCredentialJsonGenerator: AnyCredentialJsonGeneratorProtocol {

  func generate(for anyCredential: any AnyCredential) throws -> String {
    guard let vcSdJwt = anyCredential as? VcSdJwt else { throw CredentialFormatError.formatNotSupported }
    return vcSdJwt.rawPayload
  }
}
