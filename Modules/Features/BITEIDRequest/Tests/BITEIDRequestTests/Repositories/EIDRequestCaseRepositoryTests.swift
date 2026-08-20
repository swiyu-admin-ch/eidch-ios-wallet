import Factory
import FactoryTesting
import RealmSwift
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared

@Suite(.container)
struct EIDRequestCaseRepositoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    Container.shared.dataStore.reset()
    repository = EIDRequestCaseRepository()
  }

  // MARK: Internal

  @Test
  func createEIDRequestCaseSuccess() async throws {
    let eIDRequestCase = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)
    let savedRequestCase = try await repository.get(id: eIDRequestCase.id)
    #expect(eIDRequestCase == savedRequestCase)
  }

  @Test
  func getAllEIDRequestCaseSuccess() async throws {
    _ = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleAVReady)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleInQueueNoOnlineSessionStart)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleExpired)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleCancelled)

    let eIDRequestCases = try await repository.getAll()

    let sortedArray: [EIDRequestCase] = [
      .Mock.sampleInQueueNoOnlineSessionStart,
      .Mock.sampleExpired,
      .Mock.sampleCancelled,
      .Mock.sampleAVReady,
      .Mock.sampleInQueue,
    ]

    #expect(eIDRequestCases == sortedArray)
  }

  @Test
  func updateEIDRequestCaseSuccess() async throws {
    var eIDRequestCase = try await repository.create(eIDRequestCase: .Mock.sampleAVReady)
    eIDRequestCase.state = EIDRequestState.Mock.sample

    let updatedRequestCase = try await repository.update(eIDRequestCase)
    let savedRequestCase = try await repository.get(id: eIDRequestCase.id)

    #expect(updatedRequestCase == savedRequestCase)
    #expect(eIDRequestCase == savedRequestCase)
  }

  @Test
  func deleteEIDRequestCaseSuccess() async throws {
    let expired = try await repository.create(eIDRequestCase: .Mock.sampleExpired)

    try await repository.delete(expired.id)

    await #expect(throws: EIDRequestCaseRepositoryError.notFound) {
      _ = try await repository.get(id: expired.id)
    }
  }

  @Test
  func getAllFiles_returnsAll() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: EIDRequestCaseFile.Mock.sampleArray, forRequestCaseId: eIDRequest.id)

    let files = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)

    #expect(expectedFiles.count == files.count)
  }

  @Test
  func saveMultipleFileAtOnce() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: expectedFiles, forRequestCaseId: eIDRequest.id)

    let allFiles = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    #expect(expectedFiles.count == allFiles.count)
  }

  @Test
  func deleteAllFiles() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: EIDRequestCaseFile.Mock.sampleArray, forRequestCaseId: eIDRequest.id)

    let allFiles = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    #expect(expectedFiles.count == allFiles.count)

    try await repository.deleteAllFiles(forRequestCaseId: eIDRequest.id)

    let files = try await repository.getAllFiles(forRequestCaseId: eIDRequest.id)
    #expect(files.isEmpty)
  }

  @Test
  func getFilesByCategory() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: EIDRequestCaseFile.Mock.sampleArray, forRequestCaseId: eIDRequest.id)

    let filteredFiles = try await repository.getFiles(forRequestCaseId: eIDRequest.id, matching: .documentScan)
    #expect(expectedFiles.count == filteredFiles.count)
  }

  @Test
  func getFilesByNameAndCategory() async throws {
    let expectedFiles = EIDRequestCaseFile.Mock.sampleArray
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: expectedFiles, forRequestCaseId: eIDRequest.id)

    let file = try await repository.getFile(forRequestCaseId: eIDRequest.id, name: "sample3.jpg", category: .documentScan)

    #expect(file == expectedFiles.last)
  }

  @Test
  func getFilesByNameAndCategory_fileNotExisiting_throwsError() async throws {
    let fileToSave = EIDRequestCaseFile.Mock.sample
    let eIDRequest = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)

    try await repository.save(files: [fileToSave], forRequestCaseId: eIDRequest.id)

    await #expect(throws: EIDRequestCaseRepositoryError.notFound) {
      _ = try await repository.getFile(forRequestCaseId: eIDRequest.id, name: "sample3.jpg", category: .documentScan)
    }
  }

  @Test
  func getAllPushIds_success() async throws {
    _ = try await repository.create(eIDRequestCase: .Mock.sampleInQueue)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleAVReady)
    _ = try await repository.create(eIDRequestCase: .Mock.sampleInQueueNoOnlineSessionStart)

    let result = try await repository.getAllPushIds()

    #expect(result.count == 3)
  }

  @Test
  func savePushId_repository() async throws {
    let mockPushId = "push_id"
    var mockRequestCase = EIDRequestCase.Mock.sampleInQueue
    mockRequestCase.pushId = mockPushId
    _ = try await repository.create(eIDRequestCase: mockRequestCase)

    try await repository.savePushId(mockPushId, for: mockRequestCase.id)

    let updateRequestCase = try await repository.get(id: mockRequestCase.id)

    #expect(updateRequestCase.pushId == mockPushId)
  }

  @Test
  func savePairingId_success() async throws {
    let mockPairingId = "pairing_id"
    let mockRequestCase = EIDRequestCase.Mock.sampleAutoVerification

    try await repository.create(eIDRequestCase: mockRequestCase)
    try await repository.savePairingId(mockPairingId, forRequestCaseId: mockRequestCase.id)

    let updateRequestCase = try await repository.get(id: mockRequestCase.id)

    #expect(updateRequestCase.pairingIds.contains(mockPairingId))
  }

  @Test
  func savePairingId_requestCaseNotFound_throwsError() async throws {
    await #expect(throws: EIDRequestCaseRepositoryError.notFound) {
      try await repository.savePairingId("pairing_id", forRequestCaseId: "unknownCaseId")
    }
  }

  @Test
  func getPairingIds_success() async throws {
    let mockRequestCase = EIDRequestCase.Mock.sampleAutoVerification

    try await repository.create(eIDRequestCase: mockRequestCase)
    try await repository.savePairingId("pairing_id_1", forRequestCaseId: mockRequestCase.id)
    try await repository.savePairingId("pairing_id_2", forRequestCaseId: mockRequestCase.id)

    let pairingIds = try await repository.getPairingIds(forRequestCaseId: mockRequestCase.id)

    #expect(pairingIds == ["pairing_id_1", "pairing_id_2"])
  }

  @Test
  func getPairingIds_noPairingIds_returnsEmptyArray() async throws {
    let mockRequestCase = EIDRequestCase.Mock.sampleAutoVerification

    try await repository.create(eIDRequestCase: mockRequestCase)

    let pairingIds = try await repository.getPairingIds(forRequestCaseId: mockRequestCase.id)

    #expect(pairingIds.isEmpty)
  }

  @Test
  func getPairingIds_requestCaseNotFound_throwsError() async throws {
    await #expect(throws: EIDRequestCaseRepositoryError.notFound) {
      _ = try await repository.getPairingIds(forRequestCaseId: "unknownCaseId")
    }
  }

  @Test
  func deletePairings_success() async throws {
    let mockRequestCase = EIDRequestCase.Mock.sampleAutoVerification

    try await repository.create(eIDRequestCase: mockRequestCase)
    try await repository.savePairingId("pairing_id_1", forRequestCaseId: mockRequestCase.id)
    try await repository.savePairingId("pairing_id_2", forRequestCaseId: mockRequestCase.id)

    try await repository.deletePairings(for: mockRequestCase.id)

    let pairingIds = try await repository.getPairingIds(forRequestCaseId: mockRequestCase.id)
    #expect(pairingIds.isEmpty)
  }

  @Test
  func deletePairings_requestCaseNotFound_throwsError() async throws {
    await #expect(throws: EIDRequestCaseRepositoryError.notFound) {
      try await repository.deletePairings(for: "unknownCaseId")
    }
  }

  // MARK: Private

  private let repository: EIDRequestCaseRepositoryProtocol
}
