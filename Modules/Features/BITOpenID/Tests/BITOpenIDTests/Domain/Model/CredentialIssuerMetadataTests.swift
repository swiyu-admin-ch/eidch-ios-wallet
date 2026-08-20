// swiftlint:disable force_unwrapping force_cast

import Foundation
import Testing
@testable import BITCore
@testable import BITOpenID
@testable import BITTestingCore

struct CredentialIssuerMetadataTests {

  // MARK: Internal

  @Test
  func decode_success_returnsMetadata() throws {
    let data = CredentialIssuerMetadata.Mock.sampleData

    let metadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)

    #expect(metadata.credentialIssuer.absoluteString == "https://example.com/issuer")
    #expect(metadata.credentialEndpoint == "https://example.com/credential")
    #expect(metadata.nonceEndpoint.absoluteString == "https://example.com/nonce")
    #expect(metadata.deferredCredentialEndpoint?.absoluteString == "https://example.com/deferred")

    #expect(metadata.credentialRequestEncryption.supportedEncryptionAlgorithms == [.A256GCM])
    #expect(metadata.credentialRequestEncryption.supportedZipValues == [.deflate])
    #expect(metadata.credentialRequestEncryption.encryptionRequired == true)
    #expect(metadata.credentialRequestEncryption.jwks.keys.count == 1)

    #expect(metadata.credentialResponseEncryption.supportedEncryptionAlgorithms == [.A256GCM])
    #expect(metadata.credentialResponseEncryption.supportedZipValues == [.deflate])
    #expect(metadata.credentialResponseEncryption.supportedAlgorithmValues == [.ECDH_ES])
    #expect(metadata.credentialResponseEncryption.encryptionRequired == false)

    #expect(metadata.batchCredentialIssuance?.batchSize == 10)
    #expect(metadata.display?.count == 2)

    let displayDe = metadata.display?.first { $0.locale == "de-CH" }
    #expect(displayDe?.name == "issuer name (de-CH)")
    #expect(displayDe?.logo?.url?.absoluteString == "data:image/png;base64,aXNzdWVyIGltYWdlIChkZS1DSCk=")

    let displayEn = metadata.display?.first { $0.locale == "en-US" }
    #expect(displayEn?.name == "issuer name (en-US)")
    #expect(displayEn?.logo?.url?.absoluteString == "data:image/png;base64,aXNzdWVyIGltYWdlIChlbi1VUyk=")

    #expect(metadata.credentialConfigurationsSupported.count == 1)

    #expect(metadata.credentialConfigurationsSupported.first?.key == "sample-credential")
    let vcSdJwt = metadata.credentialConfigurationsSupported.first?.value as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported
    #expect(vcSdJwt != nil)
  }

  @Test
  func decodeMetadataWithUnsupportedNonceEndpointThrowsError() throws {
    let payload = [CredentialIssuerMetadata.CodingKeys.nonceEndpoint.rawValue: "ftp://chasseral-r.infra.swiyu.admin.ch/issuer01/oid4vci/api/nonce"]
    let data = try CredentialIssuerMetadata.Mock.sampleData.changeJsonPayload(with: payload)

    #expect(throws: DecodingError.self) {
      try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)
    }
  }

  @Test
  func decodeUnknownMetadataFormat_ignoresUnknown() throws {
    let vcSdJwtConfig = try JSONSerialization.jsonObject(with: CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported.Mock.sampleData)
    let data = try CredentialIssuerMetadata.Mock.sampleData.changeJsonPayload(with: [CredentialIssuerMetadata.CodingKeys.credentialConfigurationsSupported.rawValue: ["unknown": "config", "vc+sd-jwt": vcSdJwtConfig]])

    let metadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)

    #expect(metadata.credentialConfigurationsSupported.count == 1)
  }

  @Test
  func decode_lowerBoundBatchSize_returnsBatchSize() throws {
    let data = try createIssuerMetadata(batchSize: 10)

    let metadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)

    #expect(metadata.batchCredentialIssuance?.batchSize == 10)
  }

  @Test
  func decode_bigBatchSize_returnsBatchSize() throws {
    let data = try createIssuerMetadata(batchSize: 100)

    let metadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)

    #expect(metadata.batchCredentialIssuance?.batchSize == 100)
  }

  @Test
  func decode_tooSmallBatchSize_throwsError() throws {
    let data = try createIssuerMetadata(batchSize: 9)

    #expect(throws: CredentialIssuerMetadataError.invalidBatchSize) {
      try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)
    }
  }

  @Test
  func decode_negativeBatchSize_throwsError() throws {
    let data = try createIssuerMetadata(batchSize: -1)

    #expect(throws: CredentialIssuerMetadataError.invalidBatchSize) {
      try JSONDecoder().decode(CredentialIssuerMetadata.self, from: data)
    }
  }

  // MARK: Private

  private func createIssuerMetadata(batchSize: Int) throws -> Data {
    let payload = [CredentialIssuerMetadata.CodingKeys.batchCredentialIssuance.rawValue: [CredentialIssuerMetadata.BatchCredentialIssuance.CodingKeys.batchSize.rawValue: batchSize]]
    return try CredentialIssuerMetadata.Mock.sampleData.changeJsonPayload(with: payload)
  }
}
