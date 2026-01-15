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
}
