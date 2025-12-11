import BITCore
import BITDataStore
import Factory
import RealmSwift
import XCTest
@testable import BITCredential
@testable import BITCredentialShared

// swiftlint:disable implicitly_unwrapped_optional

final class CredentialRepositoryTest: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }

    repository = CredentialRepository()
  }

  func testCount_success() async throws {
    _ = try await repository.create(verifiableCredential: .Mock.sample)
    _ = try await repository.create(deferredCredential: .Mock.sample)

    let count = try repository.count()

    XCTAssertEqual(count, 1)
  }

  func testDeleteCredential() async throws {
    let credential = try await repository.create(verifiableCredential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)

    XCTAssertEqual(credential, savedCredential as? VerifiableCredential)

    try await repository.delete(credential.id)

    do {
      _ = try await repository.get(id: credential.id)
      XCTFail("Expecting CredentialRepositoryError.notFound error")
    } catch {
      XCTAssertEqual(error as? CredentialRepositoryError, .notFound)
    }
  }

  func testGetCredential() async throws {
    let credential = try await repository.create(verifiableCredential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)

    XCTAssertEqual(credential, savedCredential as? VerifiableCredential)
  }

  func testGetAllCredentials() async throws {
    _ = try await repository.create(verifiableCredential: .Mock.sample)
    _ = try await repository.create(deferredCredential: .Mock.sample)

    let credentials = try await repository.getAll()

    XCTAssertEqual(credentials.count, 2)
  }

  // MARK: - Verifiable Credentials

  func testGetAllVerifiableCredentials() async throws {
    _ = try await repository.create(verifiableCredential: .Mock.sample)
    _ = try await repository.create(verifiableCredential: .Mock.diploma)
    _ = try await repository.create(deferredCredential: .Mock.sample)

    let credentials = try await repository.getAllVerifiableCredentials()

    XCTAssertEqual(credentials, [VerifiableCredential.Mock.sample, VerifiableCredential.Mock.diploma])
  }

  func testCreateVerifiableCredential() async throws {
    let credential = try await repository.create(verifiableCredential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)

    XCTAssertEqual(credential, savedCredential as? VerifiableCredential)
  }

  func testUpdateVerifiableCredential() async throws {
    var credential = try await repository.create(verifiableCredential: .Mock.sample)
    credential.status = .expired
    let updated = try await repository.update(verifiableCredential: credential)

    XCTAssertEqual(credential.status, updated.status)
  }

  // MARK: - Deferred Credentials

  func testCreateDeferredCredential() async throws {
    let credential = try await repository.create(deferredCredential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)

    XCTAssertEqual(credential, savedCredential as? DeferredCredential)
  }

  // MARK: Private

  private var repository: CredentialRepositoryProcotol!
}
