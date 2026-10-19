import BITCredentialShared
import BITDataStore
import BITEntities
import Factory
import FactoryTesting
import Foundation
import RealmSwift
import Testing
@testable import BITActivity

// MARK: - ActivityRepositoryTests

@MainActor
@Suite(.container)
struct ActivityRepositoryTests {

  // MARK: Lifecycle

  init() throws {
    Container.shared.configureInMemoryDataStore()
    realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())

    let listItemFactorySpy = ActivityListItemFactoryProtocolSpy()
    listItemFactorySpy.callAsFunctionReturnValue = Self.activityListItemMock
    let detailFactorySpy = ActivityDetailFactoryProtocolSpy()
    detailFactorySpy.callAsFunctionReturnValue = Self.activityDetailMock

    Container.shared.activityListItemFactory.register { listItemFactorySpy }
    Container.shared.activityDetailFactory.register { detailFactorySpy }

    self.listItemFactorySpy = listItemFactorySpy
    self.detailFactorySpy = detailFactorySpy
    repository = ActivityRepository()
  }

  // MARK: Internal

  enum MissingIdOperation: CaseIterable {
    case getDetail
    case getAll
    case delete
  }

  @Test(arguments: [true, false])
  func activityHistoryEnabledSubject_reflectsTheStoredPreference(isEnabled: Bool) {
    UserDefaults.standard.set(isEnabled, forKey: Self.activityHistoryEnabledKey)

    let repository = ActivityRepository()

    #expect(repository.activityHistoryEnabledSubject.value == isEnabled)
  }

  @Test
  func create_success() throws {
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock)

    let id = try repository.create(.Mock.default, credentialId: Self.credentialIdMock)

    let images = realm.objects(ImageEntity.self)
    #expect(images.count == 1)
    #expect(images[0].contentHash == ImageEntity.contentHash(of: Activity.Mock.default.actorDisplays.first?.image))
    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: Self.credentialIdMock)
    #expect(credential?.activities.count == 1)
    #expect(credential?.activities[0].id == id)
    #expect(realm.objects(CredentialActivityEntity.self).count == 1)
  }

  @Test
  func create_snapshotsCredentialRenderingAndIssuer() throws {
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(issuer: Self.issuerMock, createParent: false)
    let rendering = try CredentialRenderingEntity.Mock.create(displays: [CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)])
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, verifiableCredential: verifiableCredential, rendering: rendering)

    let id = try repository.create(.Mock.default, credentialId: Self.credentialIdMock)

    let activity = realm.object(ofType: CredentialActivityEntity.self, forPrimaryKey: id)
    #expect(activity?.credentialRendering?.contentHash == rendering.contentHash)
    #expect(activity?.issuer == Self.issuerMock)
    #expect(activity?.claims.count == 3)
  }

  @Test
  func create_bundleItemSnapshot_isPersisted() throws {
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock)
    let bundleItem = ActivityBundleItem(payload: Self.payloadMock, statusListState: .revoked)
    let activity = Activity(type: .issuance, actorTrust: .trusted, vcSchemaTrust: .trusted, bundleItem: bundleItem)

    let id = try repository.create(activity, credentialId: Self.credentialIdMock)

    let entity = realm.object(ofType: CredentialActivityEntity.self, forPrimaryKey: id)
    #expect(entity?.bundleItem?.statusListState == .revoked)
    #expect(entity?.bundleItem?.payload == Self.payloadMock)
  }

  @Test
  func create_noBundleItemSnapshot_persistsNoBundleItem() throws {
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock)

    let id = try repository.create(.Mock.default, credentialId: Self.credentialIdMock)

    let entity = realm.object(ofType: CredentialActivityEntity.self, forPrimaryKey: id)
    #expect(entity?.bundleItem == nil)
  }

  @Test
  func getDetail_success() throws {
    let activity = try createActivity(id: Self.activityIdMock)

    let fetched = try repository.getDetail(Self.activityIdMock)

    #expect(fetched == Self.activityDetailMock)
    #expect(detailFactorySpy.callAsFunctionReceivedEntity == activity)
  }

  @Test(arguments: MissingIdOperation.allCases)
  func operationOnAMissingId_throwsNotFound(operation: MissingIdOperation) throws {
    #expect(throws: ActivityRepositoryError.notFound) {
      switch operation {
      case .getDetail: _ = try repository.getDetail(UUID())
      case .getAll: _ = try repository.getAll(for: UUID())
      case .delete: try repository.delete(UUID())
      }
    }
  }

  @Test(arguments: [Int.max, 1, 3])
  func getAll_returnsTheMostRecentActivitiesUpToTheLimit(limit: Int) throws {
    let earlierActivity = try createActivity(createdAt: Date())
    let laterActivity = try createActivity(createdAt: Date().addingTimeInterval(10))
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, activities: [earlierActivity, laterActivity])

    let activities = try repository.getAll(for: Self.credentialIdMock, limit: limit)

    let expectedIds = limit == 1 ? [laterActivity.id] : [laterActivity.id, earlierActivity.id]
    #expect(listItemFactorySpy.callAsFunctionReceivedInvocations.map(\.id) == expectedIds)
    #expect(activities == Array(repeating: Self.activityListItemMock, count: expectedIds.count))
  }

  @Test
  func delete_success() throws {
    let created = try createActivity()

    try repository.delete(created.id)

    #expect(realm.objects(CredentialActivityEntity.self).isEmpty)
  }

  @Test(arguments: [true, false])
  func delete_image_isRemovedOnlyWhenNoActivityStillReferencesIt(isStillReferenced: Bool) throws {
    let created = try createActivity(imageHash: imageHashMock)
    if isStillReferenced {
      let other = try createActivity(imageHash: imageHashMock)
      _ = try CredentialEntity.Mock.create(activities: [created, other])
    }
    _ = try ImageEntity.Mock.create(contentHash: imageHashMock)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHashMock) != nil)

    try repository.delete(created.id)

    #expect((realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHashMock) != nil) == isStillReferenced)
  }

  @Test(arguments: [true, false])
  func delete_snapshotRendering_isRemovedOnlyWhenItsCredentialNoLongerPointsAtIt(isStillReferenced: Bool) throws {
    let rendering = try CredentialRenderingEntity.Mock.create(displays: [CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)])
    let contentHash = rendering.contentHash
    let created = try createActivity(rendering: rendering)
    if isStillReferenced {
      _ = try CredentialEntity.Mock.create(rendering: rendering, activities: [created])
    }

    try repository.delete(created.id)

    #expect((realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: contentHash) != nil) == isStillReferenced)
    if !isStillReferenced {
      #expect(realm.objects(CredentialDisplayEntity.self).isEmpty)
    }
  }

  @Test
  func deleteAll_success() throws {
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, activities: [createActivity(), createActivity()])
    _ = try CredentialEntity.Mock.create(activities: [createActivity()])

    try repository.deleteAll()

    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: Self.credentialIdMock)
    #expect(credential?.activities.isEmpty == true)
    #expect(realm.objects(CredentialActivityEntity.self).isEmpty)
  }

  @Test
  func deleteAll_removesCachedImages() throws {
    let imageData = Data("image".utf8)
    let hash = ImageEntity.contentHash(of: imageData)
    let activity1 = try createActivity(imageHash: hash)
    let activity2 = try createActivity(imageHash: hash)
    _ = try CredentialEntity.Mock.create(activities: [activity1, activity2])

    try repository.deleteAll()

    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: hash) == nil)
  }

  @Test
  func deleteAll_removesSnapshotRenderingsNoCredentialPointsAt() throws {
    let snapshot = try CredentialRenderingEntity.Mock.create(displays: [CredentialDisplayEntity.Mock.create(locale: "snapshot", createParent: false)])
    let current = try CredentialRenderingEntity.Mock.create(displays: [CredentialDisplayEntity.Mock.create(locale: "current", createParent: false)])
    let snapshotContentHash = snapshot.contentHash
    let activity = try createActivity(rendering: snapshot)
    _ = try CredentialEntity.Mock.create(rendering: current, activities: [activity])

    try repository.deleteAll()

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: snapshotContentHash) == nil)
    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: current.contentHash) != nil)
  }

  @Test(arguments: [true, false])
  func isActivityHistoryEnabled_returnsTheStoredPreference(isEnabled: Bool) throws {
    UserDefaults.standard.set(isEnabled, forKey: Self.activityHistoryEnabledKey)

    let result = try repository.isActivityHistoryEnabled()

    #expect(result == isEnabled)
  }

  @Test
  func setActivityHistoryEnabled_disabled_passesArguments() throws {
    UserDefaults.standard.set(false, forKey: Self.activityHistoryEnabledKey)
    let repository = ActivityRepository()

    try repository.setActivityHistoryEnabled(true)

    #expect(UserDefaults.standard.bool(forKey: Self.activityHistoryEnabledKey))
    #expect(repository.activityHistoryEnabledSubject.value)
  }

  // MARK: Private

  private static let activityHistoryEnabledKey = "isActivityHistoryEnabled"
  private static let imageDataMock = Data("image".utf8)
  private static let activityIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a2") ?? UUID()
  private static let credentialIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a1") ?? UUID()
  private static let issuerMock = "issuer"
  private static let payloadMock = Data("presented-token".utf8)
  private static let activityListItemMock = ActivityListItem.Mock.acceptedPresentation
  private static let activityDetailMock = ActivityDetail.Mock.trustedIssuance

  private let realm: Realm
  private let listItemFactorySpy: ActivityListItemFactoryProtocolSpy
  private let detailFactorySpy: ActivityDetailFactoryProtocolSpy
  private let repository: ActivityRepositoryProtocol

  private var imageHashMock: String {
    ImageEntity.contentHash(of: Self.imageDataMock)
  }

  private func createActivity(
    id: UUID = UUID(),
    createdAt: Date = Date(),
    imageHash: String? = nil,
    rendering: CredentialRenderingEntity? = nil) throws
    -> CredentialActivityEntity
  {
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(imageHash: imageHash, createParent: false)
    return try CredentialActivityEntity.Mock.create(
      id: id,
      createdAt: createdAt,
      credentialRendering: rendering,
      actorDisplays: [actorDisplay],
      createParent: false)
  }
}
