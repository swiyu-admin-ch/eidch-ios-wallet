// swiftlint:disable force_unwrapping force_cast
import BITCore
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

final class CredentialMetadataTests: XCTestCase {

  func testDecodeMetadata() throws {
    let credentialMetadata = CredentialMetadata.Mock.sample

    XCTAssertFalse(credentialMetadata.credentialConfigurationsSupported.isEmpty)
    XCTAssertFalse(credentialMetadata.display?.isEmpty == true)

    let credentialSupported = try XCTUnwrap(credentialMetadata.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value)

    XCTAssertNotNil(credentialSupported.cryptographicBindingMethodsSupported)
    XCTAssertNotNil(credentialSupported.display)
    XCTAssertNotNil(credentialSupported.orderClaims)
    XCTAssertNotNil(credentialSupported.credentialSigningAlgValuesSupported)
    XCTAssertNotNil(credentialSupported.proofTypesSupported)
    XCTAssertFalse(try XCTUnwrap(credentialSupported.cryptographicBindingMethodsSupported?.isEmpty))
    XCTAssertFalse(try XCTUnwrap(credentialSupported.display?.isEmpty))
    XCTAssertFalse(try XCTUnwrap(credentialSupported.orderClaims?.isEmpty))
    XCTAssertFalse(try XCTUnwrap(credentialSupported.credentialSigningAlgValuesSupported?.isEmpty))
    XCTAssertEqual(credentialSupported.proofTypesSupported.count, 1)
    if case .jwt(let type) = credentialSupported.proofTypesSupported.first {
      XCTAssertEqual(type.supportedAlgorithms.count, 2)
    }

    XCTAssertFalse(credentialSupported.claims.isEmpty)
    XCTAssertEqual(credentialSupported.claims.count, credentialSupported.orderClaims?.count)

    for claim in credentialSupported.claims {
      let order = credentialSupported.orderClaims?.firstIndex(where: { $0 == claim.key })
      XCTAssertEqual(claim.order, order)
    }
  }

  func testDecodeMetadata_WithoutProofTypes_ReturnsMetadataWithoutProofTypes() throws {
    let credentialMetadata = CredentialMetadata.Mock.sampleWithoutProofTypes
    let credentialSupported = try XCTUnwrap(credentialMetadata.credentialConfigurationsSupported.first(where: { $0.key == "elfa-sdjwt" })?.value)

    XCTAssertTrue(credentialSupported.proofTypesSupported.isEmpty)
  }

  func testDecodeMetadata_WithVctUrl_ReturnsMetadataWithVctUrl() throws {
    let credentialMetadata = CredentialMetadata.Mock.vctUrl
    let credentialSupported = try XCTUnwrap(credentialMetadata.credentialConfigurationsSupported.first?.value as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported)

    XCTAssertEqual(credentialSupported.vct, "https://vct.example.com")
    XCTAssertEqual(credentialSupported.vctIntegrity, "vctIntegrity")
  }

  func testDecodeMetadata_WithVctMetadataUri_ReturnsMetadataWithVctMetadataUri() throws {
    let credentialMetadata = CredentialMetadata.Mock.vctMetadataUri
    let credentialSupported = try XCTUnwrap(credentialMetadata.credentialConfigurationsSupported.first?.value as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported)

    XCTAssertEqual(credentialSupported.vct, "vct")
    XCTAssertNil(credentialSupported.vctIntegrity)
    XCTAssertEqual(credentialSupported.vctMetadataUri, "https://vct-metadata.example.com")
    XCTAssertEqual(credentialSupported.vctMetadataUriIntegrity, "vctMetadataUriIntegrity")
  }

  func testDecodeMetadata_WithUnsupportedProofTypeAlgorithm_ThrowsError() throws {
    let credentialMetadataData = CredentialMetadata.Mock.sampleUnsupportedProofTypeAlgorithmData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialMetadata.self, from: credentialMetadataData)) { error in
      XCTAssertEqual(error as? CredentialMetadata.AnyCredentialConfigurationSupportedError, .invalidProofType)
    }
  }

  func testDecodeMetadata_WithUnsupportedCryptographicBindingMethod_ThrowsError() throws {
    let credentialMetadataData = CredentialMetadata.Mock.sampleUnsupportedCryptographicBindingMethodData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialMetadata.self, from: credentialMetadataData)) { error in
      XCTAssertEqual(error as? CredentialMetadata.AnyCredentialConfigurationSupportedError, .invalidCryptographicBindingMethod)
    }
  }

  func testDecodeMetadata_WithUnsupportedNonceEndpoint_ThrowsError() throws {
    let credentialMetadataData = CredentialMetadata.Mock.chasseralIssuerUnsupportedNonceData
    XCTAssertThrowsError(try JSONDecoder().decode(CredentialMetadata.self, from: credentialMetadataData)) { error in
      XCTAssertNotNil(error as? DecodingError)
    }
  }

  func testDecodeUnknownMetadataFormat() throws {
    let credentialMetadataData = CredentialMetadata.Mock.sampleWithUnknownFormatData
    let credentialMetadata = try JSONDecoder().decode(CredentialMetadata.self, from: credentialMetadataData)
    XCTAssertFalse(credentialMetadata.credentialConfigurationsSupported.isEmpty)

    guard let jsonObject = try JSONSerialization.jsonObject(with: credentialMetadataData, options: []) as? [String: Any] else {
      XCTFail("can not decode Data in to [String: Any]")
      return
    }
    guard let credentialConfigurations = jsonObject["credential_configurations_supported"] as? [String: Any] else {
      XCTFail("can not parse credential_configurations_supported")
      return
    }
    XCTAssertTrue(credentialMetadata.credentialConfigurationsSupported.count == credentialConfigurations.count - 1, "There should be an unknown format that has been ignored")
  }

}
