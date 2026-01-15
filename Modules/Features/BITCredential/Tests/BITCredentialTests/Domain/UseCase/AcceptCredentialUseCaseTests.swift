import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class AcceptCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    registerMocks()
    useCase = AcceptCredentialUseCase()
    createSuccess()
  }

  func testUseCase_success_assertCount() async throws {
    let result = try await useCase(mockCredential)

    XCTAssertEqual(result, updateCredential)
    XCTAssertEqual(credentialRepository.updateVerifiableCredentialCallsCount, 1)
  }

  func testUseCase_success_assertParameters() async throws {
    _ = try await useCase(mockCredential)

    XCTAssertEqual(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.id, mockCredential.id)
    XCTAssertEqual(credentialRepository.updateVerifiableCredentialReceivedVerifiableCredential?.progressionState, .accepted)
  }

  func testUseCase_updateCredentialFails_throwsError() async throws {
    credentialRepository.updateVerifiableCredentialThrowableError = TestingError.error

    do {
      _ = try await useCase(mockCredential)
      XCTFail("Expected exception")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockCredential = VerifiableCredential.Mock.sample
  private let updateCredential = VerifiableCredential.Mock.diploma

  private var useCase: AcceptCredentialUseCase!
  private var credentialRepository: CredentialRepositoryProcotolSpy!

  private func registerMocks() {
    credentialRepository = CredentialRepositoryProcotolSpy()
    Container.shared.credentialRepository.register { self.credentialRepository }
  }

  private func createSuccess() {
    credentialRepository.updateVerifiableCredentialReturnValue = updateCredential
  }

}
