import JWSETKit
import XCTest
@testable import BITCrypto

class ContentEncryptionAlgorithmTests: XCTestCase {

  func testInit_A128GCM_success() {
    let encryptionAlgorithm = try? JSONWebContentEncryptionAlgorithm(from: .A128GCM)
    XCTAssertEqual(encryptionAlgorithm, .aesEncryptionGCM128)
  }

  func testInit_A256GCM_success() {
    let encryptionAlgorithm = try? JSONWebContentEncryptionAlgorithm(from: .A256GCM)
    XCTAssertEqual(encryptionAlgorithm, .aesEncryptionGCM256)
  }
}
