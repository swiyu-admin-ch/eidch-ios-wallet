import BITCore
import BITDataStore
import Factory
import RealmSwift
import XCTest
@testable import BITCredential
@testable import BITCredentialShared

final class VerifiableCredentialRepositoryTest: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    repository = VerifiableCredentialRepository()
  }

  // MARK: - Metadata

  func testCreateCredentialSuccess() async throws {
    let credential = try await repository.create(.Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)
    XCTAssertEqual(credential, savedCredential)
  }

  func testUpdatingCredential() async throws {
    var credential = try await repository.create(.Mock.sample)
    credential.status = .expired
    let updated = try await repository.update(credential)
    XCTAssertEqual(credential.status, updated.status)
  }

  func testDeletingCredential() async throws {
    let credential = try await repository.create(.Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)
    XCTAssertEqual(credential, savedCredential)
    try await repository.delete(credential.id)
    do {
      _ = try await repository.get(id: credential.id)
      XCTFail("Expecting CredentialRepositoryError.notFound error")
    } catch {
      XCTAssertEqual(error as? VerifiableCredentialRepositoryError, .notFound)
    }
  }

  func testGetAllCredentials() async throws {
    _ = try await repository.create(.Mock.sample)
    _ = try await repository.create(.Mock.diploma)
    let allCredentials = try await repository.getAll()
    XCTAssertEqual(allCredentials, [.Mock.sample, .Mock.diploma])
  }

  func testCountCredentials() async throws {
    _ = try await repository.create(.Mock.sample)
    _ = try await repository.create(.Mock.diploma)
    let count = try repository.count()
    XCTAssertEqual(count, 2)
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional
  private var repository: VerifiableCredentialRepositoryProcotol!
  // swiftlint:enable implicitly_unwrapped_optional
}
