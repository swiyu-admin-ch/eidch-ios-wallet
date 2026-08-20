import Factory
import Spyable
import XCTest
@testable import BITCredential
@testable import BITInvitation
@testable import BITTestingCore

final class GetCredentialsCountUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    credentialRepository = CredentialRepositoryProtocolSpy()

    Container.shared.credentialRepository.register { self.credentialRepository }
    useCase = GetCredentialsCountUseCase()
  }

  func testExecuteTrue_Success() async throws {
    credentialRepository.countReturnValue = 1

    let count = try await useCase()

    XCTAssertTrue(credentialRepository.countCalled)
    XCTAssertEqual(count, 1)
  }

  func testExecuteFalse_Success() async throws {
    credentialRepository.countReturnValue = 0

    let count = try await useCase()

    XCTAssertTrue(credentialRepository.countCalled)
    XCTAssertEqual(count, 0)
  }

  // MARK: Private

  // swiftlint: disable all
  private var credentialRepository: CredentialRepositoryProtocolSpy!
  private var useCase: GetCredentialsCountUseCase!
  // swiftlint: enable all

}
