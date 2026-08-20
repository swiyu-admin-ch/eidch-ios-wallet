import Factory
import Testing
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

struct CompareScanDocumentOutputUseCaseTests {

  // MARK: Lifecycle

  init() throws {
    resultJsonFile = try EIDRequestCaseFile(fileName: "result.json", mime: .json, data: JSONEncoder().encode(extractedData), category: .documentScan)
    mockScanDocumentOutput = ScanDocumentOutput(mrz: .Mock.sample, files: [resultJsonFile], identityType: .passport)

    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReturnValue = resultJsonFile
    self.eIDRequestCaseRepository = eIDRequestCaseRepository

    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }

    useCase = CompareScanDocumentOutputUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success_returnsTrue() async {
    let result = await useCase(for: mockCaseId, with: mockScanDocumentOutput)

    #expect(result == true)
    #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount == 1)
    #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.id == mockCaseId)
    #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.category == .documentScan)
    #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name == "result.json")
  }

  @Test
  func callAsFunction_getRequestCaseFileFails_returnsFalse() async {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryThrowableError = TestingError.error

    let result = await useCase(for: mockCaseId, with: mockScanDocumentOutput)

    #expect(result == false)
  }

  @Test
  func callAsFunction_getRequestCaseFilesReturnsDocumentWithWrongData_returnsFalse() async throws {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReturnValue = try EIDRequestCaseFile(
      fileName: "result.json",
      mime: .json,
      data: JSONEncoder().encode(wrongExtractedData),
      category: .documentScan)

    let result = await useCase(for: mockCaseId, with: mockScanDocumentOutput)

    #expect(result == false)
  }

  // MARK: Private

  private let resultJsonFile: EIDRequestCaseFile
  private var useCase: CompareScanDocumentOutputUseCase
  private let mockCaseId = "caseId"
  private var mockScanDocumentOutput: ScanDocumentOutput
  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
  private let extractedData = ScanDocumentOutput.ExtractedData(
    steps: [
      ScanDocumentOutput.ExtractedData.Step(summary: ScanDocumentOutput.ExtractedData.Step.Summary(documentNumber: "123456789")),
    ])

  private let wrongExtractedData = ScanDocumentOutput.ExtractedData(
    steps: [
      ScanDocumentOutput.ExtractedData.Step(summary: ScanDocumentOutput.ExtractedData.Step.Summary(documentNumber: "987654321")),
    ])
}
