// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITEIDRequest
@testable import BITTestingCore

final class ValidateAttestationsUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = ValidateAttestationsUseCase()
  }

  func testExecute_success() async throws {
    try await useCase.execute(clientAttestation: mockClientAttestation, keyAttestation: mockKeyAttestation)

    XCTAssertEqual(repository.validateAttestationsCallsCount, 1)
    XCTAssertEqual(repository.validateAttestationsReceivedRequestBody?.clientAttestation, mockClientAttestation.rawJWS)
    XCTAssertEqual(repository.validateAttestationsReceivedRequestBody?.keyAttestation, mockKeyAttestation.rawJWS)
  }

  // MARK: Private

  private var useCase: ValidateAttestationsUseCase!

  private let mockKeyAttestation = KeyAttestationJWT.Mock.sample
  private let mockClientAttestation = ClientAttestationJWT.Mock.sample

  private var repository: SIDRepositoryProtocolSpy!

  private func registerMocks() {
    repository = SIDRepositoryProtocolSpy()
    Container.shared.sidRepository.register { self.repository }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
