#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension CredentialIssuerMetadataJWT: Mockable {
  struct Mock {
    static let sample: JWS<CredentialIssuerMetadataJWT> = createJWS(from: .Mock.sample)
    static let sampleData = Data(sample.rawPayload.utf8)
    static let sampleNoBatch: JWS<CredentialIssuerMetadataJWT> = createJWS(from: .Mock.sample.changing(\.batchCredentialIssuance, to: nil))
    static let simpleSample: JWS<CredentialIssuerMetadataJWT> = createJWS(from: .Mock.simpleSample)

    static func createJWS(from credentialIssuerMetadata: CredentialIssuerMetadata) -> JWS<CredentialIssuerMetadataJWT> {
      let jwt = CredentialIssuerMetadataJWT(subject: "subject", issuedAt: Date(), expiredAt: nil, credentialIssuerMetadata: credentialIssuerMetadata)
      return JWS(payload: jwt, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "keyIdentifier"))
    }
  }
}
#endif
