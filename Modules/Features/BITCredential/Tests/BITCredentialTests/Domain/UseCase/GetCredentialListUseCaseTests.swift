import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class GetCredentialListUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.verifiableCredentialRepository.register { self.verifiableCredentialRepository }

    useCase = GetCredentialListUseCase()
  }

  func testExecuteSucces() async throws {
    verifiableCredentialRepository.getAllReturnValue = mockCredentials

    let credentials = try await useCase.execute()

    XCTAssertEqual(credentials.count, mockCredentials.count)
    XCTAssertTrue(verifiableCredentialRepository.getAllCalled)
  }

  func testExecuteWithRepositoryError() async throws {
    verifiableCredentialRepository.getAllThrowableError = TestingError.error

    do {
      _ = try await useCase.execute()
    } catch {
      XCTAssertTrue(verifiableCredentialRepository.getAllCalled)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: GetCredentialListUseCase!
  private var mockCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.sampleDisplaysAdditional, .Mock.diploma]
  private var verifiableCredentialRepository = VerifiableCredentialRepositoryProcotolSpy()
  // swiftlint:enable all

}
