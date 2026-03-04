import CryptoKit
import XCTest
@testable import BITCrypto
@testable import BITTestingCore

// MARK: - EncrypterTests

final class AESEncrypterTests: XCTestCase {

  // MARK: Internal

  func testEncryptWithAsymmetricKey_withVector() throws {
    let encrypter = AESEncrypter()
    guard let data: Data = "123456".data(using: .utf8) else { fatalError("pin data conversion") }
    let initialVector = try Data.random(length: 12)
    let privateKey = SecKeyTestsHelper.createPrivateKey()

    let cipherData1 = try encrypter.encrypt(
      data,
      withAsymmetricKey: privateKey,
      length: Self.keyLength,
      derivationAlgorithm: .ecdhKeyExchangeStandardX963SHA256,
      initialVector: initialVector)
    let cipherData2 = try encrypter.encrypt(
      data,
      withAsymmetricKey: privateKey,
      length: Self.keyLength,
      derivationAlgorithm: .ecdhKeyExchangeStandardX963SHA256,
      initialVector: initialVector)

    XCTAssertFalse(cipherData1.isEmpty)
    XCTAssertFalse(cipherData2.isEmpty)
    XCTAssertEqual(cipherData1.hexString, cipherData2.hexString)
  }

  func testEncryptWithAsymmetricKey_noVector() throws {
    let encrypter = AESEncrypter()
    guard let data: Data = "123456".data(using: .utf8) else { fatalError("pin data conversion") }
    let privateKey = SecKeyTestsHelper.createPrivateKey()

    let cipherData1 = try encrypter.encrypt(
      data,
      withAsymmetricKey: privateKey,
      length: Self.keyLength,
      derivationAlgorithm: .ecdhKeyExchangeStandardX963SHA256,
      initialVector: nil)
    let cipherData2 = try encrypter.encrypt(
      data,
      withAsymmetricKey: privateKey,
      length: Self.keyLength,
      derivationAlgorithm: .ecdhKeyExchangeStandardX963SHA256,
      initialVector: nil)

    XCTAssertFalse(cipherData1.isEmpty)
    XCTAssertFalse(cipherData2.isEmpty)
    XCTAssertNotEqual(cipherData1.hexString, cipherData2.hexString)
  }

  func testEncryptWithSymmetricKey_withVector() throws {
    let encrypter = AESEncrypter()
    guard let data: Data = "123456".data(using: .utf8) else { fatalError("pin data conversion") }
    let initialVector = try Data.random(length: Self.vectorLength)
    let symmetricKey = SymmetricKey(size: .bits256)

    let cipherData1 = try encrypter.encrypt(
      data,
      withSymmetricKey: symmetricKey,
      initialVector: initialVector)
    let cipherData2 = try encrypter.encrypt(
      data,
      withSymmetricKey: symmetricKey,
      initialVector: initialVector)

    XCTAssertFalse(cipherData1.isEmpty)
    XCTAssertFalse(cipherData2.isEmpty)
    XCTAssertEqual(cipherData1.hexString, cipherData2.hexString)
  }

  func testEncryptWithSymmetricKey_noVector() throws {
    let encrypter = AESEncrypter()
    guard let data: Data = "123456".data(using: .utf8) else { fatalError("pin data conversion") }
    let symmetricKey = SymmetricKey(size: .bits256)

    let cipherData1 = try encrypter.encrypt(
      data,
      withSymmetricKey: symmetricKey,
      initialVector: nil)
    let cipherData2 = try encrypter.encrypt(
      data,
      withSymmetricKey: symmetricKey,
      initialVector: nil)

    XCTAssertFalse(cipherData1.isEmpty)
    XCTAssertFalse(cipherData2.isEmpty)
    XCTAssertNotEqual(cipherData1.hexString, cipherData2.hexString)
  }

  // MARK: Private

  private static let keyLength = 32
  private static let vectorLength = 12

}
