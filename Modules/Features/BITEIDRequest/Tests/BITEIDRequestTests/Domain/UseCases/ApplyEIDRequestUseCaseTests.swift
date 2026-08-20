import Factory
import Spyable
import XCTest
@testable import BITAppAttestation
@testable import BITCore
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class ApplyEIDRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = ApplyEIDRequestUseCase()
    createSuccessState()
  }

  func testExecute_parameters_success() async throws {
    let result = try await useCase(scanDocumentOutput: scanDocumentOutput, hasLegalRepresentant: false)

    XCTAssertEqual(sidRepository.applyWithReceivedBody, mockPayload)
    XCTAssertEqual(sidRepository.fetchRequestStatusForReceivedCaseId, mockEIDRequestResponse.caseId)
    XCTAssertEqual(eIDRequestCaseRepository.createEIDRequestCaseReceivedEIDRequestCase?.id, mockEIDRequestResponse.caseId)
    XCTAssertNotNil(eIDRequestCaseRepository.createEIDRequestCaseReceivedEIDRequestCase?.state)
    XCTAssertEqual(eIDRequestCaseRepository.saveFilesForRequestCaseIdReceivedArguments?.files.count, scanDocumentOutput.files.count)
    XCTAssertEqual(eIDRequestCaseRepository.saveFilesForRequestCaseIdReceivedArguments?.id, mockEIDRequestCase.id)
    XCTAssertEqual(result, mockEIDRequestCase)
  }

  func testExecute_count_success() async throws {
    _ = try await useCase(scanDocumentOutput: scanDocumentOutput, hasLegalRepresentant: false)

    XCTAssertEqual(sidRepository.applyWithCallsCount, 1)
    XCTAssertEqual(sidRepository.fetchRequestStatusForCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.createEIDRequestCaseCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.saveFilesForRequestCaseIdCallsCount, 1)
  }

  func testExecute_applyFails_throwsError() async throws {
    sidRepository.applyWithThrowableError = TestingError.error

    do {
      _ = try await useCase(scanDocumentOutput: scanDocumentOutput, hasLegalRepresentant: false)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchRequestStatusThrowsError_returnsNil() async throws {
    sidRepository.fetchRequestStatusForThrowableError = TestingError.error

    let result = try await useCase(scanDocumentOutput: scanDocumentOutput, hasLegalRepresentant: false)

    XCTAssertEqual(result.id, mockEIDRequestResponse.caseId)
    XCTAssertEqual(result.lastName, mockEIDRequestResponse.lastName)
    XCTAssertEqual(result.firstName, mockEIDRequestResponse.firstName)
    XCTAssertEqual(result.documentNumber, mockEIDRequestResponse.identityNumber)
  }

  func testExecute_saveRequestCase_throwsError() async throws {
    eIDRequestCaseRepository.createEIDRequestCaseThrowableError = TestingError.error

    do {
      _ = try await useCase(scanDocumentOutput: scanDocumentOutput, hasLegalRepresentant: false)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_saveFilesFails_throwsError() async throws {
    eIDRequestCaseRepository.saveFilesForRequestCaseIdThrowableError = TestingError.error

    do {
      _ = try await useCase(scanDocumentOutput: scanDocumentOutput, hasLegalRepresentant: false)
    } catch {
      XCTAssertTrue(sidRepository.applyWithCalled)
      XCTAssertTrue(eIDRequestCaseRepository.createEIDRequestCaseCalled)
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: ApplyEIDRequestUseCase!

  private let mockPayload = MRZData.Mock.array.first!.payload
  private let mockEIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockEIDRequestStatus: EIDRequestStatus = .Mock.inQueueSample
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleWithoutState
  private let mockEIDRequestCaseWithoutState: EIDRequestCase = .Mock.sampleWithoutState

  private var sidRepository: SIDRepositoryProtocolSpy!
  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!

  private var scanDocumentOutput: ScanDocumentOutput {
    let mrz = try! MRZ(values: MRZ.Mock.sampleValues)
    let files = EIDRequestCaseFile.Mock.sampleArray
    return ScanDocumentOutput(mrz: mrz, files: files, identityType: .identityCard)
  }

  private func registerMocks() {
    sidRepository = SIDRepositoryProtocolSpy()
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()

    Container.shared.sidRepository.register { self.sidRepository }
    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
  }

  private func createSuccessState() {
    sidRepository.applyWithReturnValue = mockEIDRequestResponse
    sidRepository.fetchRequestStatusForReturnValue = mockEIDRequestStatus
    eIDRequestCaseRepository.createEIDRequestCaseReturnValue = mockEIDRequestCase
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
