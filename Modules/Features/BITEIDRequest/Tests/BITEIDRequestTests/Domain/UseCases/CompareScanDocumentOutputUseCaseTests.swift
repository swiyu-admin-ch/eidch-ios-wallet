import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_try

final class CompareScanDocumentOutputUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    useCase = CompareScanDocumentOutputUseCase()
    success()
  }

  func testCallAsFunction_success_returnsTrue() async {
    let result = await useCase(for: mockCaseId, with: mockScanDocumentOutput)

    XCTAssertTrue(result)
    XCTAssertEqual(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.id, mockCaseId)
    XCTAssertEqual(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.category, .documentScan)
    XCTAssertEqual(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name, "mobile-result.json")
  }

  func testCallAsFunction_getRequestCaseFileFails_returnsFalse() async {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryThrowableError = TestingError.error

    let result = await useCase(for: mockCaseId, with: mockScanDocumentOutput)

    XCTAssertFalse(result)
  }

  func testCallAsFunction_getRequestCaseFilesReturnsDocumentWithWrongData_returnsFalse() async throws {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReturnValue = try EIDRequestCaseFile(
      fileName: "mobile-result.json",
      mime: .json,
      data: JSONEncoder().encode(wrongExtractedData),
      category: .documentScan)

    let result = await useCase(for: mockCaseId, with: mockScanDocumentOutput)

    XCTAssertFalse(result)
  }

  // MARK: Private

  private var useCase: CompareScanDocumentOutputUseCase!
  private let mockCaseId = "caseId"
  private var mockScanDocumentOutput: ScanDocumentOutput!
  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!
  private var extractedDataData: Data!
  private let extractedData = ScanDocumentOutput.ExtractedData(
    steps: [
      ScanDocumentOutput.ExtractedData.Step(
        summary: ScanDocumentOutput.ExtractedData.Step.Summary(
          documentNumber: "123456789")),
    ])

  private let wrongExtractedData = ScanDocumentOutput.ExtractedData(
    steps: [
      ScanDocumentOutput.ExtractedData.Step(
        summary: ScanDocumentOutput.ExtractedData.Step.Summary(
          documentNumber: "987654321")),
    ])

  private func registerMocks() {
    mockScanDocumentOutput = ScanDocumentOutput(
      mrz: .Mock.sample,
      files: [EIDRequestCaseFile(
        fileName: "result.json",
        mime: .json,
        data: try! JSONEncoder().encode(extractedData),
        category: .documentScan)],
      identityType: .passport)
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
  }

  private func success() {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReturnValue = EIDRequestCaseFile(
      fileName: "mobile-result.json",
      mime: .json,
      data: try! JSONEncoder().encode(extractedData),
      category: .documentScan)
  }
}
