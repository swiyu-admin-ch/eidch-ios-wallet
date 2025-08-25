import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class UpdateEIDRequestCaseStatusUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }

    registerMocks()
    useCase = UpdateEIDRequestCaseStatusUseCase()
    createSuccessState()
  }

  func testExecute_MultipleRequestsOrdering_Succes() async throws {
    Container.shared.requestCasePriorityOrder.register { [.readyForOnlineSession, .inQueue] }
    var fetchCount = 0
    eIDRequestRepository.fetchRequestStatusForClosure = { _ in
      if fetchCount == 1 {
        return EIDRequestStatus.Mock.readyForAVSample
      }
      fetchCount += 1

      return EIDRequestStatus.Mock.inQueueSample
    }

    var updateCount = 0
    eIDRequestCaseRepository.updateClosure = { _ in
      if updateCount == 1 {
        return .Mock.sampleAVReady
      }
      updateCount += 1

      return .Mock.sampleInQueue
    }

    var getCount = 0
    eIDRequestCaseRepository.getIdClosure = { _ in
      if getCount == 1 {
        return .Mock.sampleAVReady
      }
      getCount += 1

      return .Mock.sampleInQueue
    }

    let sortedArray: [EIDRequestCase] = [
      .Mock.sampleAVReady,
      .Mock.sampleInQueue,
    ]

    let updateRequestCases = try await useCase.execute(mockEIDRequestCases.map(\.id))

    XCTAssertEqual(updateRequestCases, sortedArray)
    XCTAssertEqual(updateRequestCases.count, mockEIDRequestCases.count)
  }

  func testExecute_assertParameters_success() async throws {
    let result = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(result.state, mockEIDRequestCase.state)
    XCTAssertEqual(eIDRequestRepository.fetchRequestStatusForReceivedCaseId, mockEIDRequestCaseInQueue.id)
    XCTAssertEqual(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.state?.state, mockStatus.state)
    XCTAssertEqual(eIDRequestCaseRepository.getIdReceivedId, mockEIDRequestCaseInQueue.id)
  }

  func testExecute_assertCount_success() async throws {
    _ = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(eIDRequestRepository.fetchRequestStatusForCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.updateCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.getIdCallsCount, 1)
  }

  func testExecute_getRequestCaseThrowsError_throwsError() async throws {
    eIDRequestCaseRepository.getIdThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchStatusFails_throwsError() async throws {
    eIDRequestRepository.fetchRequestStatusForThrowableError = TestingError.error

    let result = try await useCase.execute(for: mockEIDRequestCase.id)

    XCTAssertEqual(mockEIDRequestCase, result)
  }

  func testExecute_updateRequestCaseFails_throwsError() async throws {
    eIDRequestCaseRepository.updateThrowableError = TestingError.error

    let result = try await useCase.execute(for: mockEIDRequestCase.id)

    XCTAssertEqual(mockEIDRequestCase, result)
  }

  // MARK: Private

  private var useCase: UpdateEIDRequestCaseStatusUseCase!

  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!
  private var eIDRequestRepository: EIDRequestRepositoryProtocolSpy!

  private let mockStatus = EIDRequestStatus.Mock.readyForAVSample
  private let mockEIDRequestCaseInQueue: EIDRequestCase = .Mock.sampleInQueue
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleAVReady
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleWithoutState]

  private func registerMocks() {
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }
  }

  private func createSuccessState() {
    eIDRequestCaseRepository.updateReturnValue = mockEIDRequestCase
    eIDRequestCaseRepository.getIdReturnValue = mockEIDRequestCase
    eIDRequestRepository.fetchRequestStatusForReturnValue = mockStatus
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
