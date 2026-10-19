import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class UpdateEIDRequestCaseStatusUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.eIDRequestCaseRepository = eIDRequestCaseRepository
    let sidRepository = SIDRepositoryProtocolSpy()
    self.sidRepository = sidRepository

    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }
    Container.shared.sidRepository.register { sidRepository }

    registerMocks()
    useCase = UpdateEIDRequestCaseStatusUseCase()
    createSuccessState()
  }

  func testExecute_assertParameters_success() async throws {
    let result = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(result.state, mockEIDRequestCase.state)
    XCTAssertEqual(sidRepository.fetchRequestStatusForReceivedCaseId, mockEIDRequestCaseInQueue.id)
    XCTAssertEqual(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.state?.state, mockStatus.state)
    XCTAssertEqual(eIDRequestCaseRepository.getIdReceivedId, mockEIDRequestCaseInQueue.id)
  }

  func testExecute_assertCount_success() async throws {
    _ = try await useCase.execute(for: mockEIDRequestCaseInQueue.id)

    XCTAssertEqual(sidRepository.fetchRequestStatusForCallsCount, 1)
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
    sidRepository.fetchRequestStatusForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockEIDRequestCase.id)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_updateRequestCaseFails_throwsError() async throws {
    eIDRequestCaseRepository.updateThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockEIDRequestCase.id)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: UpdateEIDRequestCaseStatusUseCase!

  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!
  private var sidRepository: SIDRepositoryProtocolSpy!

  private let mockStatus = EIDRequestStatus.Mock.readyForAVSample
  private let mockEIDRequestCaseInQueue: EIDRequestCase = .Mock.sampleInQueue
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleAVReady
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleWithoutState]

  private func registerMocks() {
    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.eIDRequestCaseRepository = eIDRequestCaseRepository
    let sidRepository = SIDRepositoryProtocolSpy()
    self.sidRepository = sidRepository

    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }
    Container.shared.sidRepository.register { sidRepository }
  }

  private func createSuccessState() {
    eIDRequestCaseRepository.updateReturnValue = mockEIDRequestCase
    eIDRequestCaseRepository.getIdReturnValue = mockEIDRequestCase
    sidRepository.fetchRequestStatusForReturnValue = mockStatus
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
