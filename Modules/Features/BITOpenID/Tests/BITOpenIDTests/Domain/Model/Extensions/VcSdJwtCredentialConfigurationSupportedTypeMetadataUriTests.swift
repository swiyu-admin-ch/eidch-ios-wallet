import Foundation
import XCTest
@testable import BITOpenID

final class VcSdJwtCredentialConfigurationSupportedTypeMetadataUriTests: XCTestCase {

  // MARK: Internal

  func testTypeMetadataUri_vctMetadataUri_returnsVctMetadataUriAndIntegrity() throws {
    let metadataMock = createMetadata(
      vct: vctMock,
      vctIntegrity: vctIntegrityMock,
      vctMetadataUri: vctMetadataUriMock,
      vctMetadataUriIntegrity: vctMetadataUriIntegrityMock)

    let uri = try metadataMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctMetadataUriMock)
    XCTAssertEqual(uri?.integrity, vctMetadataUriIntegrityMock)
  }

  func testTypeMetadataUri_vctUrl_returnsVctUrlAndIntegrity() throws {
    let metadataMock = createMetadata(vct: vctUrlMock, vctIntegrity: vctIntegrityMock)

    let uri = try metadataMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctUrlMock)
    XCTAssertEqual(uri?.integrity, vctIntegrityMock)
  }

  func testTypeMetadataUri_vctMetadataUriNotUrl_returnsNil() throws {
    let metadataMock = createMetadata(vct: vctUrlMock, vctMetadataUri: "invalid", vctMetadataUriIntegrity: "vctMetadataUriIntegrity")

    let uri = try metadataMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  func testTypeMetadataUri_vctNotUrlWithoutVctIntegrity_returnsNil() throws {
    let metadataMock = createMetadata(vct: "invalid")

    let uri = try metadataMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  func testTypeMetadataUri_vctNotUrlWithVctIntegrity_throwsError() throws {
    let metadataMock = createMetadata(vct: "invalid", vctIntegrity: vctIntegrityMock)

    XCTAssertThrowsError(_ = try metadataMock.typeMetadataUri) { error in
      XCTAssertEqual(error as? VcMetadataForVcSdJwtError, .superfluousVctIntegrity)
    }
  }

  // MARK: Private

  private let vctMock = "vct"
  private let vctUrlMock = "https://vct.example.com"
  private let vctIntegrityMock = "vctIntegrity"

  private let vctMetadataUriMock = "https://vct-metadata.example.com"
  private let vctMetadataUriIntegrityMock = "vctMetadataUriIntegrity"

  private func createMetadata(vct: String, vctIntegrity: String? = nil, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil) -> CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported {
    CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported(
      format: .vcSdJwt,
      vct: vct,
      vctIntegrity: vctIntegrity,
      vctMetadataUri: vctMetadataUri,
      vctMetadataUriIntegrity: vctMetadataUriIntegrity)
  }
}
