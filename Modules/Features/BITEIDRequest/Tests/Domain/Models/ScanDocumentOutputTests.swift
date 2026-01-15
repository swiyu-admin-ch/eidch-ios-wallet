import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared

final class ScanDocumentOutputTests: XCTestCase {

  func testInit() throws {
    let documentOutput = try ScanDocumentOutput(.Mock.sample, identityType: .passport)

    XCTAssertEqual(documentOutput.identityType, .passport)
    XCTAssertEqual(documentOutput.files.count, 3)
  }
}
