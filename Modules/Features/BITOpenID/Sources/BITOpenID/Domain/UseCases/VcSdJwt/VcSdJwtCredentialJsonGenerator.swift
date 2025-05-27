import BITAnyCredentialFormat
import BITSdJWT
import Foundation

// MARK: - VcSdJwtCredentialJsonGeneratorError

enum VcSdJwtCredentialJsonGeneratorError: Error {
  case invalidJsonData
}

// MARK: - VcSdJwtCredentialJsonGenerator

struct VcSdJwtCredentialJsonGenerator: AnyCredentialJsonGeneratorProtocol {

  func generate(for anyCredential: any AnyCredential) throws -> String {
    guard let vcSdJwt = anyCredential as? VcSdJwt else { throw CredentialFormatError.formatNotSupported }
    let data = try JSONSerialization.data(withJSONObject: vcSdJwt.rawPayload)
    guard let json = String(data: data, encoding: .utf8) else { throw VcSdJwtCredentialJsonGeneratorError.invalidJsonData }
    return json
  }
}
