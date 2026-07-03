import XCTest
@testable import BITOpenID

final class PresentationRequestBodyTests: XCTestCase {

  // MARK: Internal

  func test_acceptPresentation() {
    let response = AuthorizationResponse(vpToken: vpTokenByCredentialQueryId)
    let dictionary = response.asDictionary()

    XCTAssertFalse(dictionary.isEmpty)
    XCTAssertEqual(dictionary.count, 1)
    XCTAssertTrue(dictionary.contains(where: { $0.key == "vp_token" }))

    XCTAssertEqual(dictionary["vp_token"] as? String, vpTokenString)
  }

  func test_acceptPresentation_dcqlAndState() {
    let response = AuthorizationResponse(vpToken: vpTokenByCredentialQueryId, state: state)
    let dictionary = response.asDictionary()

    XCTAssertEqual(dictionary.count, 2)
    XCTAssertEqual(dictionary["state"] as? String, state)
  }

  // MARK: Private

  private let state = "state"
  private let vpTokenString = "{\"query_1\":[\"vpToken\"]}"
  private let vpTokenByCredentialQueryId = ["query_1": ["vpToken"]]

}
