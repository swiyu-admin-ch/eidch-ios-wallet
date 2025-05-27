import BITCore
import BITDataStore
import Factory
import RealmSwift
import XCTest
@testable import BITCredential
@testable import BITCredentialMocks
@testable import BITCredentialShared

final class DatabaseCredentialRepositoryTests: XCTestCase {

  // MARK: Internal

  override class func setUp() {
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory")
    }
  }

  override func setUp() {
    repository = RealmCredentialRepository()
  }

  // MARK: - Metadata

  func testCreateCredentialSuccess() async throws {
    let credential = try await repository.create(credential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)
    XCTAssertEqual(credential, savedCredential)
  }

  func testUpdatingCredential() async throws {
    var credential = try await repository.create(credential: .Mock.sample)
    credential.status = .expired
    let updated = try await repository.update(credential)
    XCTAssertEqual(credential.status, updated.status)
  }

  func testDeletingCredential() async throws {
    let credential = try await repository.create(credential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)
    XCTAssertEqual(credential, savedCredential)
    try await repository.delete(credential.id)
    do {
      let _ = try await repository.get(id: credential.id)
      XCTFail("Expecting CredentialRepositoryError.notFound error")
    } catch {
      XCTAssertEqual(error as? CredentialRepositoryError, .notFound)
    }
  }

  func testGetAllCredentials() async throws {
    _ = try await repository.create(credential: .Mock.sample)
    _ = try await repository.create(credential: .Mock.diploma)
    let allCredentials = try await repository.getAll()
    XCTAssertEqual(allCredentials, [.Mock.sample, .Mock.diploma])
  }

  func testCountCredentials() async throws {
    _ = try await repository.create(credential: .Mock.sample)
    _ = try await repository.create(credential: .Mock.diploma)
    let count = try repository.count()
    XCTAssertEqual(count, 2)
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional
  private var repository: CredentialRepositoryProtocol!
  // swiftlint:enable implicitly_unwrapped_optional
}
