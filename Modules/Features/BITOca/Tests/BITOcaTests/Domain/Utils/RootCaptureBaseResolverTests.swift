import XCTest
@testable import BITOca

final class RootCaptureBaseResolverTests: XCTestCase {

  // MARK: Internal

  func testResolve_ValidCaptureBase_returnsRoot() throws {
    let captureBase1 = Self.createCaptureBase(digest: "a", attributes: ["test": referenceAttributeMock])
    let captureBase2 = Self.createCaptureBase(digest: "digest", attributes: ["test": .text])

    let root = try resolver.resolve([captureBase1, captureBase2]) as? CaptureBase1x0

    XCTAssertEqual(root, captureBase1)
  }

  func testResolve_noCaptureBases_throwsError() throws {
    XCTAssertThrowsError(try resolver.resolve([])) { error in
      XCTAssertEqual(error as? OcaError, .invalidRootCaptureBase)
    }
  }

  func testResolve_noRootCaptureBase_throwsError() throws {
    let captureBase1 = Self.createCaptureBase(attributes: ["test": referenceAttributeMock])
    let captureBase2 = Self.createCaptureBase(attributes: ["test": .array(type: referenceAttributeMock)])

    XCTAssertThrowsError(try resolver.resolve([captureBase1, captureBase2])) { error in
      XCTAssertEqual(error as? OcaError, .invalidRootCaptureBase)
    }
  }

  func testResolve_multiRootCaptureBases_throwsError() throws {
    XCTAssertThrowsError(try resolver.resolve([Self.createCaptureBase(), Self.createCaptureBase()])) { error in
      XCTAssertEqual(error as? OcaError, .invalidRootCaptureBase)
    }
  }

  // MARK: Private

  private static let digestMock = "digest"

  private let referenceAttributeMock = AttributeType.reference(digest: digestMock)
  private let resolver = RootCaptureBaseResolver()

  private static func createCaptureBase(digest: String = digestMock, attributes: [AttributeKey: AttributeType] = [:]) -> CaptureBase1x0 {
    CaptureBase1x0(digest: digest, attributes: attributes, classification: nil, flaggedAttributes: nil)
  }

}
