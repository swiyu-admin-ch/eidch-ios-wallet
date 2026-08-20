#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// swiftlint:disable force_try

extension CredentialIssuerMetadataWrapper: Mockable {

  struct Mock {
    static var sample = CredentialIssuerMetadataWrapper(credentialConfigurationId: "sample-credential", credentialIssuerMetadata: .Mock.sample)
    static var simpleSample = CredentialIssuerMetadataWrapper(credentialConfigurationId: "sample-credential", credentialIssuerMetadata: .Mock.simpleSample)
  }
}

extension CredentialIssuerMetadataWrapper {
  fileprivate init(credentialConfigurationId: String, credentialIssuerMetadata: CredentialIssuerMetadata) {
    let jwt = CredentialIssuerMetadataJWT(subject: "subject", issuedAt: Date(), expiredAt: nil, credentialIssuerMetadata: credentialIssuerMetadata)
    let jws = JWS(payload: jwt, rawPayload: "rawPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: JWTAlgorithm.ES256))
    try! self.init(credentialConfigurationId: credentialConfigurationId, metadataJws: jws)
  }
}

#endif
