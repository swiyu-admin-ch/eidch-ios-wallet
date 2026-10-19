import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

final class GetEIDRequestCaseListUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    let repository = EIDRequestCaseRepositoryProtocolSpy()
    self.repository = repository

    Container.shared.eIDRequestCaseRepository.register { repository }
  }

  func testExecuteSucces() async throws {
    Container.shared.requestCasePriorityOrder.register { [.autoVerification, .issuing, .closed, .readyForOnlineSession, .inTargetWalletPairing, .readyForFinalEntitlementCheck, .inQueue, .refused, .unknown, .expired, .cancelled, .agentReview] }
    repository.getAllReturnValue = mockEIDRequestCases
    useCase = GetEIDRequestCaseListUseCase()

    let sortedArray: [EIDRequestCase] = [
      .Mock.sampleAVReady,
      .Mock.sampleInQueue,
      .Mock.sampleInQueueNoOnlineSessionStart,
      .Mock.sampleWithoutState,
      .Mock.sampleCancelled,
    ]

    let requestCases = try await useCase()

    XCTAssertEqual(requestCases, sortedArray)
  }

  func testExecuteSucces_withoutPriorities() async throws {
    Container.shared.requestCasePriorityOrder.register { [] }
    repository.getAllReturnValue = mockEIDRequestCases
    useCase = GetEIDRequestCaseListUseCase()

    let requestCases = try await useCase()

    XCTAssertEqual(requestCases.count, mockEIDRequestCases.count)
  }

  func testExecuteWithRepositoryError() async throws {
    repository.getAllThrowableError = TestingError.error
    useCase = GetEIDRequestCaseListUseCase()

    do {
      _ = try await useCase()
      XCTFail("An error was expected")
    } catch {
      XCTAssertTrue(repository.getAllCalled)
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: GetEIDRequestCaseListUseCase!
  private var mockEIDRequestCases: [EIDRequestCase] = [
    .Mock.sampleAVReady,
    .Mock.sampleInQueue,
    .Mock.sampleInQueueNoOnlineSessionStart,
    .Mock.sampleWithoutState,
    .Mock.sampleCancelled,
  ]
  private var repository: EIDRequestCaseRepositoryProtocolSpy!
  // swiftlint:enable all

}
