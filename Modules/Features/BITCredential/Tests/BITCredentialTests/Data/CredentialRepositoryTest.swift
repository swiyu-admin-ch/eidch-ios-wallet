import BITCore
import BITDataStore
import BITEntities
import Factory
import XCTest
@testable import BITAnyCredentialFormat
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

  func testDeleteCredential_unreferencedImages_removesImages() async throws {
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential())
    let database = Container.shared.dataStore()
    let entity = try XCTUnwrap(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let images = entity.displayImages

    try await repository.delete(credential.id)

    for image in images {
      XCTAssertNil(try database.get(ImageEntity.self, forPrimaryKey: image))
    }
  }

  func testDeleteCredential_keepsImagesWhenStillReferenced() async throws {
    let issuerImage = Data("shared issuer image".utf8)
    let logoData = Data("shared logo data".utf8)
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential(issuerImage: issuerImage, logoData: logoData))
    _ = try await repository.create(verifiableCredential: makeVerifiableCredential(issuerImage: issuerImage, logoData: logoData))
    let database = Container.shared.dataStore()
    let entity = try XCTUnwrap(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let images = entity.displayImages

    try await repository.delete(credential.id)

    XCTAssertFalse(images.isEmpty)
    for image in images {
      XCTAssertNotNil(try database.get(ImageEntity.self, forPrimaryKey: image))
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
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
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
      format: formatMock,
      issuerUrl: issuerUrl,
      keyBindings: [keyBinding],
      authentication: CredentialAuthentication(accessToken: "access-token"))
    let createdCredential = try await repository.create(deferredCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, keyBinding.id.uuidString)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testDeleteCredential_deletesVerifiableCredentialDPoPKeyPair() async throws {
    let dpopBinding = KeyBinding(
      id: UUID(),
      algorithm: VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue,
      bindingType: .hardware)
    var credential = VerifiableCredential.Mock.sampleWithoutKeyBinding
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: .dpop,
      refreshToken: credential.authentication.refreshToken,
      dpopBinding: dpopBinding)
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, dpopBinding.id.uuidString)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm, .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  func testDeleteCredential_deletesDeferredCredentialDPoPKeyPair() async throws {
    let dpopBinding = KeyBinding(
      id: UUID(),
      algorithm: VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue,
      bindingType: .hardware)
    let authentication = CredentialAuthentication(
      accessToken: "access-token",
      tokenType: .dpop,
      dpopBinding: dpopBinding)
    let credential = DeferredCredential(
      transactionId: "tx-id",
      endpoint: "https://issuer/deferred",
      format: formatMock,
      issuerUrl: issuerUrl,
      authentication: authentication)
    let createdCredential = try await repository.create(deferredCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier, dpopBinding.id.uuidString)
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
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 0)
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
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    try await repository.delete(createdCredential.id)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 1)
    await XCTAssertCredentialNotFound(id: createdCredential.id)
  }

  func testDeleteCredential_deleteKeyPairsFalse_deleteKeyPairNotCalled() async throws {
    let deferredCredential = DeferredCredential(
      transactionId: "tx-id",
      endpoint: "https://issuer/deferred",
      format: formatMock,
      issuerUrl: issuerUrl,
      keyBindings: [],
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdDeferredCredential = try await repository.create(deferredCredential: deferredCredential)

    try await repository.delete(createdDeferredCredential.id, deleteKeyPairs: false)

    XCTAssertEqual(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount, 0)
    await XCTAssertCredentialNotFound(id: createdDeferredCredential.id)
  }

  func testGetCredential() async throws {
    let credential = try await repository.create(verifiableCredential: .Mock.sample)
    let savedCredential = try await repository.get(id: credential.id)

    XCTAssertEqual(credential, savedCredential as? VerifiableCredential)
  }

  func testGetAllCredentials() async throws {
    let readyForActivation = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .unaccepted))
    let active = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .accepted, status: .valid))
    let ghost = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .accepted, status: .unknown))
    let rejected = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .accepted, status: .suspended))
    let inProgress = try await repository.create(deferredCredential: .Mock.sample)

    let credentials = try await repository.getAll()

    let expectedOrder = [readyForActivation.id, active.id, inProgress.id, ghost.id, rejected.id]
    XCTAssertEqual(credentials.map(\.id), expectedOrder)
  }

  func testGetIssuanceSummary_success() async throws {
    let firstBundleItem = BundleItem(payload: Data("first".utf8), presented: false)
    let secondBundleItem = BundleItem(payload: Data("second".utf8), presented: true)
    let thirdBundleItem = BundleItem(payload: Data("third".utf8), presented: false)
    let issuedAt = Date(timeIntervalSince1970: 1_234_567)
    let credential = VerifiableCredential(
      createdAt: issuedAt,
      progressionState: .accepted,
      bundleItems: [firstBundleItem, secondBundleItem, thirdBundleItem],
      nextPresentableBundleItemId: firstBundleItem.id,
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    let summary = try await repository.getIssuanceSummary(id: createdCredential.id)

    XCTAssertEqual(summary, CredentialIssuanceSummary(issuedAt: issuedAt, available: 2, total: 3))
  }

  func testGetIssuanceSummary_refreshedCredential_usesRefreshedAt() async throws {
    let issuedAt = Date(timeIntervalSince1970: 1_234_567)
    let refreshedAt = Date(timeIntervalSince1970: 2_345_678)
    let bundleItem = BundleItem(payload: Data("first".utf8), presented: false)
    let credential = VerifiableCredential(
      createdAt: issuedAt,
      refreshedAt: refreshedAt,
      progressionState: .accepted,
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdCredential = try await repository.create(verifiableCredential: credential)

    let summary = try await repository.getIssuanceSummary(id: createdCredential.id)

    XCTAssertEqual(summary.issuedAt, refreshedAt)
  }

  func testGetIssuanceSummary_deferredCredential_throwsUnsupportedCredential() async throws {
    let credential = try await repository.create(deferredCredential: .Mock.sample)

    do {
      _ = try await repository.getIssuanceSummary(id: credential.id)
      XCTFail("Expecting CredentialRepositoryError.unsupportedCredential error")
    } catch {
      XCTAssertEqual(error as? CredentialRepositoryError, .unsupportedCredential)
    }
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

  func testUpdateVerifiableCredential_storesRefreshedAt() async throws {
    let refreshedAt = Date(timeIntervalSince1970: 1_234_567)
    let bundleItem = BundleItem(payload: Data())
    let credential = VerifiableCredential(
      refreshedAt: refreshedAt,
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "access-token"))
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
    _ = try CredentialEntity.Mock.create(id: credential.id, verifiableCredential: verifiableCredential)

    let storedCredential = try await repository.update(verifiableCredential: credential)

    XCTAssertEqual(storedCredential.refreshedAt?.timeIntervalSince1970, refreshedAt.timeIntervalSince1970)
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

  func testUpdateVerifiableCredential_removesReplacedDisplayImages() async throws {
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential(issuerImage: Data("old issuer".utf8), logoData: Data("old logo".utf8)))
    let database = Container.shared.dataStore()
    let oldEntity = try XCTUnwrap(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let oldImages = oldEntity.displayImages
    let updatedCredential = makeVerifiableCredential(id: credential.id, issuerImage: Data("new issuer".utf8), logoData: Data("new logo".utf8))

    _ = try await repository.update(verifiableCredential: updatedCredential)

    let updatedEntity = try XCTUnwrap(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    for image in oldImages {
      XCTAssertNil(try database.get(ImageEntity.self, forPrimaryKey: image))
    }
    for image in updatedEntity.displayImages {
      XCTAssertNotNil(try database.get(ImageEntity.self, forPrimaryKey: image))
    }
  }

  func testGetAllAcceptedVerifiableCredentials_returnsAcceptedSortedByDisplayOrder() async throws {
    let active = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .accepted, status: .valid))
    let rejected = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .accepted, status: .suspended))
    let ghost = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .accepted, status: .unknown))
    _ = try await repository.create(
      verifiableCredential: makeVerifiableCredential(progressionState: .unaccepted))
    _ = try await repository.create(deferredCredential: .Mock.sample)

    let credentials = try await repository.getAllAcceptedVerifiableCredentials()

    XCTAssertEqual(credentials.map(\.id), [active.id, ghost.id, rejected.id])
    XCTAssertTrue(credentials.allSatisfy { $0.progressionState == .accepted })
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

  func testGetAllDeferredCredentials_returnsSortedByDisplayOrder() async throws {
    let rejected = try await repository.create(
      deferredCredential: makeDeferredCredential(transactionId: "rejected", progressionState: .invalid))
    let inProgress = try await repository.create(
      deferredCredential: makeDeferredCredential(transactionId: "in-progress", progressionState: .inProgress))
    _ = try await repository.create(verifiableCredential: .Mock.sample)

    let credentials = try await repository.getAllDeferredCredentials()

    XCTAssertEqual(credentials.map(\.id), [inProgress.id, rejected.id])
    XCTAssertEqual(credentials.map(\.progressionState), [.inProgress, .invalid])
  }

  // MARK: Private

  private let issuerUrl = URL(string: "https://issuer.domain.ch")!
  private let formatMock = CredentialFormat.vcSdJwt

  private var repository: CredentialRepositoryProtocol!
  private var keyManagerSpy: KeyManagerProtocolSpy!

  private func makeVerifiableCredential(
    id: UUID = UUID(),
    issuerImage: Data = Data("issuer image".utf8),
    logoData: Data = Data("logo data".utf8),
    progressionState: VerifiableCredential.ProgressState = .accepted,
    status: CredentialStatus = .valid)
    -> VerifiableCredential
  {
    let bundleItemId = UUID()
    let bundleItem = BundleItem(id: bundleItemId, payload: Data(), status: status)
    return VerifiableCredential(
      id: id,
      progressionState: progressionState,
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItemId,
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "access-token"),
      issuerDisplays: [CredentialIssuerDisplay(credentialId: id, image: issuerImage)],
      displays: [CredentialDisplay(locale: "en-US", logoBase64: logoData)])
  }

  private func makeDeferredCredential(
    transactionId: String,
    progressionState: DeferredCredential.ProgressionState)
    -> DeferredCredential
  {
    DeferredCredential(
      transactionId: transactionId,
      progressionState: progressionState,
      endpoint: "https://endpoint",
      format: formatMock,
      issuerUrl: issuerUrl,
      authentication: CredentialAuthentication(accessToken: "accessToken"))
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
