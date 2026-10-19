import BITCore
import BITDataStore
import BITEntities
import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable force_unwrapping

// MARK: - CredentialRepositoryTest

@Suite(.container)
struct CredentialRepositoryTest {

  // MARK: Lifecycle

  init() {
    Container.shared.configureInMemoryDataStore()

    let keyManagerSpy = KeyManagerProtocolSpy()
    Container.shared.keyManager.register { keyManagerSpy }

    self.keyManagerSpy = keyManagerSpy
    repository = CredentialRepository()
  }

  // MARK: Internal

  /// The four places a credential can hold a key pair the repository has to clean up on delete.
  enum KeyPairOwner: CaseIterable {
    case verifiableCredentialKeyBinding
    case deferredCredentialKeyBinding
    case verifiableCredentialDPoPBinding
    case deferredCredentialDPoPBinding
  }

  enum KeyDeletionFailure: CaseIterable {
    case unknownAlgorithm
    case keyManagerThrows

    var expectedDeleteKeyPairCallsCount: Int {
      switch self {
      case .unknownAlgorithm: 0
      case .keyManagerThrows: 1
      }
    }
  }

  @Test
  func count_success() async throws {
    _ = try await repository.create(verifiableCredential: .Mock.sample)
    _ = try await repository.create(deferredCredential: .Mock.sample)

    let count = try repository.count()

    #expect(count == 1)
  }

  @Test
  func createAndGet_returnsTheSameCredential() async throws {
    let credential = try await repository.create(verifiableCredential: .Mock.sample)

    let savedCredential = try await repository.get(id: credential.id)

    #expect(credential == savedCredential as? VerifiableCredential)
  }

  @Test
  func delete_removesTheCredential() async throws {
    let credential = try await repository.create(verifiableCredential: .Mock.sample)

    try await repository.delete(credential.id)

    await expectCredentialNotFound(id: credential.id)
  }

  @Test(arguments: [true, false])
  func delete_displayImages_areKeptOnlyWhileAnotherCredentialUsesThem(isSharedWithAnotherCredential: Bool) async throws {
    let issuerImage = Data("shared issuer image".utf8)
    let logoData = Data("shared logo data".utf8)
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential(issuerImage: issuerImage, logoData: logoData))
    if isSharedWithAnotherCredential {
      _ = try await repository.create(verifiableCredential: makeVerifiableCredential(issuerImage: issuerImage, logoData: logoData))
    }
    let database = Container.shared.dataStore()
    let entity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let images = entity.displayImages

    try await repository.delete(credential.id)

