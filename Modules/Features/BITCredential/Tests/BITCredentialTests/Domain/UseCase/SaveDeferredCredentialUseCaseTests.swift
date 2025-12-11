import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class SaveDeferredCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.credentialRepository.register { self.credentialRepository }
    credentialRepository.createDeferredCredentialReturnValue = mockCredential
    useCase = SaveDeferredCredentialUseCase()
  }

  func testExecute_success() async throws {
    try await useCase.execute(for: mockCredential)

    XCTAssertEqual(credentialRepository.createDeferredCredentialCallsCount, 1)
    XCTAssertEqual(credentialRepository.createDeferredCredentialReceivedDeferredCredential, mockCredential)
  }

  func testExecute_credentialRepositoryFails_throwsError() async throws {
    credentialRepository.createDeferredCredentialThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockCredential)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: SaveDeferredCredentialUseCase!

  private var mockCredential = DeferredCredential.Mock.sample
  private var credentialRepository = CredentialRepositoryProcotolSpy()

}
