import BITCore
import BITDataStore
import BITEntities
import Factory
import RealmSwift
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class CredentialRepositoryTest: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    Container.shared.configureInMemoryDataStore()
    keyManagerSpy = KeyManagerProtocolSpy()
    Container.shared.keyManager.register { self.keyManagerSpy }

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

  func testDeleteCredential_deletesVerifiableCredentialKeyPair() async throws {
    let keyBinding = KeyBinding(
      id: UUID(),
      algorithm: VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue,
      bindingType: .hardware)
    let bundleItem = BundleItem(payload: Data(), keyBinding: keyBinding)
    let credential = VerifiableCredential(
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: "vc+sd-jwt",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertTrue(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, keyBinding.id.uuidString)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testDeleteCredential_deletesDeferredCredentialKeyPair() async throws {
    let keyBinding = KeyBinding(
      id: UUID(),
      algorithm: VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue,
      bindingType: .hardware)
    let credential = DeferredCredential(
      transactionId: "tx-id",
      endpoint: "https://issuer/deferred",
      format: "vc+sd-jwt",
      issuerUrl: "https://issuer",
      keyBindings: [keyBinding],
      authentication: CredentialAuthentication(accessToken: "access-token"))
    let createdCredential = try await repository.create(deferredCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertTrue(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, keyBinding.id.uuidString)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testDeleteCredential_ignoresUnknownAlgorithmAndDeletesCredential() async throws {
    let keyBinding = KeyBinding(
      id: UUID(),
      algorithm: "unknown_algorithm",
      bindingType: .hardware)
    let bundleItem = BundleItem(payload: Data(), keyBinding: keyBinding)
    let credential = VerifiableCredential(
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: "vc+sd-jwt",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertFalse(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    await XCTAssertCredentialNotFound(id: createdCredential.id)
  }

  func testDeleteCredential_whenKeyDeletionFails_stillDeletesCredential() async throws {
    keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmThrowableError = TestingError.error

    let keyBinding = KeyBinding(
      id: UUID(),
      algorithm: VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue,
      bindingType: .hardware)
    let bundleItem = BundleItem(payload: Data(), keyBinding: keyBinding)
    let credential = VerifiableCredential(
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: "vc+sd-jwt",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertTrue(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCalled)
    await XCTAssertCredentialNotFound(id: createdCredential.id)
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
    var credential = VerifiableCredential.Mock.sample
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
    _ = try CredentialEntity.Mock.create(id: credential.id, verifiableCredential: verifiableCredential)
    credential.bundleItems[0].status = .expired

    _ = try await repository.update(verifiableCredential: credential)

    let database = Container.shared.dataStore()
    let updatedEntity = try XCTUnwrap(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    XCTAssertEqual(updatedEntity.verifiableCredential?.bundleItems[0].status, .expired)
  }

  func testCreateVerifiableCredential_withBatchData_storesBatchData() async throws {
    var credential = VerifiableCredential.Mock.sample
    credential.batchData = BatchData(batchSize: 3)

    let createdCredential = try await repository.create(verifiableCredential: credential)

    XCTAssertEqual(createdCredential.batchData, BatchData(batchSize: 3))
  }

  func testUpdateVerifiableCredential_withBatchData_storesUpdatedBatchData() async throws {
    var credential = VerifiableCredential.Mock.sample
    credential.batchData = BatchData(batchSize: 2)
    let createdCredential = try await repository.create(verifiableCredential: credential)

    var updatedCredential = createdCredential
    updatedCredential.batchData = BatchData(batchSize: 4)
    let storedCredential = try await repository.update(verifiableCredential: updatedCredential)

    XCTAssertEqual(storedCredential.batchData, BatchData(batchSize: 4))
  }

  func testUpdateVerifiableCredential_preservesExistingActivities() async throws {
    let credential = VerifiableCredential.Mock.sample
    let activityId = UUID()
    let activity = try CredentialActivityEntity.Mock.create(id: activityId, createParent: false)
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
    _ = try CredentialEntity.Mock.create(id: credential.id, verifiableCredential: verifiableCredential, activities: [activity])
    _ = try await repository.update(verifiableCredential: credential)

    let database = Container.shared.dataStore()
    let updatedEntity = try XCTUnwrap(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    XCTAssertEqual(updatedEntity.activities.count, 1)
    XCTAssertEqual(updatedEntity.activities.first?.id, activityId)
  }

  func getAllAcceptedVerifiableCredentials() async throws {
    _ = try await repository.create(verifiableCredential: .Mock.sample)
    _ = try await repository.create(verifiableCredential: .Mock.diploma)
    _ = try await repository.create(deferredCredential: .Mock.sample)
    _ = try await repository.create(verifiableCredential: VerifiableCredential(
      progressionState: .unaccepted,
      bundleItems: [BundleItem(payload: Data())],
      nextPresentableBundleItemId: UUID(),
      format: "format",
      issuerUrl: "https://issuer",
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken")))

    let credentials = try await repository.getAllVerifiableCredentials()

    XCTAssertEqual(credentials, [VerifiableCredential.Mock.sample, VerifiableCredential.Mock.diploma])
    XCTAssertTrue(credentials.allSatisfy({ $0.progressionState == .accepted }))
  }

  // MARK: - Deferred Credentials

  func testCreateDeferredCredential() async throws {
    let credential = try await repository.create(deferredCredential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)

    XCTAssertEqual(credential, savedCredential as? DeferredCredential)
  }

  func testUpdateDeferredCredential() async throws {
    var credential = try await repository.create(deferredCredential: .Mock.sample)
    credential.polledAt = Date(timeIntervalSince1970: 1_234_567)
    credential.progressionState = .invalid

    let updated = try await repository.update(deferredCredential: credential)

    XCTAssertEqual(updated.polledAt?.timeIntervalSince1970, 1_234_567)
    XCTAssertEqual(updated.progressionState, .invalid)
  }

  func testGetAllDeferredCredentials() async throws {
    _ = try await repository.create(deferredCredential: .Mock.sample)
    _ = try await repository.create(deferredCredential: .Mock.sampleWithoutMetadata)
    _ = try await repository.create(verifiableCredential: .Mock.sample)

    let credentials = try await repository.getAllDeferredCredentials()

    XCTAssertEqual(credentials, [DeferredCredential.Mock.sample, DeferredCredential.Mock.sampleWithoutMetadata])
  }

  // MARK: Private

  private var repository: CredentialRepositoryProcotol!
  private var keyManagerSpy: KeyManagerProtocolSpy!

  private func createActivity(id: UUID = UUID(), createdAt: Date = Date(), imageHash: String? = nil) throws -> CredentialActivityEntity {
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(imageHash: imageHash, createParent: false)
    return try CredentialActivityEntity.Mock.create(id: id, createdAt: createdAt, actorDisplays: [actorDisplay], createParent: false)
  }

  private func XCTAssertCredentialNotFound(id: UUID) async {
    do {
      _ = try await repository.get(id: id)
      XCTFail("Expecting CredentialRepositoryError.notFound error")
    } catch {
      XCTAssertEqual(error as? CredentialRepositoryError, .notFound)
    }
  }
}
