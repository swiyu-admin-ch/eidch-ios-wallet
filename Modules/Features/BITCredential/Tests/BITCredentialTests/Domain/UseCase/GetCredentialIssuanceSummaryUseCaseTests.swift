// swiftlint:disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class GetCredentialIssuanceSummaryUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    repositorySpy = CredentialRepositoryProtocolSpy()
    Container.shared.credentialRepository.register { self.repositorySpy }
    useCase = GetCredentialIssuanceSummaryUseCase()
  }

  func testExecute_success_returnsRepositorySummary() async throws {
    repositorySpy.getIssuanceSummaryIdReturnValue = summary

    let result = try await useCase(for: credentialId)

    XCTAssertEqual(result, summary)
    XCTAssertEqual(repositorySpy.getIssuanceSummaryIdCallsCount, 1)
    XCTAssertEqual(repositorySpy.getIssuanceSummaryIdReceivedId, credentialId)
  }

  func testExecute_repositoryThrowsUnsupportedCredential_throwsUnsupportedCredential() async {
    repositorySpy.getIssuanceSummaryIdThrowableError = CredentialRepositoryError.unsupportedCredential

    do {
      _ = try await useCase(for: credentialId)
      XCTFail("Expecting GetCredentialIssuanceSummaryUseCaseError.unsupportedCredential error")
    } catch {
      XCTAssertEqual(error as? GetCredentialIssuanceSummaryUseCaseError, .unsupportedCredential)
    }
  }

  func testExecute_repositoryThrowsOtherError_throwsError() async {
    repositorySpy.getIssuanceSummaryIdThrowableError = TestingError.error

    do {
      _ = try await useCase(for: credentialId)
      XCTFail("Expecting TestingError.error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let credentialId = UUID()
  private let summary = CredentialIssuanceSummary(issuedAt: Date(timeIntervalSince1970: 1_234_567), available: 2, total: 3)

  private var repositorySpy: CredentialRepositoryProtocolSpy!
  private var useCase: GetCredentialIssuanceSummaryUseCase!
}
