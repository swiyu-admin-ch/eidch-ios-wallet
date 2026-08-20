import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class DeleteCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    credentialRepository = CredentialRepositoryProtocolSpy()

    Container.shared.credentialRepository.register { self.credentialRepository }

    useCase = DeleteCredentialUseCase()
  }

  func testDeleteCredential_Success() async throws {
    try await useCase.execute(mockCredential)

    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.id, mockCredential.id)
    XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsReceivedArguments?.deleteKeyPairs, true)
  }

  func testDeleteCredential_FailureOnRepository() async throws {
    credentialRepository.deleteDeleteKeyPairsThrowableError = TestingError.error

    do {
      try await useCase.execute(mockCredential)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(credentialRepository.deleteDeleteKeyPairsCalled)
      XCTAssertEqual(credentialRepository.deleteDeleteKeyPairsCallsCount, 1)
    }
  }

  // MARK: Private

  private var mockCredential = VerifiableCredential.Mock.sample
  private var useCase = DeleteCredentialUseCase()
  private var credentialRepository = CredentialRepositoryProtocolSpy()
}
