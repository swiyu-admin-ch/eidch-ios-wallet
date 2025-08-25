import Factory
import Spyable
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore
@testable import BITVault

final class DeleteCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    keyManagerProtocolSpy = KeyManagerProtocolSpy()
    localRepositorySpy = CredentialRepositoryProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerProtocolSpy }
    Container.shared.databaseCredentialRepository.register { self.localRepositorySpy }

    useCase = DeleteCredentialUseCase()
  }

  func testDeleteCredential_Success() async throws {
    try await useCase.execute(mockCredential)

    XCTAssertEqual(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, mockCredential.keyBinding?.id.uuidString)
    XCTAssertEqual(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM)
    XCTAssertEqual(localRepositorySpy.deleteReceivedId, mockCredential.id)
  }

  func testDeleteCredential_WithoutPrivateKey() async throws {
    var credential = mockCredential
    credential.keyBinding = nil

    try await useCase.execute(credential)

    XCTAssertFalse(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    XCTAssertEqual(localRepositorySpy.deleteReceivedId, mockCredential.id)
  }

  func testDeleteCredential_FailureOnVaultAlgorithm() async throws {
    var credential = mockCredential
    credential.keyBinding = keyBindingWithUnknownAlgorithm

    try await useCase.execute(credential)

    XCTAssertFalse(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    XCTAssertEqual(localRepositorySpy.deleteReceivedId, mockCredential.id)
  }

  func testDeleteCredential_FailureOnVault() async throws {
    keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmThrowableError = TestingError.error

    try await useCase.execute(mockCredential)

    XCTAssertTrue(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    XCTAssertEqual(localRepositorySpy.deleteReceivedId, mockCredential.id)
  }

  func testDeleteCredential_FailureOnRepository() async throws {
    localRepositorySpy.deleteThrowableError = TestingError.error

    do {
      try await useCase.execute(mockCredential)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(localRepositorySpy.deleteCalled)
      XCTAssertEqual(localRepositorySpy.deleteCallsCount, 1)

      XCTAssertTrue(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
      XCTAssertEqual(keyManagerProtocolSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    }
  }

  // MARK: Private

  private var mockCredential = Credential.Mock.sample
  private var keyBindingWithUnknownAlgorithm = CredentialKeyBinding(id: UUID(), algorithm: "unknown_algorithm", bindingType: .hardware)
  private var useCase = DeleteCredentialUseCase()
  private var keyManagerProtocolSpy = KeyManagerProtocolSpy()
  private var localRepositorySpy = CredentialRepositoryProtocolSpy()
}
