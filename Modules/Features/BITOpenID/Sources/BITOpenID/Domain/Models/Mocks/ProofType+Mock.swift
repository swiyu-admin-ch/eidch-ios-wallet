#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITVault

// MARK: AccessToken.Mock

extension CredentialIssuerMetadata.ProofType: Mockable {
  struct Mock {
    static let jwtSoftware256 = createJwt()
    static let jwtHardwareHigh256 = createJwt(keyStorageLevels: [.iso18045High])

    static func createJwt(supportedAlgorithms: [JWTAlgorithm] = [.ES256], keyStorageLevels: [KeyStorageSecurityLevel]? = nil) -> CredentialIssuerMetadata.ProofType {
      var requirements: CredentialIssuerMetadata.KeyAttestationRequirements? = nil
      if let keyStorageLevels {
        requirements = CredentialIssuerMetadata.KeyAttestationRequirements(keyStorage: keyStorageLevels)
      }
      let type = CredentialIssuerMetadata.JwtProofType(supportedAlgorithms: supportedAlgorithms, keyAttestationRequirements: requirements)
      return CredentialIssuerMetadata.ProofType.jwt(type)
    }
  }
}
#endif
