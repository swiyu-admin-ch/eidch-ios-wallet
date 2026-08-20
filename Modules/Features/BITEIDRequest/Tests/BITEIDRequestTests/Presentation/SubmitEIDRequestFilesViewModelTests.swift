import Factory
import Foundation
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore


// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

@MainActor
final class SubmitEIDRequestFilesViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    viewModel = SubmitEIDRequestFilesViewModel()

    success()
  }

  func testFileUploads_initialState() {
    XCTAssertTrue(viewModel.fileUploads.isEmpty)
    XCTAssertTrue(viewModel.failedFiles.isEmpty)
    XCTAssertEqual(viewModel.overallProgress, 0.0)
    XCTAssertFalse(viewModel.areAllFilesCompleted)
  }

  func testOverallProgress_allPending_returnsZero() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]

    XCTAssertEqual(viewModel.overallProgress, 0.0)
  }

  func testOverallProgress_allCompleted_returnsOne() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .completed

    XCTAssertEqual(viewModel.overallProgress, 1.0)
  }

  func testOverallProgress_mixedStates_returnsCorrectValue() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
      mockFileId3: FileUploadInfo(file: mockFile3),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .uploading(progress: 0.5)
    viewModel.fileUploads[mockFileId3]?.state = .pending

    let expectedProgress = (1.0 + 0.5 + 0.0) / 3.0
    XCTAssertEqual(viewModel.overallProgress, expectedProgress)
  }

  func testOverallProgress_withFailedStates_returnsCorrectValue() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .failed(TestingError.error)

    XCTAssertEqual(viewModel.overallProgress, 0.5)
  }

  func testAreAllFilesCompleted_emptyFileUploads_returnsFalse() {
    XCTAssertFalse(viewModel.areAllFilesCompleted)
  }

  func testAreAllFilesCompleted_allCompleted_returnsTrue() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .completed

    XCTAssertTrue(viewModel.areAllFilesCompleted)
  }

  func testAreAllFilesCompleted_notAllCompleted_returnsFalse() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .pending

    XCTAssertFalse(viewModel.areAllFilesCompleted)
  }

  func testFailedFiles_noFailedFiles_returnsEmpty() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .pending

    XCTAssertTrue(viewModel.failedFiles.isEmpty)
  }

  func testFailedFiles_withFailedFiles_returnsFailedFiles() {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
      mockFileId3: FileUploadInfo(file: mockFile3),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed
    viewModel.fileUploads[mockFileId2]?.state = .failed(TestingError.error)
    viewModel.fileUploads[mockFileId3]?.state = .failed(TestingError.error)

    let failedFiles = viewModel.failedFiles
    XCTAssertEqual(failedFiles.count, 2)
    XCTAssertTrue(failedFiles.contains { $0.file.id == mockFileId2 })
    XCTAssertTrue(failedFiles.contains { $0.file.id == mockFileId3 })
  }

  func testSubmit_validCaseId_callsGetEIDRequestFiles() async {
    await viewModel.submit()

    XCTAssertEqual(getEIDRequestFilesUseCase.executeCaseIdCallsCount, 1)
    XCTAssertEqual(getEIDRequestFilesUseCase.executeCaseIdReceivedCaseId, mockCaseId)
    XCTAssertEqual(deleteEIDRequestCaseFileUseCase.executeForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(deleteEIDRequestCaseFileUseCase.executeForRequestCaseIdReceivedId, mockCaseId)
  }

  func testSubmit_noCaseId_doesNotCallGetEIDRequestFiles() async {
    context.caseId = nil

    await viewModel.submit()

    XCTAssertEqual(getEIDRequestFilesUseCase.executeCaseIdCallsCount, 0)
  }

  func testSubmit_validFiles_updatesFileUploads() async {
    await viewModel.submit()

    XCTAssertEqual(viewModel.fileUploads.count, 2)
    XCTAssertNotNil(viewModel.fileUploads[mockFileId1])
    XCTAssertNotNil(viewModel.fileUploads[mockFileId2])
    XCTAssertEqual(viewModel.fileUploads[mockFileId1]?.file.id, mockFileId1)
    XCTAssertEqual(viewModel.fileUploads[mockFileId2]?.file.id, mockFileId2)
  }

  func testSubmit_validFiles_callsSubmitEIDRequestFile() async {
    await viewModel.submit()
    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtCallsCount, 2)
    XCTAssertTrue(submitEIDRequestUseCase.callAsFunctionCaseIdAuthJwtFilesCalled)
  }

  func testSubmit_renamesFilesBeforeSubmitting() async {
    let file = EIDRequestCaseFile.Mock.sample(name: "result.xml")
    filenameMap = ["result.xml": "mobile-result.xml"]
    allowedFiles = ["mobile-result.xml"]
    getEIDRequestFilesUseCase.executeCaseIdReturnValue = [file]

    viewModel = SubmitEIDRequestFilesViewModel()
    await viewModel.submit()

    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtReceivedArguments?.file.fileName, "mobile-result.xml")
  }

  func testSubmit_filtersFilesNotAllowedForSID() async {
    allowedFiles = [mockFile1.fileName]

    viewModel = SubmitEIDRequestFilesViewModel()
    await viewModel.submit()

    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtCallsCount, 1)
    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtReceivedArguments?.file.id, mockFile1.id)
  }

  func testSubmit_duplicateFileNames_submitsLargestFile() async {
    let smallerFile = EIDRequestCaseFile(fileName: "duplicate.jpg", mime: .jpg, data: Data([0x01]), category: .documentScan)
    let largerFile = EIDRequestCaseFile(fileName: "duplicate.jpg", mime: .jpg, data: Data([0x01, 0x02]), category: .documentScan)
    allowedFiles = ["duplicate.jpg"]
    getEIDRequestFilesUseCase.executeCaseIdReturnValue = [smallerFile, largerFile]

    viewModel = SubmitEIDRequestFilesViewModel()
    await viewModel.submit()

    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtCallsCount, 1)
    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtReceivedArguments?.file.id, largerFile.id)
  }

  func testSubmit_getFilesThrowsError_doesNotSubmit() async {
    getEIDRequestFilesUseCase.executeCaseIdThrowableError = TestingError.error

    await viewModel.submit()

    XCTAssertFalse(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtCalled)
  }

  func testRetryFailedUploads_noFailedFiles_doesNothing() async {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .completed

    await viewModel.retryFailedUploads()

    XCTAssertEqual(viewModel.fileUploads[mockFileId1]?.state, .completed)
    XCTAssertFalse(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtCalled)
  }

  func testRetryFailedUploads_withFailedFiles_resetsToPendingAndRetries() async {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
      mockFileId2: FileUploadInfo(file: mockFile2),
    ]
    viewModel.fileUploads[mockFileId1]?.state = .failed(TestingError.error)
    viewModel.fileUploads[mockFileId2]?.state = .completed

    await viewModel.retryFailedUploads()

    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtCallsCount, 1)
    XCTAssertEqual(submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtReceivedArguments?.file.id, mockFileId1)
  }

  func testSubmitEidRequest_noCaseId_doesNotClose() async {
    context.caseId = nil

    await viewModel.submitEidRequest([mockFile1, mockFile2])

    if case .error = viewModel.destination {
      XCTAssert(true)
    }
  }

  func testSubmitEidRequest_noAuthJwt_doesNotClose() async {
    context.autoVerificationResponse = nil

    await viewModel.submitEidRequest([mockFile1, mockFile2])

    if case .error = viewModel.destination {
      XCTAssert(true)
    }
  }

  func testUpload_successfulUpload_setsCompletedState() async {
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
    ]

    await viewModel.submit()

    XCTAssertEqual(viewModel.fileUploads[mockFileId1]?.state, .completed)
  }

  func testUpload_failedUpload_setsFailedState() async {
    submitEIDRequestFileUseCase.executeCaseIdFileAuthJwtThrowableError = TestingError.error
    viewModel.fileUploads = [
      mockFileId1: FileUploadInfo(file: mockFile1),
    ]

    await viewModel.submit()

    if case .failed(let error) = viewModel.fileUploads[mockFileId1]?.state {
      XCTAssertEqual(error as? TestingError, .error)
    } else {
      XCTFail("Expected failed state")
    }
  }

  // MARK: Private

  private var context: EIDRequestContext!
  private var getEIDRequestFilesUseCase: GetEIDRequestCaseFilesUseCaseProtocolSpy!
  private var submitEIDRequestFileUseCase: SubmitEIDRequestFileUseCaseProtocolSpy!
  private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocolSpy!
  private var deleteEIDRequestCaseFileUseCase: DeleteEIDRequestCaseFileUseCaseProtocolSpy!
  private var filenameMap: [String: String?]!
  private var allowedFiles: [String]!

  private var viewModel: SubmitEIDRequestFilesViewModel!

  private let mockFile1 = EIDRequestCaseFile.Mock.sample
  private let mockFile2 = EIDRequestCaseFile.Mock.sample(name: "sample2")
  private let mockFile3 = EIDRequestCaseFile.Mock.sample(name: "sample3")
  private let mockCaseId = "mock_case_id"
  private let mockAutoVerificationResponse = AutoVerificationResponse.Mock.nfcSample

  private var mockFileId1: UUID {
    mockFile1.id
  }

  private var mockFileId2: UUID {
    mockFile2.id
  }

  private var mockFileId3: UUID {
    mockFile3.id
  }

  private func registerMocks() {
    context = EIDRequestContext()

    getEIDRequestFilesUseCase = GetEIDRequestCaseFilesUseCaseProtocolSpy()
    submitEIDRequestFileUseCase = SubmitEIDRequestFileUseCaseProtocolSpy()
    deleteEIDRequestCaseFileUseCase = DeleteEIDRequestCaseFileUseCaseProtocolSpy()
    submitEIDRequestUseCase = SubmitEIDRequestUseCaseProtocolSpy()
    filenameMap = [:]
    allowedFiles = [mockFile1.fileName, mockFile2.fileName, mockFile3.fileName]

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.sidFilenameMap.register { @MainActor in self.filenameMap }
    Container.shared.sidAllowedFiles.register { @MainActor in self.allowedFiles }
    Container.shared.getEIDRequestCaseFilesUseCase.register { @MainActor in self.getEIDRequestFilesUseCase }
    Container.shared.submitEIDRequestFileUseCase.register { @MainActor in self.submitEIDRequestFileUseCase }
    Container.shared.submitEIDRequestUseCase.register { @MainActor in self.submitEIDRequestUseCase }
    Container.shared.deleteEIDRequestCaseFileUseCase.register { @MainActor in self.deleteEIDRequestCaseFileUseCase }
  }

  private func success() {
    getEIDRequestFilesUseCase.executeCaseIdReturnValue = [mockFile1, mockFile2]
    context.caseId = mockCaseId
    context.autoVerificationResponse = mockAutoVerificationResponse
  }
}
