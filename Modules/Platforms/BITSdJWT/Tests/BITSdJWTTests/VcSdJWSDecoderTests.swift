// swiftlint: disable implicitly_unwrapped_optional
import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - VcSdJWSDecoderTests

final class VcSdJWSDecoderTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    decoder = VcSdJWSDecoder()
  }

  func testDecode_allFields_success() throws {
    let data = VcSdJWS.Mock.sampleData

    let vcSdJWS = try decoder.decode(VcSdJwt.self, from: data)

    try assertVcSdJwt(vcSdJWS, vctMetadataUri: Self.vctUrlMock, vctMetadataUriIntegrity: Self.vctIntegrityMock)
  }

  func testDecode_withoutKeyBinding_success() throws {
    let data = VcSdJWS.Mock.noKeyBindingData

    let vcSdJWS = try decoder.decode(VcSdJwt.self, from: data)

    try assertVcSdJwt(vcSdJWS)
  }

  func testDecode_vctMetadataUri_success() throws {
    let data = VcSdJWS.Mock.vctMetadataUriData

    let vcSdJWS = try decoder.decode(VcSdJwt.self, from: data)

    try assertVcSdJwt(
      vcSdJWS,
      vct: "identity_credential",
      vctIntegrity: nil,
      vctMetadataUri: Self.vctUrlMock,
      vctMetadataUriIntegrity: Self.vctIntegrityMock)
  }

  func testDecode_withLegacyType_success() throws {
    let data = VcSdJWS.Mock.sampleLegacyTypeData

    let vcSdJWS = try decoder.decode(VcSdJwt.self, from: data)

    try assertVcSdJwt(vcSdJWS, headerType: VcSdJwt.legacyType)
  }

  func testDecode_withUnregisteredNonSelectivelyDisclosableClaim_throwsError() throws {
    let data = VcSdJWS.Mock.unregistedNonSelectivelyDisclosableClaimData

    XCTAssertThrowsError(try decoder.decode(VcSdJwt.self, from: data)) { error in
      XCTAssertEqual(error as? VcSdJWSDecoderError, .unregisteredNonSelectivelyDisclosableClaimFound)
    }
  }

  func testDecode_nonDisclosableClaimInDisclosure_throwsError() throws {
    // ["test_salt", "iss", "value"]
    let disclosure = "WyJ0ZXN0X3NhbHQiLCAiaXNzIiwgInZhbHVlIl0"
    // {}
    let jws = "eyJ0eXAiOiJmbGF0IiwiYWxnIjoiRVM1MTIifQ.e30.AfTpiH-4UImlQZmM9AxEZJ45axWIAlz_BRWetjX6jRWCjzWXMIimSB7ltfTy2GXIWW0SNbP_IDF6FZgpb7Oybnk6AB362Bc2tUNKEy1N4hhMjxIIi3I1Vug4zCgxtmi3ffpBHMitfDJK6Oz8muWjoK4vHMXQZujwkv0NqkJZtUhLu3NM"
    let data = jws.sdJWSData(with: [disclosure])

    XCTAssertThrowsError(try decoder.decode(FlatJWT.self, from: data)) { error in
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidSdClaim(disclosure))
    }
  }

  @MainActor
  func testDecode_decoder_throwsError() throws {
    let decoderMock = SdJWSDecoderMock<FlatJWT>()
    decoderMock.decodeFromThrowableError = TestingError.error

    XCTAssertThrowsError(try VcSdJWSDecoder(sdJwsDecoder: decoderMock).decode(FlatJWT.self, from: VcSdJWS.Mock.sampleData)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let vctUrlMock = "https://credentials.example.com/identity_credential"
  private static let vctIntegrityMock = "sha265-onXnKxyPhvWaqkNqWgpL0r1lEoBfLIsJQfFuY5ydHPg"

  private var decoder: VcSdJWSDecoder!

  private func assertVcSdJwt(_ jws: VcSdJWS, vct: String = vctUrlMock, vctIntegrity: String? = vctIntegrityMock, vctMetadataUri: String? = nil, vctMetadataUriIntegrity: String? = nil, headerType: String = VcSdJwt.currentType) throws {
    let expectedStatusList = VcSdJwtTokenStatusList(statusList: VcSdJwtTokenStatusList.StatusList(index: 285, uri: "https://example.com/statuslist/example.jwt"))
    let jwt = jws.payload
    XCTAssertEqual(jws.header.type, headerType)
    XCTAssertEqual(jwt.issuer, "did:tdw:example")
    XCTAssertEqual(jwt.activatedAt, Date(timeIntervalSince1970: 1722499200))
    XCTAssertEqual(jwt.expiredAt, Date(timeIntervalSince1970: 1767168000))
    XCTAssertEqual(jwt.vct, vct)
    XCTAssertEqual(jwt.vctIntegrity, vctIntegrity)
    XCTAssertEqual(jwt.vctMetadataUri, vctMetadataUri)
    XCTAssertEqual(jwt.vctMetadataUriIntegrity, vctMetadataUriIntegrity)
    XCTAssertEqual(jwt.statusList, expectedStatusList)
    XCTAssertEqual(jwt.issuedAt, Date(timeIntervalSince1970: 1739282713))
  }
}
