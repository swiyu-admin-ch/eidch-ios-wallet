import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class PresentationRequestUrlParserTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    parser = PresentationRequestUrlParser()
  }

  func testParse_httpsUrl_returnsHttpsUrl() throws {
    let result = try parser.parse(httpsUrl)

    if case .https(let url) = result {
      XCTAssertEqual(url, httpsUrl)
    } else {
      XCTFail("Wrong request object url type")
    }
  }

  func testParse_openID4VPUrl_returnsOpenID4VPUrl() throws {
    let result = try parser.parse(openID4VPUrl)

    if case .openID4VP(let url, let clientId) = result {
      XCTAssertEqual(url, httpsUrl)
      XCTAssertEqual(clientId, clientIdMock)
    } else {
      XCTFail("Wrong request object url type")
    }
  }

  func testParse_openID4VPUrlWithNoClientId_throwsInvalidRequestUrlError() throws {
    let url = try XCTUnwrap(URL(string: "openid4vp://?request_uri=https%3A%2F%2Fexample.com"))

    XCTAssertThrowsError(try parser.parse(url)) { error in
      XCTAssertEqual(error as? FetchPresentationRequestError, .invalidRequestUrl)
    }
  }

  func testParse_openID4VPUrlWithNoRequestUri_throwsInvalidRequestUrlError() throws {
    let url = try XCTUnwrap(URL(string: "openid4vp://?client_id=did%3Aexample%3A12345"))

    XCTAssertThrowsError(try parser.parse(url)) { error in
      XCTAssertEqual(error as? FetchPresentationRequestError, .invalidRequestUrl)
    }
  }

  func testParse_openID4VPUrlWithNoQueryParameters_throwsInvalidRequestUrlError() throws {
    let url = try XCTUnwrap(URL(string: "openid4vp://"))

    XCTAssertThrowsError(try parser.parse(url)) { error in
      XCTAssertEqual(error as? FetchPresentationRequestError, .invalidRequestUrl)
    }
  }

  // MARK: Private

  private let httpsUrl = URL(string: "https://example.com")!
  private let openID4VPUrl = URL(string: "openid4vp://?client_id=did%3Aexample%3A12345&request_uri=https%3A%2F%2Fexample.com")!
  private let clientIdMock = "did:example:12345"

  private var parser: PresentationRequestUrlParser!
}

// swiftlint:enable force_unwrapping implicitly_unwrapped_optional
