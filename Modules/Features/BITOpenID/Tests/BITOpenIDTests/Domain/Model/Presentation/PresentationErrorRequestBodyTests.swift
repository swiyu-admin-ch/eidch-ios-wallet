import XCTest
@testable import BITOpenID

final class PresentationErrorRequestBodyTests: XCTestCase {

  // MARK: Internal

  func test_refusePresentation() {
    let presentationErrorRequestBody = PresentationErrorRequestBody(error: .accessDenied)
    let dictionary = presentationErrorRequestBody.asDictionary()

    XCTAssertFalse(dictionary.isEmpty)
    XCTAssertEqual(dictionary.count, 1)
    XCTAssertTrue(dictionary.contains(where: { $0.key == "error" }))
    XCTAssertFalse(dictionary.contains(where: { $0.key == "error_description" }))

    XCTAssertEqual(dictionary["error"] as? String, error.rawValue)
  }

  func test_refusePresentationWithDescription() {
    let presentationErrorRequestBody = PresentationErrorRequestBody(error: .accessDenied, errorDescription: "description")
    let dictionary = presentationErrorRequestBody.asDictionary()

    XCTAssertFalse(dictionary.isEmpty)
    XCTAssertEqual(dictionary.count, 2)
    XCTAssertTrue(dictionary.contains(where: { $0.key == "error" }))
    XCTAssertTrue(dictionary.contains(where: { $0.key == "error_description" }))

    XCTAssertEqual(dictionary["error"] as? String, error.rawValue)
    XCTAssertEqual(dictionary["error_description"] as? String, "description")
  }

  // MARK: Private

  private let error = PresentationErrorRequestBody.Code.accessDenied
}
