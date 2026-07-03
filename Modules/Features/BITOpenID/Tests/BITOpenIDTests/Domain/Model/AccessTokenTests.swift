// swiftlint:disable force_unwrapping
import Factory
import XCTest
@testable import BITOpenID

final class AccessTokenTests: XCTestCase {

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  func testDecode_allFields() throws {
    let data = AccessToken.Mock.sampleData

    XCTAssertNoThrow(try JSONDecoder().decode(AccessToken.self, from: data))
  }

  func testDecode_missingTokenType_throws() {
    let data = AccessToken.Mock.sampleWithoutTokenTypeData

    XCTAssertThrowsError(try JSONDecoder().decode(AccessToken.self, from: data)) { error in
      XCTAssertEqual(error as? AccessTokenError, .accessTokenDecodingError)
    }
  }

  func testDecode_dpopTokenType_success() throws {
    let data = AccessToken.Mock.sampleDPoPData

    let accessToken = try JSONDecoder().decode(AccessToken.self, from: data)

    XCTAssertEqual(accessToken.tokenType, .dpop)
    XCTAssertEqual(accessToken.accessToken, AccessToken.Mock.sampleDPoP.accessToken)
    XCTAssertEqual(accessToken.refreshToken, AccessToken.Mock.sampleDPoP.refreshToken)
  }

  func testDecode_uppercaseTokenType_success() throws {
    let data = AccessToken.Mock.sampleUppercaseDPoPData

    let accessToken = try JSONDecoder().decode(AccessToken.self, from: data)

    XCTAssertEqual(accessToken.tokenType, .dpop)
  }
}
