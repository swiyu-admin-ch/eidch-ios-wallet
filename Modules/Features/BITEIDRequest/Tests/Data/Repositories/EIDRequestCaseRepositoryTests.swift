import Factory
import RealmSwift
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared

// swiftlint:disable implicitly_unwrapped_optional

final class EIDRequestCaseRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    Container.shared.dataStore.reset()
    repository = EIDRequestCaseRepository()
  }

  // MARK: - Metadata

  func testCreateEIDRequestCaseSuccess() async throws {
    let eIDRequestCase = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)
    let savedRequestCase = try await repository.get(id: eIDRequestCase.id)
    XCTAssertEqual(eIDRequestCase, savedRequestCase)
  }

  func testGetAllEIDRequestCaseSuccess() async throws {
    _ = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleAVReady)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleInQueueNoOnlineSessionStart)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleExpired)

    let eIDRequestCases = try await repository.getAll()

    let sortedArray: [EIDRequestCase] = [
      .Mock.sampleInQueueNoOnlineSessionStart,
      .Mock.sampleExpired,
      .Mock.sampleAVReady,
      .Mock.sampleInQueue,
    ]

    XCTAssertEqual(eIDRequestCases, sortedArray)
  }

  func testUpdateEIDRequestCaseSuccess() async throws {
    var eIDRequestCase = try await repository.create(eIDRequestCase: .Mock.sampleAVReady)
    eIDRequestCase.state = mockEIDRequestState

    let updatedRequestCase = try await repository.update(eIDRequestCase)
    let savedRequestCase = try await repository.get(id: eIDRequestCase.id)

    XCTAssertEqual(updatedRequestCase, savedRequestCase)
    XCTAssertEqual(eIDRequestCase, savedRequestCase)
  }

  func testDeleteEIDRequestCaseSuccess() async throws {
    let expired = try await repository.create(eIDRequestCase: .Mock.sampleExpired)

    try await repository.delete(expired.id)

    do {
      _ = try await repository.get(id: expired.id)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? EIDRequestCaseRepositoryError, .notFound)
    }
  }

  func testGetAllFiles_returnsAll() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: EIDRequestCaseFile.Mock.sampleArray, forRequestCaseId: eIDRequest.id)

    let files = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)

    XCTAssertEqual(expectedFiles.count, files.count)
  }

  func testSaveFile() async throws {
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(file: EIDRequestCaseFile.Mock.sample, forRequestCaseId: eIDRequest.id)

    let allFiles = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    XCTAssertEqual(allFiles.count, 1)
  }

  func testSaveMultipleFileAtOnce() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: expectedFiles, forRequestCaseId: eIDRequest.id)

    let allFiles = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    XCTAssertEqual(expectedFiles.count, allFiles.count)
  }

  func testDeleteAllFiles() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: EIDRequestCaseFile.Mock.sampleArray, forRequestCaseId: eIDRequest.id)

    let allFiles = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    XCTAssertEqual(expectedFiles.count, allFiles.count)

    try await repository.deleteAllFiles(forRequestCaseId: eIDRequest.id)

    let files = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    XCTAssertEqual(files.count, 0)
  }

  func testGetFilesByCategory() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: EIDRequestCaseFile.Mock.sampleArray, forRequestCaseId: eIDRequest.id)

    let filteredFiles = try await repository.getFiles(forRequestCaseId: eIDRequest.id, matching: .documentScan)
    XCTAssertEqual(expectedFiles.count, filteredFiles.count)
  }

  func testGetFilesByNameAndCategory() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: expectedFiles, forRequestCaseId: eIDRequest.id)

    let file = try await repository.getFile(forRequestCaseId: eIDRequest.id, name: "sample.jpg", category: .documentScan)

    XCTAssertEqual(file, expectedFiles.first)
  }

  func testGetFilesByNameAndCategory_fileNotExisiting_throwsError() async throws {
    let fileToSave = EIDRequestCaseFile.Mock.sample
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: [fileToSave], forRequestCaseId: eIDRequest.id)

    do {
      _ = try await repository.getFile(forRequestCaseId: eIDRequest.id, name: "sample.jpg", category: .documentScan)
    } catch {
      XCTAssertEqual(error as? EIDRequestCaseRepositoryError, .notFound)
    }
  }

  // MARK: Private

  private var repository: EIDRequestCaseRepositoryProtocol!
  private let mockEIDRequestState = EIDRequestState.Mock.sample

}

// swiftlint:enable implicitly_unwrapped_optional
