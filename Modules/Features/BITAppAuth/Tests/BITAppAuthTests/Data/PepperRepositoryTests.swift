import BITCore
import BITCrypto
import Factory
import Foundation
import Spyable
import XCTest
@testable import BITAppAuth
@testable import BITTestingCore
@testable import BITVault

// MARK: - PepperRepositoryTests

final class PepperRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    repository = SecretsRepository()
  }

  func testCreatePepperKey() throws {
    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockKeyPair
    let secKey = try repository.createPepperKey()
    XCTAssertEqual(mockKeyPair.privateKey, secKey)
    XCTAssertTrue(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    XCTAssertEqual(mockKeyPair.algorithm, keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm)
    XCTAssertTrue(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCalled)
    XCTAssertEqual(mockKeyPair.algorithm, keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.algorithm)
    XCTAssertEqual([.secureEnclavePermanently], keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.options)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReceivedArguments?.identifier)
  }

  func testGetPepperKey() throws {
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair
    let secKey = try repository.getPepperKey()
    XCTAssertEqual(mockKeyPair.privateKey, secKey)
    XCTAssertTrue(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryCalled)
    XCTAssertEqual(mockKeyPair.algorithm, keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.algorithm)
  }

  func testGetPepperInitialVector() throws {
    let mockData = Data()
    secretManagerSpy.dataForKeyQueryReturnValue = mockData
    let data = try repository.getPepperInitialVector()
    XCTAssertEqual(mockData, data)
    XCTAssertTrue(secretManagerSpy.dataForKeyQueryCalled)
  }

  func testSetPepperInitialVector() throws {
    let mockData = Data()
    let mockAccessControl = try SecAccessControl.create(accessControlFlags: [], protection: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
    try repository.setPepperInitialVector(mockData)
    XCTAssertTrue(secretManagerSpy.setForKeyQueryCalled)
    XCTAssertEqual(mockData, secretManagerSpy.setForKeyQueryReceivedArguments?.value as? Data)
    // swiftlint:disable force_cast
    XCTAssertEqual(mockAccessControl, secretManagerSpy.setForKeyQueryReceivedArguments?.query?[kSecAttrAccessControl as String] as! SecAccessControl)
    // swiftlint:enable force_cast
  }

  // MARK: Private

  private let mockKeyPair = VaultKeyPair.Mock.ES256

  // swiftlint:disable all
  private var secretManagerSpy: SecretManagerProtocolSpy!
  private var keyManagerSpy: KeyManagerProtocolSpy!
  private var processInfoServiceSpy: ProcessInfoServiceProtocolSpy!
  private var repository: PepperRepositoryProtocol!

  // swiftlint:enable all

  private func registerMocks() {
    secretManagerSpy = SecretManagerProtocolSpy()
    keyManagerSpy = KeyManagerProtocolSpy()
    processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    Container.shared.secretManager.register { self.secretManagerSpy }
    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.processInfoService.register { self.processInfoServiceSpy }
  }

}
