// swiftlint:disable implicitly_unwrapped_optional
import Factory
import RealmSwift
import XCTest
@testable import BITEIDRequest

final class DatabaseEIDRequestRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    repository = DatabaseEIDRequestRepository()
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

    try await repository.delete(expired)

    do {
      _ = try await repository.get(id: expired.id)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? DatabaseEIDRequestRepositoryError, .notFound)
    }
  }

  // MARK: Private

  private var repository: LocalEIDRequestRepositoryProtocol!
  private let mockEIDRequestState = EIDRequestState.Mock.sample

}

// swiftlint:enable implicitly_unwrapped_optional
