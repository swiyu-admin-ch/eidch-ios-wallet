import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_try

final class UpdateEIDRequestCaseFilesUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = EIDRequestCaseRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.repository }

    useCase = UpdateEIDRequestCaseFilesUseCase()
  }

  func testExecute_success() async throws {
    try await useCase(for: mockCaseId, scanDocumentOutput: mockScanDocumentOutput)

    XCTAssertEqual(repository.deleteAllFilesForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(repository.deleteAllFilesForRequestCaseIdReceivedId, mockCaseId)

    XCTAssertEqual(repository.saveFilesForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(repository.saveFilesForRequestCaseIdReceivedArguments?.id, mockCaseId)
    XCTAssertEqual(repository.saveFilesForRequestCaseIdReceivedArguments?.files, mockScanDocumentOutput.files)
  }

  func testExecute_deleteFilesFails_throws() async throws {
    repository.deleteAllFilesForRequestCaseIdThrowableError = TestingError.error

    do {
      try await useCase(for: mockCaseId, scanDocumentOutput: mockScanDocumentOutput)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertFalse(repository.deleteCalled)
    }
  }

  func testExecute_saveFilesFails_throws() async throws {
    repository.saveFilesForRequestCaseIdThrowableError = TestingError.error

    do {
      _ = try await useCase(for: mockCaseId, scanDocumentOutput: mockScanDocumentOutput)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var useCase: UpdateEIDRequestCaseFilesUseCase!
  private let mockCaseId = "caseId"
  private var repository: EIDRequestCaseRepositoryProtocolSpy!

  private var mockScanDocumentOutput: ScanDocumentOutput {
    let mrz = try! MRZ(values: MRZ.Mock.sampleValues)
    let files = EIDRequestCaseFile.Mock.sampleArray
    return ScanDocumentOutput(mrz: mrz, files: files, identityType: .identityCard)
  }
}
