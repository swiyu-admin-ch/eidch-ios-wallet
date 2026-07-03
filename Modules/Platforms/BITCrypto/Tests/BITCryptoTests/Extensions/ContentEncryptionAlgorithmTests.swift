import XCTest
@testable import BITCrypto
@testable import JOSESwift

class ContentEncryptionAlgorithmTests: XCTestCase {

  func testInit_A128GCM_success() {
    let encryptionAlgorithm = try? ContentEncryptionAlgorithm(from: .A128GCM)
    XCTAssertEqual(encryptionAlgorithm, .A128GCM)
  }

  func testInit_A256GCM_success() {
    let encryptionAlgorithm = try? ContentEncryptionAlgorithm(from: .A256GCM)
    XCTAssertEqual(encryptionAlgorithm, .A256GCM)
  }
}