    #expect(!images.isEmpty)
    for image in images {
      let storedImage = try database.get(ImageEntity.self, forPrimaryKey: image)
      #expect((storedImage != nil) == isSharedWithAnotherCredential)
    }
  }

  @Test(arguments: [true, false])
  func delete_rendering_isKeptOnlyWhileAnotherCredentialUsesIt(isSharedWithAnotherCredential: Bool) async throws {
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential())
    if isSharedWithAnotherCredential {
      _ = try await repository.create(verifiableCredential: makeVerifiableCredential())
    }
    let database = Container.shared.dataStore()
    let entity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let contentHash = try #require(entity.credentialRendering?.contentHash)

    try await repository.delete(credential.id)

    let rendering = try database.get(CredentialRenderingEntity.self, forPrimaryKey: contentHash)
    #expect((rendering != nil) == isSharedWithAnotherCredential)

    guard !isSharedWithAnotherCredential else { return }
    let displayCount = try database.get(CredentialDisplayEntity.self).count
    let issuerDisplayCount = try database.get(CredentialIssuerDisplayEntity.self).count
    #expect(displayCount == 0)
    #expect(issuerDisplayCount == 0)
  }

  @Test(arguments: KeyPairOwner.allCases)
  func delete_deletesTheKeyPairOfTheCredential(owner: KeyPairOwner) async throws {
    let keyBinding = KeyBinding(
      id: UUID(),
      algorithm: VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue,
      bindingType: .hardware)
    let credentialId = try await createCredential(holding: keyBinding, as: owner)

    try await repository.delete(credentialId)

    #expect(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount == 1)
    #expect(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.identifier == keyBinding.id.uuidString)
    #expect(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmReceivedArguments?.algorithm == .eciesEncryptionStandardVariableIVX963SHA256AESGCM)
  }

  @Test(arguments: KeyDeletionFailure.allCases)
  func delete_keyDeletionFailure_stillDeletesTheCredential(failure: KeyDeletionFailure) async throws {
    let algorithm: String
    switch failure {
    case .unknownAlgorithm:
      algorithm = "unknown_algorithm"
    case .keyManagerThrows:
      algorithm = VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA256AESGCM.rawValue
      keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmThrowableError = TestingError.error
    }
    let bundleItem = BundleItem(payload: Data(), keyBinding: KeyBinding(id: UUID(), algorithm: algorithm, bindingType: .hardware))
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential(bundleItem: bundleItem))

    try await repository.delete(credential.id)

    #expect(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount == failure.expectedDeleteKeyPairCallsCount)
    await expectCredentialNotFound(id: credential.id)
  }

  @Test
  func delete_deleteKeyPairsFalse_deleteKeyPairNotCalled() async throws {
    let deferredCredential = DeferredCredential(
      transactionId: "tx-id",
      endpoint: "https://issuer/deferred",
      format: formatMock,
      issuerUrl: issuerUrl,
      keyBindings: [],
      authentication: CredentialAuthentication(accessToken: "accessToken"))
    let createdDeferredCredential = try await repository.create(deferredCredential: deferredCredential)

    try await repository.delete(createdDeferredCredential.id, deleteKeyPairs: false)

    #expect(keyManagerSpy.deleteKeyPairWithIdentifierAlgorithmCallsCount == 0)
    await expectCredentialNotFound(id: createdDeferredCredential.id)
  }

  @Test
  func getAll_returnsEveryCredentialSortedByDisplayOrder() async throws {
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

    #expect(credentials.map(\.id) == [readyForActivation.id, active.id, inProgress.id, ghost.id, rejected.id])
  }

  @Test
  func getIssuanceSummary_success() async throws {
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

    #expect(summary == CredentialIssuanceSummary(issuedAt: issuedAt, available: 2, total: 3))
  }

  @Test
  func getIssuanceSummary_refreshedCredential_usesRefreshedAt() async throws {
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

    #expect(summary.issuedAt == refreshedAt)
  }

  @Test
  func getIssuanceSummary_deferredCredential_throwsUnsupportedCredential() async throws {
    let credential = try await repository.create(deferredCredential: .Mock.sample)

    await #expect(throws: CredentialRepositoryError.unsupportedCredential) {
      _ = try await repository.getIssuanceSummary(id: credential.id)
    }
  }

  // MARK: - Verifiable Credentials

  @Test
  func getAllVerifiableCredentials() async throws {
    _ = try await repository.create(verifiableCredential: .Mock.sample)
    _ = try await repository.create(verifiableCredential: .Mock.diploma)
    _ = try await repository.create(deferredCredential: .Mock.sample)

    let credentials = try await repository.getAllVerifiableCredentials()

    #expect(credentials == [VerifiableCredential.Mock.sample, VerifiableCredential.Mock.diploma])
  }

  @Test
  func updateVerifiableCredential() async throws {
    var credential = VerifiableCredential.Mock.sample
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
    _ = try CredentialEntity.Mock.create(id: credential.id, verifiableCredential: verifiableCredential)
    credential.bundleItems[0].status = .expired

    _ = try await repository.update(verifiableCredential: credential)

    let database = Container.shared.dataStore()
    let updatedEntity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    #expect(updatedEntity.verifiableCredential?.bundleItems[0].status == .expired)
  }

  @Test
  func updateVerifiableCredential_storesRefreshedAt() async throws {
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

    #expect(storedCredential.refreshedAt?.timeIntervalSince1970 == refreshedAt.timeIntervalSince1970)
  }

  @Test
  func createVerifiableCredential_withBatchData_storesBatchData() async throws {
    var credential = VerifiableCredential.Mock.sample
    credential.batchData = BatchData(batchSize: 3)

    let createdCredential = try await repository.create(verifiableCredential: credential)

    #expect(createdCredential.batchData == BatchData(batchSize: 3))
  }

  @Test
  func updateVerifiableCredential_withBatchData_storesUpdatedBatchData() async throws {
    var credential = VerifiableCredential.Mock.sample
    credential.batchData = BatchData(batchSize: 2)
    let createdCredential = try await repository.create(verifiableCredential: credential)

    var updatedCredential = createdCredential
    updatedCredential.batchData = BatchData(batchSize: 4)
    let storedCredential = try await repository.update(verifiableCredential: updatedCredential)

    #expect(storedCredential.batchData == BatchData(batchSize: 4))
  }

  @Test
  func updateVerifiableCredential_preservesExistingActivities() async throws {
    let credential = VerifiableCredential.Mock.sample
    let activityId = UUID()
    let activity = try CredentialActivityEntity.Mock.create(id: activityId, createParent: false)
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
    _ = try CredentialEntity.Mock.create(id: credential.id, verifiableCredential: verifiableCredential, activities: [activity])
    _ = try await repository.update(verifiableCredential: credential)

    let database = Container.shared.dataStore()
    let updatedEntity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    #expect(updatedEntity.activities.count == 1)
    #expect(updatedEntity.activities.first?.id == activityId)
  }

  @Test
  func updateVerifiableCredential_removesReplacedDisplayImages() async throws {
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential(issuerImage: Data("old issuer".utf8), logoData: Data("old logo".utf8)))
    let database = Container.shared.dataStore()
    let oldEntity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let oldImages = oldEntity.displayImages
    let updatedCredential = makeVerifiableCredential(id: credential.id, issuerImage: Data("new issuer".utf8), logoData: Data("new logo".utf8))

    _ = try await repository.update(verifiableCredential: updatedCredential)

    let updatedEntity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    for image in oldImages {
      let storedImage = try database.get(ImageEntity.self, forPrimaryKey: image)
      #expect(storedImage == nil)
    }
    for image in updatedEntity.displayImages {
      let storedImage = try database.get(ImageEntity.self, forPrimaryKey: image)
      #expect(storedImage != nil)
    }
  }

  @Test(arguments: [true, false])
  func updateVerifiableCredential_replacedRendering_isKeptOnlyWhenAnActivityHoldsIt(isHeldByAnActivity: Bool) async throws {
    let credential = try await repository.create(verifiableCredential: makeVerifiableCredential(logoData: Data("old logo".utf8)))
    let database = Container.shared.dataStore()
    let oldEntity = try #require(try database.get(CredentialEntity.self, forPrimaryKey: credential.id))
    let oldRendering = try #require(oldEntity.credentialRendering)
    let oldContentHash = oldRendering.contentHash
    if isHeldByAnActivity {
      let activity = try CredentialActivityEntity.Mock.create(credentialRendering: oldRendering, createParent: false)
      try database.write { oldEntity.activities.append(activity) }
    }
    let updatedCredential = makeVerifiableCredential(id: credential.id, logoData: Data("new logo".utf8))

    _ = try await repository.update(verifiableCredential: updatedCredential)

    let oldStoredRendering = try database.get(CredentialRenderingEntity.self, forPrimaryKey: oldContentHash)
    #expect((oldStoredRendering != nil) == isHeldByAnActivity)

    guard !isHeldByAnActivity else { return }
    let renderingCount = try database.get(CredentialRenderingEntity.self).count
    #expect(renderingCount == 1)
  }

  @Test
  func getAllAcceptedVerifiableCredentials_returnsAcceptedSortedByDisplayOrder() async throws {
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

    #expect(credentials.map(\.id) == [active.id, ghost.id, rejected.id])
    #expect(credentials.allSatisfy { $0.progressionState == .accepted })
  }

  // MARK: - Deferred Credentials

  @Test
  func createDeferredCredential() async throws {
    let credential = try await repository.create(deferredCredential: .Mock.sample)

    let savedCredential = try await repository.get(id: credential.id)

    #expect(credential == savedCredential as? DeferredCredential)
  }

  @Test
  func updateDeferredCredential() async throws {
    var credential = try await repository.create(deferredCredential: .Mock.sample)
    credential.polledAt = Date(timeIntervalSince1970: 1_234_567)
    credential.progressionState = .invalid

    let updated = try await repository.update(deferredCredential: credential)

    #expect(updated.polledAt?.timeIntervalSince1970 == 1_234_567)
    #expect(updated.progressionState == .invalid)
  }

  @Test
  func getAllDeferredCredentials_returnsSortedByDisplayOrder() async throws {
    let rejected = try await repository.create(
      deferredCredential: makeDeferredCredential(transactionId: "rejected", progressionState: .invalid))
    let inProgress = try await repository.create(
      deferredCredential: makeDeferredCredential(transactionId: "in-progress", progressionState: .inProgress))
    _ = try await repository.create(verifiableCredential: .Mock.sample)

    let credentials = try await repository.getAllDeferredCredentials()

    #expect(credentials.map(\.id) == [inProgress.id, rejected.id])
    #expect(credentials.map(\.progressionState) == [.inProgress, .invalid])
  }

  // MARK: Private

  private let issuerUrl = URL(string: "https://issuer.domain.ch")!
  private let formatMock = CredentialFormat.vcSdJwt

  private let repository: CredentialRepositoryProtocol
  private let keyManagerSpy: KeyManagerProtocolSpy

  private func createCredential(holding keyBinding: KeyBinding, as owner: KeyPairOwner) async throws -> UUID {
    switch owner {
    case .verifiableCredentialKeyBinding:
      let bundleItem = BundleItem(payload: Data(), keyBinding: keyBinding)
      return try await repository.create(verifiableCredential: makeVerifiableCredential(bundleItem: bundleItem)).id

    case .deferredCredentialKeyBinding:
      let credential = DeferredCredential(
        transactionId: "tx-id",
        endpoint: "https://issuer/deferred",
        format: formatMock,
        issuerUrl: issuerUrl,
        keyBindings: [keyBinding],
        authentication: CredentialAuthentication(accessToken: "access-token"))
      return try await repository.create(deferredCredential: credential).id

    case .verifiableCredentialDPoPBinding:
      var credential = VerifiableCredential.Mock.sampleWithoutKeyBinding
      credential.authentication = CredentialAuthentication(
        accessToken: credential.authentication.accessToken,
        tokenType: .dpop,
        refreshToken: credential.authentication.refreshToken,
        dpopBinding: keyBinding)
      return try await repository.create(verifiableCredential: credential).id

    case .deferredCredentialDPoPBinding:
      let credential = DeferredCredential(
        transactionId: "tx-id",
        endpoint: "https://issuer/deferred",
        format: formatMock,
        issuerUrl: issuerUrl,
        authentication: CredentialAuthentication(accessToken: "access-token", tokenType: .dpop, dpopBinding: keyBinding))
      return try await repository.create(deferredCredential: credential).id
    }
  }

  private func makeVerifiableCredential(bundleItem: BundleItem) -> VerifiableCredential {
    VerifiableCredential(
      bundleItems: [bundleItem],
      nextPresentableBundleItemId: bundleItem.id,
      format: formatMock,
      issuerUrl: issuerUrl,
      issuer: "issuer",
      authentication: CredentialAuthentication(accessToken: "accessToken"))
  }

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
      issuerDisplays: [CredentialIssuerDisplay(image: issuerImage)],
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

  private func expectCredentialNotFound(id: UUID, sourceLocation: SourceLocation = #_sourceLocation) async {
    await #expect(throws: CredentialRepositoryError.notFound, sourceLocation: sourceLocation) {
      _ = try await repository.get(id: id)
    }
  }
}

// swiftlint:enable force_unwrapping
