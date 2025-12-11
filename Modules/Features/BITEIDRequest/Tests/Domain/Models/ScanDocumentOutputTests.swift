import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared

final class ScanDocumentOutputTests: XCTestCase {

  // MARK: Internal

  func testInit() throws {
    let documentOutput = try ScanDocumentOutput(mockPackageResult, identityType: .passport)

    XCTAssertEqual(documentOutput.identityType, .passport)
    XCTAssertEqual(documentOutput.files.count, 3)
  }

  // MARK: Private

  private let mockPackageResult = AVBeamPackageResult.Mock.sample
}
