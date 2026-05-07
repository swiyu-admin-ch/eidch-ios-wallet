// swiftlint:disable force_unwrapping force_cast
import BITCore
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

final class CredentialIssuerMetadataTests: XCTestCase {

  func testDecodeMetadata() throws {
    let credentialIssuerMetadata = CredentialIssuerMetadata.Mock.sample

    XCTAssertFalse(credentialIssuerMetadata.credentialConfigurationsSupported.isEmpty)
    XCTAssertFalse(credentialIssuerMetadata.display?.isEmpty == true)

    let credentialSupported = try XCTUnwrap(credentialIssuerMetadata.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value)

    XCTAssertNotNil(credentialSupported.cryptographicBindingMethodsSupported)
    XCTAssertNotNil(credentialSupported.credentialMetadata?.display)
    XCTAssertNotNil(credentialSupported.credentialSigningAlgValuesSupported)
    XCTAssertNotNil(credentialSupported.proofTypesSupported)
    XCTAssertFalse(try XCTUnwrap(credentialSupported.cryptographicBindingMethodsSupported?.isEmpty))
    XCTAssertFalse(try XCTUnwrap(credentialSupported.credentialMetadata?.display?.isEmpty))
    XCTAssertFalse(try XCTUnwrap(credentialSupported.credentialSigningAlgValuesSupported?.isEmpty))
    XCTAssertEqual(credentialSupported.proofTypesSupported.count, 1)
    if case .jwt(let type) = credentialSupported.proofTypesSupported.first {
      XCTAssertEqual(type.supportedAlgorithms.count, 2)
    }

    XCTAssertFalse(try XCTUnwrap(credentialSupported.credentialMetadata?.claims?.isEmpty))
    XCTAssertEqual(credentialIssuerMetadata.credentialIssuer, "https://issuer.domain.ch")
    XCTAssertEqual(credentialIssuerMetadata.credentialEndpoint, "https://issuer.domain.ch/credential")
    XCTAssertEqual(credentialIssuerMetadata.credentialConfigurationsSupported.count, 3)
    XCTAssertNil(credentialIssuerMetadata.nonceEndpoint)
    XCTAssertNil(credentialIssuerMetadata.deferredCredentialEndpoint)

    let responseEncryption = try XCTUnwrap(credentialIssuerMetadata.credentialResponseEncryption)
    XCTAssertFalse(responseEncryption.encryptionRequired)
    XCTAssertEqual(responseEncryption.supportedAlgorithmValues.map(\.rawValue), ["ECDH-ES"])
    XCTAssertEqual(responseEncryption.supportedEncryptionAlgorithms.map(\.rawValue), ["A128GCM"])
    XCTAssertNil(responseEncryption.supportedZipValues)

    let credentialSupportedVcSdJwt = try XCTUnwrap(credentialSupported as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported)
    XCTAssertEqual(credentialSupportedVcSdJwt.vct, "elfa-sdjwt")

    let metadataDisplay = try XCTUnwrap(credentialSupportedVcSdJwt.credentialMetadata?.display)
    XCTAssertEqual(metadataDisplay.count, 2)
    let germanMetadataDisplay = try XCTUnwrap(metadataDisplay.first(where: { $0.locale == "de-CH" }))
    XCTAssertEqual(germanMetadataDisplay.description, "Kategorie B")
    XCTAssertEqual(germanMetadataDisplay.backgroundColor, "#ff69b4")
    XCTAssertEqual(germanMetadataDisplay.logo?.url?.scheme, "data")

    let metadataClaims = try XCTUnwrap(credentialSupportedVcSdJwt.credentialMetadata?.claims)
    XCTAssertEqual(metadataClaims.count, 18)

    let idClaim = try XCTUnwrap(metadataClaims.first(where: { $0.path.compactMap { $0 } == [.string("id")] }))
    XCTAssertEqual(idClaim.mandatory, true)
    XCTAssertEqual(idClaim.display?.count, 4)
    XCTAssertEqual(idClaim.display?.first(where: { $0.locale == "en-US" })?.name, "Holder binding key")

    let credentialNumberClaim = try XCTUnwrap(metadataClaims.first(where: { $0.path.compactMap { $0 } == [.string("credentialNumber")] }))
    XCTAssertEqual(credentialNumberClaim.mandatory, true)
    XCTAssertEqual(credentialNumberClaim.display?.first(where: { $0.locale == "de-CH" })?.name, "Credentialnummer")
  }

  func testDecodeMetadata_WithoutProofTypes_ReturnsMetadataWithoutProofTypes() throws {
    let credentialIssuerMetadata = CredentialIssuerMetadata.Mock.sampleWithoutProofTypes
    let credentialSupported = try XCTUnwrap(credentialIssuerMetadata.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value)

    XCTAssertTrue(credentialSupported.proofTypesSupported.isEmpty)
  }

