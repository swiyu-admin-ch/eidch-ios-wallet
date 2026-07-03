import Foundation
import XCTest
@testable import BITOpenID
@testable import BITSdJWT

final class VcSdJwtTypeMetadataUriTests: XCTestCase {

  // MARK: Internal

  func testTypeMetadataUri_vctMetadataUri_returnsVctMetadataUriAndIntegrity() throws {
    let vcSdJwtMock = createVcSdJwt(
      vct: vctMock,
      vctIntegrity: vctIntegrityMock,
      vctMetadataUri: vctMetadataUriMock,
      vctMetadataUriIntegrity: vctMetadataUriIntegrityMock)

    let uri = try vcSdJwtMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctMetadataUriMock)
    XCTAssertEqual(uri?.integrity, vctMetadataUriIntegrityMock)
  }

  func testTypeMetadataUri_vctUrl_returnsVctUrlAndIntegrity() throws {
    let vcSdJwtMock = createVcSdJwt(vct: vctUrlMock, vctIntegrity: vctIntegrityMock)

    let uri = try vcSdJwtMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctUrlMock)
    XCTAssertEqual(uri?.integrity, vctIntegrityMock)
  }

  func testTypeMetadataUri_vctMetadataUriNotUrl_returnsNil() throws {
    let vcSdJwtMock = createVcSdJwt(vct: vctUrlMock, vctMetadataUri: "invalid", vctMetadataUriIntegrity: "vctMetadataUriIntegrity")

    let uri = try vcSdJwtMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  func testTypeMetadataUri_vctNotUrlNoVctIntegrity_returnsNil() throws {
    let vcSdJwtMock = createVcSdJwt(vct: "invalid")

    let uri = try vcSdJwtMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  func testTypeMetadataUri_vctNotUrlWithVctIntegrity_throwsError() throws {
    let vcSdJwtMock = createVcSdJwt(vct: "invalid", vctIntegrity: vctIntegrityMock)

    XCTAssertThrowsError(_ = try vcSdJwtMock.typeMetadataUri) { error in
      XCTAssertEqual(error as? VcMetadataForVcSdJwtError, .superfluousVctIntegrity)
    }
  }

  // MARK: Private

  private let vctMock = "vct"
  private let vctUrlMock = "https://vct.example.com"
  private let vctIntegrityMock = "vctIntegrity"

  private let vctMetadataUriMock = "https://vct-metadata.example.com"
  private let vctMetadataUriIntegrityMock = "vctMetadataUriIntegrity"

  private func createVcSdJwt(vct: String, vctIntegrity: String? = nil, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil) -> VcSdJwt {
    VcSdJwt(
      vct: vct,
      vctIntegrity: vctIntegrity,
      vctMetadataUri: vctMetadataUri,
      vctMetadataUriIntegrity: vctMetadataUriIntegrity)
  }
}
