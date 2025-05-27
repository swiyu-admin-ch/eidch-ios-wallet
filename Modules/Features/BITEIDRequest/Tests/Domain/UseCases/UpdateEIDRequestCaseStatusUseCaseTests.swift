import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

final class UpdateEIDRequestCaseStatusUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = LocalEIDRequestRepositoryProtocolSpy()
    remoteRepository = EIDRequestRepositoryProtocolSpy()

    Container.shared.localEIDRequestRepository.register { self.repository }
    Container.shared.eIDRequestRepository.register { self.remoteRepository }

    useCase = UpdateEIDRequestCaseStatusUseCase()
  }

  func testExecute_MultipleRequestsOrdering_Succes() async throws {
    Container.shared.requestCasePriorityOrder.register { [.readyForOnlineSession, .inQueue] }
    var fetchCount = 0
    remoteRepository.fetchRequestStatusForClosure = { _ in
      if fetchCount == 1 {
        return EIDRequestStatus.Mock.readyForAVSample
      }
      fetchCount += 1

      return EIDRequestStatus.Mock.inQueueSample
    }

    var updateCount = 0
    repository.updateClosure = { _ in
      if updateCount == 1 {
        return .Mock.sampleAVReady
      }
      updateCount += 1

      return .Mock.sampleInQueue
    }

    var getCount = 0
    repository.getIdClosure = { _ in
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

  func testExecuteSucces() async throws {
    let mockEIDRequestCase: EIDRequestCase = .Mock.sampleAVReady
    let mockStatus = EIDRequestStatus.Mock.readyForAVSample

    remoteRepository.fetchRequestStatusForReturnValue = mockStatus
    repository.updateReturnValue = mockEIDRequestCase
    repository.getIdReturnValue = mockEIDRequestCase

    let result = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(result.state, mockEIDRequestCase.state)
    XCTAssertEqual(remoteRepository.fetchRequestStatusForReceivedCaseId, mockEIDRequestCaseInQueue.id)
    XCTAssertEqual(repository.updateReceivedEIDRequestCase?.state?.state, mockStatus.state)
    XCTAssertEqual(repository.getIdReceivedId, mockEIDRequestCaseInQueue.id)
  }

  func testExecute_getRequestCaseThrowsError_throwsError() async throws {
    repository.getIdThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecuteWithFetchStatusError() async throws {
    repository.getIdReturnValue = mockEIDRequestCaseInQueue
    remoteRepository.fetchRequestStatusForThrowableError = TestingError.error

    let result = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(remoteRepository.fetchRequestStatusForReceivedCaseId, mockEIDRequestCaseInQueue.id)
    XCTAssertEqual(mockEIDRequestCaseInQueue, result)
  }

  func testExecuteWithUpdateRequestCaseError() async throws {
    let mockStatus = EIDRequestStatus.Mock.readyForAVSample

    repository.getIdReturnValue = mockEIDRequestCaseInQueue
    remoteRepository.fetchRequestStatusForReturnValue = mockStatus
    repository.updateThrowableError = TestingError.error

    let result = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(remoteRepository.fetchRequestStatusForReceivedCaseId, mockEIDRequestCaseInQueue.id)
    XCTAssertEqual(repository.updateReceivedEIDRequestCase?.state?.state, mockStatus.state)
    XCTAssertEqual(mockEIDRequestCaseInQueue, result)
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: UpdateEIDRequestCaseStatusUseCase!
  private let mockEIDRequestCaseInQueue: EIDRequestCase = .Mock.sampleInQueue
  private var repository: LocalEIDRequestRepositoryProtocolSpy!
  private var remoteRepository: EIDRequestRepositoryProtocolSpy!
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleWithoutState]
  // swiftlint:enable all

}
