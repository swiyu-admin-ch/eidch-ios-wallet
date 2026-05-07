import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class DeleteCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    credentialRepository = CredentialRepositoryProcotolSpy()

    Container.shared.credentialRepository.register { self.credentialRepository }

    useCase = DeleteCredentialUseCase()
  }

  func testDeleteCredential_Success() async throws {
    try await useCase.execute(mockCredential)

    XCTAssertEqual(credentialRepository.deleteReceivedId, mockCredential.id)
  }

  func testDeleteCredential_FailureOnRepository() async throws {
    credentialRepository.deleteThrowableError = TestingError.error

    do {
      try await useCase.execute(mockCredential)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(credentialRepository.deleteCalled)
      XCTAssertEqual(credentialRepository.deleteCallsCount, 1)
    }
  }

  // MARK: Private

  private var mockCredential = VerifiableCredential.Mock.sample
  private var useCase = DeleteCredentialUseCase()
  private var credentialRepository = CredentialRepositoryProcotolSpy()
}
