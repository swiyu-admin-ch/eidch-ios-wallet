import XCTest
@testable import BITOpenID

final class PresentationRequestBodyTests: XCTestCase {

  // MARK: Internal

  func test_acceptPresentation() {
    let presentationRequestBody = AuthorizationResponse(vpToken: vpToken, presentationSubmission: presentationSubmission)
    let dictionary = presentationRequestBody.asDictionary()

    XCTAssertFalse(dictionary.isEmpty)
    XCTAssertEqual(dictionary.count, 2)
    XCTAssertTrue(dictionary.contains(where: { $0.key == "vp_token" }))
    XCTAssertTrue(dictionary.contains(where: { $0.key == "presentation_submission" }))

    XCTAssertEqual(dictionary["vp_token"] as? String, vpToken)
    XCTAssertTrue(dictionary["presentation_submission"] is String)
  }

  func test_acceptPresentation_dcql() {
    let response = AuthorizationResponse(vpTokenByCredentialQueryId: vpTokenByCredentialQueryId)
    let dictionary = response.asDictionary()

    XCTAssertFalse(dictionary.isEmpty)
    XCTAssertEqual(dictionary.count, 1)
    XCTAssertTrue(dictionary.contains(where: { $0.key == "vp_token" }))

    XCTAssertEqual(dictionary["vp_token"] as? String, dcqlVpToken)
  }

  // MARK: Private

  private static let definitionId = UUID().uuidString

  private static let id = UUID().uuidString

  private let vpToken = "vpToken"
  private let dcqlVpToken = "{\"query_1\":[\"vpToken\"]}"
  private let vpTokenByCredentialQueryId = ["query_1": ["vpToken"]]
  private let presentationSubmission = AuthorizationResponse.PresentationSubmission(id: id, definitionId: definitionId, descriptorMap: [])

}
