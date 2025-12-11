import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class GetCredentialListUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.credentialRepository.register { self.credentialRepository }

    useCase = GetCredentialListUseCase()
  }

  func testExecuteSucces() async throws {
    credentialRepository.getAllReturnValue = mockCredentials

    let credentials = try await useCase.execute()

    XCTAssertEqual(credentials.count, mockCredentials.count)
    XCTAssertTrue(credentialRepository.getAllCalled)
  }

  func testExecuteWithRepositoryError() async throws {
    credentialRepository.getAllThrowableError = TestingError.error

    do {
      _ = try await useCase.execute()
    } catch {
      XCTAssertTrue(credentialRepository.getAllCalled)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: GetCredentialListUseCase!
  private var mockCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.sampleDisplaysAdditional, .Mock.diploma]
  private var credentialRepository = CredentialRepositoryProcotolSpy()
  // swiftlint:enable all

}
