import Foundation
import XCTest
@testable import BITOpenID
@testable import BITSdJWT

final class VcSdJwtTypeMetadataUriTests: XCTestCase {

  // MARK: Internal

  func testTypeMetadataUri_vctMetadataUri_returnsVctMetadataUriAndIntegrity() {
    let vcSdJwtMock = createVcSdJwt(
      vct: vctMock,
      vctMetadataUri: vctMetadataUriMock,
      vctMetadataUriIntegrity: vctMetadataUriIntegrityMock)

    let uri = vcSdJwtMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctMetadataUriMock)
    XCTAssertEqual(uri?.integrity, vctMetadataUriIntegrityMock)
  }

  func testTypeMetadataUri_vctUrl_returnsVctUrlAndIntegrity() {
    let vcSdJwtMock = createVcSdJwt(vct: vctUrlMock, vctIntegrity: vctIntegrityMock)

    let uri = vcSdJwtMock.typeMetadataUri

    XCTAssertEqual(uri?.url.absoluteString, vctUrlMock)
    XCTAssertEqual(uri?.integrity, vctIntegrityMock)
  }

  func testTypeMetadataUri_vctMetadataUriNotUrl_returnsNil() {
    let vcSdJwtMock = createVcSdJwt(vct: vctUrlMock, vctMetadataUri: "invalid", vctMetadataUriIntegrity: "vctMetadataUriIntegrity")

    let uri = vcSdJwtMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  func testTypeMetadataUri_vctUrlNotUrl_returnsNil() {
    let vcSdJwtMock = createVcSdJwt(vct: "invalid", vctIntegrity: vctIntegrityMock)

    let uri = vcSdJwtMock.typeMetadataUri

    XCTAssertNil(uri)
  }

  // MARK: Private

  private let vctMock = "vct"
  private let vctUrlMock = "https://vct.example.com"
  private let vctIntegrityMock = "vctIntegrity"

  private let vctMetadataUriMock = "https://vct-metadata.example.com"
  private let vctMetadataUriIntegrityMock = "vctMetadataUriIntegrity"

  private func createVcSdJwt(vct: String, vctIntegrity: String? = nil, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil) -> VcSdJwt {
    VcSdJwt(
      requiredIssuer: "issuer",
      vct: vct,
      vctIntegrity: vctIntegrity,
      vctMetadataUri: vctMetadataUri,
      vctMetadataUriIntegrity: vctMetadataUriIntegrity)
  }
}
