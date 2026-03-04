import XCTest
@testable import BITCrypto
@testable import JOSESwift

class ContentEncryptionAlgorithmTests: XCTestCase {

  func testInit_success() {
    let encryptionAlgorithm = try? ContentEncryptionAlgorithm(from: .A128GCM)
    XCTAssertEqual(encryptionAlgorithm, .A128GCM)
  }
}