  func testDecodeMetadata_WithVctUrl_ReturnsMetadataWithVctUrl() throws {
    let credentialIssuerMetadata = CredentialIssuerMetadata.Mock.vctUrl
    let credentialSupported = try XCTUnwrap(credentialIssuerMetadata.credentialConfigurationsSupported.first?.value as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported)

    XCTAssertEqual(credentialSupported.vct, "https://vct.example.com")
    XCTAssertEqual(credentialSupported.vctIntegrity, "vctIntegrity")
  }

  func testDecodeMetadata_WithVctMetadataUri_ReturnsMetadataWithVctMetadataUri() throws {
    let credentialIssuerMetadata = CredentialIssuerMetadata.Mock.vctMetadataUri
    let credentialSupported = try XCTUnwrap(credentialIssuerMetadata.credentialConfigurationsSupported.first?.value as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported)

    XCTAssertEqual(credentialSupported.vct, "vct")
    XCTAssertNil(credentialSupported.vctIntegrity)
    XCTAssertEqual(credentialSupported.vctMetadataUri, "https://vct-metadata.example.com")
    XCTAssertEqual(credentialSupported.vctMetadataUriIntegrity, "vctMetadataUriIntegrity")
  }

  func testDecodeMetadata_WithUnsupportedProofTypeAlgorithm_ThrowsError() throws {
    let credentialIssuerMetadataData = CredentialIssuerMetadata.Mock.sampleUnsupportedProofTypeAlgorithmData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialIssuerMetadata.self, from: credentialIssuerMetadataData)) { error in
      XCTAssertEqual(error as? CredentialIssuerMetadata.AnyCredentialConfigurationSupportedError, .invalidProofType)
    }
  }

  func testDecodeMetadata_WithUnsupportedCryptographicBindingMethod_ThrowsError() throws {
    let credentialIssuerMetadataData = CredentialIssuerMetadata.Mock.sampleUnsupportedCryptographicBindingMethodData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialIssuerMetadata.self, from: credentialIssuerMetadataData)) { error in
      XCTAssertEqual(error as? CredentialIssuerMetadata.AnyCredentialConfigurationSupportedError, .invalidCryptographicBindingMethod)
    }
  }

  func testDecodeMetadata_WithUnsupportedNonceEndpoint_ThrowsError() throws {
    let credentialIssuerMetadataData = CredentialIssuerMetadata.Mock.chasseralIssuerUnsupportedNonceData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialIssuerMetadata.self, from: credentialIssuerMetadataData)) { error in
      XCTAssertNotNil(error as? DecodingError)
    }
  }

  func testDecodeUnknownMetadataFormat() throws {
    let credentialIssuerMetadataData = CredentialIssuerMetadata.Mock.sampleWithUnknownFormatData
    let credentialIssuerMetadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: credentialIssuerMetadataData)
    XCTAssertFalse(credentialIssuerMetadata.credentialConfigurationsSupported.isEmpty)

    guard let jsonObject = try JSONSerialization.jsonObject(with: credentialIssuerMetadataData, options: []) as? [String: Any] else {
      XCTFail("can not decode Data in to [String: Any]")
      return
    }
    guard let credentialConfigurations = jsonObject["credential_configurations_supported"] as? [String: Any] else {
      XCTFail("can not parse credential_configurations_supported")
      return
    }
    XCTAssertTrue(credentialIssuerMetadata.credentialConfigurationsSupported.count == credentialConfigurations.count - 1, "There should be an unknown format that has been ignored")
  }

  func testDecodeMetadata_WithLowerBoundBatchSize_ReturnsBatchSize() throws {
    let metadataData = CredentialIssuerMetadata.Mock.sampleWithBatchSizeLowerBoundData
    let metadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: metadataData)

    XCTAssertEqual(metadata.batchCredentialIssuance?.batchSize, 10)
  }

  func testDecodeMetadata_WithUpperBoundBatchSize_ReturnsBatchSize() throws {
    let metadataData = CredentialIssuerMetadata.Mock.sampleWithBatchSizeUpperBoundData
    let metadata = try JSONDecoder().decode(CredentialIssuerMetadata.self, from: metadataData)

    XCTAssertEqual(metadata.batchCredentialIssuance?.batchSize, 100)
  }

  func testDecodeMetadata_WithTooSmallBatchSize_throwsError() throws {
    let metadataData = CredentialIssuerMetadata.Mock.sampleWithTooSmallBatchSizeData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialIssuerMetadata.self, from: metadataData)) { error in
      XCTAssertEqual(error as? CredentialIssuerMetadataError, .invalidBatchSize)
    }
  }

  func testDecodeMetadata_WithTooBigBatchSize_throwsError() throws {
    let metadataData = CredentialIssuerMetadata.Mock.sampleWithTooBigBatchSizeData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialIssuerMetadata.self, from: metadataData)) { error in
      XCTAssertEqual(error as? CredentialIssuerMetadataError, .invalidBatchSize)
    }
  }

  func testDecodeMetadata_WithNegativeBatchSize_throwsError() throws {
    let metadataData = CredentialIssuerMetadata.Mock.sampleWithNegativeBatchSizeData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialIssuerMetadata.self, from: metadataData)) { error in
      XCTAssertEqual(error as? CredentialIssuerMetadataError, .invalidBatchSize)
    }
  }
}
