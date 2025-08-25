// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

final class FetchEIDRequestCaseUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = FetchEIDRequestCaseUseCase()
  }

  func testExecute_success() async throws {
    let requestCase = EIDRequestCase.Mock.sampleInQueue
    repository.getIdReturnValue = requestCase

    let result = try await useCase.execute(caseId: requestCase.id)

    XCTAssertEqual(repository.getIdCallsCount, 1)
    XCTAssertEqual(repository.getIdReceivedId, requestCase.id)
    XCTAssertEqual(result, requestCase)
  }

  // MARK: Private

  private var useCase: FetchEIDRequestCaseUseCase!
  private var repository: EIDRequestCaseRepositoryProtocolSpy!

  private func registerMocks() {
    repository = EIDRequestCaseRepositoryProtocolSpy()
    Container.shared.eIDRequestCaseRepository.register { self.repository }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
