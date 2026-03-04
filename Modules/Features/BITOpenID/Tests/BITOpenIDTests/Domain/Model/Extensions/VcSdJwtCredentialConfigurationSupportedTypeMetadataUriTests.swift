import Foundation
import XCTest
@testable import BITOpenID

final class VcSdJwtCredentialConfigurationSupportedTypeMetadataUriTests: XCTestCase {

  // MARK: Internal

  func testTypeMetadataUri_vctMetadataUri_returnsVctMetadataUriAndIntegrity() {
    let metadataMock = createMetadata(
      vct: vctMock,
      vctMetadataUri: vctMetadataUriMock,
      vctMetadataUriIntegrity: vctMetadataUriIntegrityMock)

    let uri = metadataMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctMetadataUriMock)
    XCTAssertEqual(uri?.integrity, vctMetadataUriIntegrityMock)
  }

  func testTypeMetadataUri_vctUrl_returnsVctUrlAndIntegrity() {
    let metadataMock = createMetadata(vct: vctUrlMock, vctIntegrity: vctIntegrityMock)

    let uri = metadataMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctUrlMock)
    XCTAssertEqual(uri?.integrity, vctIntegrityMock)
  }

  func testTypeMetadataUri_vctMetadataUriNotUrl_returnsNil() {
    let metadataMock = createMetadata(vct: vctUrlMock, vctMetadataUri: "invalid", vctMetadataUriIntegrity: "vctMetadataUriIntegrity")

    let uri = metadataMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  func testTypeMetadataUri_vctUrlNotUrl_returnsNil() {
    let metadataMock = createMetadata(vct: "invalid", vctIntegrity: vctIntegrityMock)

    let uri = metadataMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  // MARK: Private

  private let vctMock = "vct"
  private let vctUrlMock = "https://vct.example.com"
  private let vctIntegrityMock = "vctIntegrity"

  private let vctMetadataUriMock = "https://vct-metadata.example.com"
  private let vctMetadataUriIntegrityMock = "vctMetadataUriIntegrity"

  private func createMetadata(vct: String, vctIntegrity: String? = nil, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil) -> CredentialMetadata.VcSdJwtCredentialConfigurationSupported {
    CredentialMetadata.VcSdJwtCredentialConfigurationSupported(
      format: "format",
      vct: vct,
      vctIntegrity: vctIntegrity,
      vctMetadataUri: vctMetadataUri,
      vctMetadataUriIntegrity: vctMetadataUriIntegrity)
  }
}
