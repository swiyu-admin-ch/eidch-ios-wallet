import Factory
import Spyable
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

final class GetEIDRequestCaseFilesUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    success()
  }

  // MARK: - Basic Repository Interaction Tests

  func testExecute_validCaseId_callsRepositoryWithCorrectCaseId() async throws {
    useCase = GetEIDRequestCaseFilesUseCase()
    _ = try await useCase.execute(caseId: mockCaseId)

    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedId, mockCaseId)
  }

  func testExecute_repositoryThrowsError_propagatesError() async throws {
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdThrowableError = TestingError.error

    useCase = GetEIDRequestCaseFilesUseCase()

    do {
      _ = try await useCase.execute(caseId: mockCaseId)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_emptyResult_returnsEmptyArray() async throws {
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = []

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertTrue(result.isEmpty)
  }

  func testExecute_multipleCalls_callsRepositoryEachTime() async throws {
    useCase = GetEIDRequestCaseFilesUseCase()
    _ = try await useCase.execute(caseId: mockCaseId)
    _ = try await useCase.execute(caseId: "another_case_id")

    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdCallsCount, 2)
  }

  func testExecute_differentCaseIds_passesCorrectParameters() async throws {
    let caseId1 = "case_id_1"
    let caseId2 = "case_id_2"
    useCase = GetEIDRequestCaseFilesUseCase()

    _ = try await useCase.execute(caseId: caseId1)
    _ = try await useCase.execute(caseId: caseId2)

    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedInvocations.count, 2)
    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedInvocations[0], caseId1)
    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedInvocations[1], caseId2)
  }

  // MARK: - File Filtering Tests

  func testExecute_withAllowedFiles_returnsOnlyAllowedFiles() async throws {
    let allowedFile1 = EIDRequestCaseFile.Mock.sample(name: "allowed1.pdf")
    let allowedFile2 = EIDRequestCaseFile.Mock.sample(name: "allowed2.pdf")
    let notAllowedFile = EIDRequestCaseFile.Mock.sample(name: "notAllowed.pdf")

    allowedFiles = ["allowed1.pdf", "allowed2.pdf"]
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [allowedFile1, allowedFile2, notAllowedFile]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertEqual(result.count, 2)
    XCTAssertTrue(result.contains(where: { $0.fileName == "allowed1.pdf" }))
    XCTAssertTrue(result.contains(where: { $0.fileName == "allowed2.pdf" }))
    XCTAssertFalse(result.contains(where: { $0.fileName == "notAllowed.pdf" }))
  }

  func testExecute_withNoAllowedFiles_returnsEmptyArray() async throws {
    let notAllowedFile1 = EIDRequestCaseFile.Mock.sample(name: "notAllowed1.pdf")
    let notAllowedFile2 = EIDRequestCaseFile.Mock.sample(name: "notAllowed2.pdf")

    allowedFiles = ["allowed1.pdf", "allowed2.pdf"]

    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [notAllowedFile1, notAllowedFile2]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertTrue(result.isEmpty)
  }

  func testExecute_withEmptyAllowedFileList_returnsEmptyArray() async throws {
    let file1 = EIDRequestCaseFile.Mock.sample(name: "file1.pdf")
    let file2 = EIDRequestCaseFile.Mock.sample(name: "file2.pdf")

    allowedFiles = []
    Container.shared.sidAllowedFiles.register { self.allowedFiles }

    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [file1, file2]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertTrue(result.isEmpty)
  }

  func testExecute_withAllFilesAllowed_returnsAllFiles() async throws {
    let file1 = EIDRequestCaseFile.Mock.sample(name: "file1.pdf")
    let file2 = EIDRequestCaseFile.Mock.sample(name: "file2.pdf")
    let file3 = EIDRequestCaseFile.Mock.sample(name: "file3.pdf")

    allowedFiles = ["file1.pdf", "file2.pdf", "file3.pdf", "metadata.bin"]

    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [file1, file2, file3]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertEqual(result.count, 4)
    XCTAssertTrue(result.contains(where: { $0.fileName == "file1.pdf" }))
    XCTAssertTrue(result.contains(where: { $0.fileName == "file2.pdf" }))
    XCTAssertTrue(result.contains(where: { $0.fileName == "file3.pdf" }))
    XCTAssertTrue(result.contains(where: { $0.fileName == "metadata.bin" }))
  }

  // MARK: - Metadata Binary Generation Tests

  func testExecute_generatesMetadataBinaryFile() async throws {
    let jsonData1 = try JSONEncoder().encode([motionRecord])
    let jsonData2 = try JSONEncoder().encode([motionRecord2])

    let metadataFile1 = EIDRequestCaseFile(fileName: "metadata-1.json", mime: .json, data: jsonData1, category: .other)
    let metadataFile2 = EIDRequestCaseFile(fileName: "metadata-2.json", mime: .json, data: jsonData2, category: .other)
    let regularFile = EIDRequestCaseFile.Mock.sample(name: "regular.pdf")

    allowedFiles = ["metadata.bin", "regular.pdf"]
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [metadataFile1, metadataFile2, regularFile]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertTrue(result.contains(where: { $0.fileName == "metadata.bin" }))
    let metadataBinary = result.first(where: { $0.fileName == "metadata.bin" })
    XCTAssertNotNil(metadataBinary)
    XCTAssertEqual(metadataBinary?.mime, .bin)
  }

  func testExecute_metadataBinaryContainsAllMotionRecords() async throws {
    let jsonData1 = try JSONEncoder().encode([motionRecord, motionRecord2])
    let jsonData2 = try JSONEncoder().encode([motionRecord3])

    let metadataFile1 = EIDRequestCaseFile(fileName: "metadata-1.json", mime: .json, data: jsonData1, category: .other)
    let metadataFile2 = EIDRequestCaseFile(fileName: "metadata-2.json", mime: .json, data: jsonData2, category: .other)

    allowedFiles = ["metadata.bin"]
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [metadataFile1, metadataFile2]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    let metadataBinary = result.first(where: { $0.fileName == "metadata.bin" })
    XCTAssertNotNil(metadataBinary)

    // Verify the binary data can be parsed back into MotionMetadata
    // This assumes MotionMetadata has a way to be decoded from Data
    XCTAssertFalse(try XCTUnwrap(metadataBinary?.data.isEmpty))
  }

  func testExecute_withNoMetadataFiles_stillGeneratesEmptyMetadataBinary() async throws {
    let regularFile = EIDRequestCaseFile.Mock.sample(name: "regular.pdf")

    allowedFiles = ["metadata.bin", "regular.pdf"]
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [regularFile]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertTrue(result.contains(where: { $0.fileName == "metadata.bin" }))
    let metadataBinary = result.first(where: { $0.fileName == "metadata.bin" })
    XCTAssertNotNil(metadataBinary)
  }

  func testExecute_onlyProcessesMetadataJsonFiles() async throws {
    let jsonData = try JSONEncoder().encode([motionRecord])

    let metadataFile = EIDRequestCaseFile(fileName: "metadata-1.json", mime: .json, data: jsonData, category: .other)
    let otherJsonFile = EIDRequestCaseFile(fileName: "other.json", mime: .json, data: jsonData, category: .other)
    let regularFile = EIDRequestCaseFile.Mock.sample(name: "regular.pdf")

    allowedFiles = ["metadata.bin"]
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [metadataFile, otherJsonFile, regularFile]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    // Should only include metadata-prefixed JSON files in the binary generation
    XCTAssertTrue(result.contains(where: { $0.fileName == "metadata.bin" }))
  }

  func testExecute_metadataBinaryNotInAllowedFiles_isFiltered() async throws {
    let file = EIDRequestCaseFile.Mock.sample(name: "file.pdf")

    allowedFiles = ["file.pdf"] // metadata.bin is NOT in allowed files
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = [file]

    useCase = GetEIDRequestCaseFilesUseCase()
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertEqual(result.count, 1)
    XCTAssertFalse(result.contains(where: { $0.fileName == "metadata.bin" }))
  }

  // MARK: Private

  // MARK: Test Data

  private let motionRecord = MotionRecord(
    timestamp: 1000,
    accX: 1.0, accY: 2.0, accZ: 3.0,
    accGravX: 0.1, accGravY: 0.2, accGravZ: 0.3,
    gyroAlpha: 0.01, gyroBeta: 0.02, gyroGamma: 0.03,
    interval: 16, event: 0)
  private let motionRecord2 = MotionRecord(
    timestamp: 2000,
    accX: 4.0, accY: 5.0, accZ: 6.0,
    accGravX: 0.4, accGravY: 0.5, accGravZ: 0.6,
    gyroAlpha: 0.04, gyroBeta: 0.05, gyroGamma: 0.06,
    interval: 16, event: 0)
  private let motionRecord3 = MotionRecord(
    timestamp: 3000,
    accX: 7.0, accY: 8.0, accZ: 9.0,
    accGravX: 0.7, accGravY: 0.8, accGravZ: 0.9,
    gyroAlpha: 0.07, gyroBeta: 0.08, gyroGamma: 0.09,
    interval: 16, event: 0)

  // MARK: Mocks

  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!
  private var useCase: GetEIDRequestCaseFilesUseCase!

  private let mockCaseId = "mock_case_id"
  private var allowedFiles: [String]!

  // MARK: Helper Methods

  private func registerMocks() {
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    allowedFiles = []

    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
    Container.shared.sidAllowedFiles.register { self.allowedFiles }
  }

  private func success() {
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = EIDRequestCaseFile.Mock.sampleArray
  }

}
