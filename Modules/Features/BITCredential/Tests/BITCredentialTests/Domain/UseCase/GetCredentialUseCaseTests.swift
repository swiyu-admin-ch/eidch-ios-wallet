// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class GetCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    repositorySpy = CredentialRepositoryProcotolSpy()
    Container.shared.credentialRepository.register { self.repositorySpy }
    useCase = GetCredentialUseCase()
  }

  func testCallAsFunction_success_returnsCredential() async throws {
    repositorySpy.getIdReturnValue = credentialMock

    let credential = try await useCase(id: credentialIdMock)

    XCTAssertEqual(credential as? VerifiableCredential, credentialMock)
    XCTAssertEqual(repositorySpy.getIdCallsCount, 1)
    XCTAssertEqual(repositorySpy.getIdReceivedId, credentialIdMock)
  }

  func testCallAsFunction_repositoryThrowsError_throwsError() async throws {
    repositorySpy.getIdThrowableError = TestingError.error

    do {
      _ = try await useCase(id: credentialIdMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var credentialIdMock = UUID()
  private var credentialMock = VerifiableCredential.Mock.sample

  private var repositorySpy: CredentialRepositoryProcotolSpy!

  private var useCase: GetCredentialUseCase!
}
