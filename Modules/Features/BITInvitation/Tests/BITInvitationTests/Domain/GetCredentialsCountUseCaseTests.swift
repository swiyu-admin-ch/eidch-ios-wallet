import Factory
import Spyable
import XCTest
@testable import BITCredential
@testable import BITInvitation
@testable import BITTestingCore

final class GetCredentialsCountUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    verifiableCredentialRepository = VerifiableCredentialRepositoryProcotolSpy()

    Container.shared.verifiableCredentialRepository.register { self.verifiableCredentialRepository }
    useCase = GetCredentialsCountUseCase()
  }

  func testExecuteTrue_Success() async throws {
    verifiableCredentialRepository.countReturnValue = 1

    let count = try await useCase.execute()

    XCTAssertTrue(verifiableCredentialRepository.countCalled)
    XCTAssertEqual(count, 1)
  }

  func testExecuteFalse_Success() async throws {
    verifiableCredentialRepository.countReturnValue = 0

    let count = try await useCase.execute()

    XCTAssertTrue(verifiableCredentialRepository.countCalled)
    XCTAssertEqual(count, 0)
  }

  // MARK: Private

  // swiftlint: disable all
  private var verifiableCredentialRepository: VerifiableCredentialRepositoryProcotolSpy!
  private var useCase: GetCredentialsCountUseCase!
  // swiftlint: enable all

}
