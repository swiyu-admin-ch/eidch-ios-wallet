// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import BITCore
import BITDataStore
import BITEntities
import Factory
import RealmSwift
import XCTest
@testable import BITActivity

final class ActivityRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    repository = ActivityRepository()
    createSuccessState()
  }

  func testActivityHistoryEnabledSubject_initiallyEnabled_returnsEnabled() {
    UserDefaults.standard.set(true, forKey: Self.activityHistoryEnabledKey)
    repository = ActivityRepository()

    XCTAssertTrue(repository.activityHistoryEnabledSubject.value)
  }

  func testActivityHistoryEnabledSubject_initiallyDisabled_returnsDisabled() {
    UserDefaults.standard.set(false, forKey: Self.activityHistoryEnabledKey)
    repository = ActivityRepository()

    XCTAssertFalse(repository.activityHistoryEnabledSubject.value)
  }

  func testCreate_success() throws {
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock)

    let id = try repository.create(.Mock.default, credentialId: Self.credentialIdMock)

    let images = realm.objects(ImageEntity.self)
    XCTAssertEqual(images.count, 1)
    XCTAssertEqual(images[0].imageHash, "200f1baf565d5eb3005560fcad0a7304cbdf89bd93444d79b4783ffc57fe3465")
    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: Self.credentialIdMock)
    XCTAssertEqual(credential?.activities.count, 1)
    XCTAssertEqual(credential?.activities[0].id, id)
    XCTAssertEqual(realm.objects(CredentialActivityEntity.self).count, 1)
  }

  func testGetDetail_success() throws {
    let activity = try createActivity(id: Self.activityIdMock)

    let fetched = try repository.getDetail(Self.activityIdMock)

    XCTAssertEqual(fetched, activityDetailMock)
    XCTAssertEqual(detailFactorySpy.callAsFunctionReceivedEntity, activity)
  }

  func testGetDetail_noActivity_notFound() throws {
    XCTAssertThrowsError(try repository.getDetail(UUID())) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testGetAll_noLimit_returnsAll() throws {
    let earlierActivity = try createActivity(createdAt: Date())
    let laterActivity = try createActivity(createdAt: Date().addingTimeInterval(10))
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, activities: [earlierActivity, laterActivity])

    let activities = try repository.getAll(for: Self.credentialIdMock)

    XCTAssertEqual(listItemFactorySpy.callAsFunctionReceivedInvocations.map(\.id), [laterActivity.id, earlierActivity.id])
    XCTAssertEqual(activities, [activityListItemMock, activityListItemMock])
  }

  func testGetAll_limit_returnsSpecifiedNumber() throws {
    let earlierActivity = try createActivity(createdAt: Date())
    let laterActivity = try createActivity(createdAt: Date().addingTimeInterval(10))
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, activities: [earlierActivity, laterActivity])

    let activities = try repository.getAll(for: Self.credentialIdMock, limit: 1)

    XCTAssertEqual(listItemFactorySpy.callAsFunctionReceivedInvocations.map(\.id), [laterActivity.id])
    XCTAssertEqual(activities, [activityListItemMock])
  }

  func testGetAll_biggerLimit_returnsAll() throws {
    let earlierActivity = try createActivity(createdAt: Date())
    let laterActivity = try createActivity(createdAt: Date().addingTimeInterval(10))
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, activities: [earlierActivity, laterActivity])

    let activities = try repository.getAll(for: Self.credentialIdMock, limit: 3)

    XCTAssertEqual(listItemFactorySpy.callAsFunctionReceivedInvocations.map(\.id), [laterActivity.id, earlierActivity.id])
    XCTAssertEqual(activities, [activityListItemMock, activityListItemMock])
  }

  func testGetAll_notFound() throws {
    XCTAssertThrowsError(try repository.getAll(for: UUID())) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testDelete_success() throws {
    let created = try createActivity()

    try repository.delete(created.id)

    XCTAssertEqual(realm.objects(CredentialActivityEntity.self).count, 0)
  }

  func testDelete_unreferencedImage_removesImage() throws {
    let created = try createActivity(imageHash: imageHashMock)
    _ = try ImageEntity.Mock.create(imageHash: imageHashMock)
    XCTAssertNotNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHashMock))

    try repository.delete(created.id)

    XCTAssertNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHashMock))
  }

  func testDelete_keepsImageWhenStillReferenced() throws {
    let activity1 = try createActivity(imageHash: imageHashMock)
    let activity2 = try createActivity(imageHash: imageHashMock)
    _ = try CredentialEntity.Mock.create(activities: [activity1, activity2])
    _ = try ImageEntity.Mock.create(imageHash: imageHashMock)

    try repository.delete(activity1.id)

    XCTAssertNotNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHashMock))
  }

  func testDelete_notFound() throws {
    XCTAssertThrowsError(try repository.delete(UUID())) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testDeleteAll_success() throws {
    _ = try CredentialEntity.Mock.create(id: Self.credentialIdMock, activities: [createActivity(), createActivity()])
    _ = try CredentialEntity.Mock.create(activities: [createActivity()])

    try repository.deleteAll()

    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: Self.credentialIdMock)
    XCTAssertEqual(credential?.activities.count, 0)
    XCTAssertEqual(realm.objects(CredentialActivityEntity.self).count, 0)
  }

  func testDeleteAll_removesCachedImages() throws {
    let imageData = Data("image".utf8)
    let hash = ImageHasher.hash(imageData)
    let activity1 = try createActivity(imageHash: hash)
    let activity2 = try createActivity(imageHash: hash)
    _ = try CredentialEntity.Mock.create(activities: [activity1, activity2])

    try repository.deleteAll()

    XCTAssertNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: hash))
  }

  func testIsActivityHistoryEnabled_enabled_returnsEnabled() throws {
    UserDefaults.standard.set(true, forKey: Self.activityHistoryEnabledKey)

    let result = try repository.isActivityHistoryEnabled()

    XCTAssertTrue(result)
  }

  func testIsActivityHistoryEnabled_disabled_returnsDisabled() throws {
    UserDefaults.standard.set(false, forKey: Self.activityHistoryEnabledKey)

    let result = try repository.isActivityHistoryEnabled()

    XCTAssertFalse(result)
  }

  func testSetActivityHistoryEnabled_disabled_passesArguments() throws {
    UserDefaults.standard.set(false, forKey: Self.activityHistoryEnabledKey)
    repository = ActivityRepository()

    try repository.setActivityHistoryEnabled(true)

    let result = UserDefaults.standard.bool(forKey: Self.activityHistoryEnabledKey)
    XCTAssertTrue(result)
    XCTAssertTrue(repository.activityHistoryEnabledSubject.value)
  }

  // MARK: Private

  private static let activityHistoryEnabledKey = "isActivityHistoryEnabled"
  private static let imageDataMock = "image".data(using: .utf8)!
  private static let activityIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a2")!
  private static let credentialIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a1")!

  private let activityListItemMock = ActivityListItem.Mock.acceptedPresentation
  private let activityDetailMock = ActivityDetail.Mock.trustedIssuance
  private var realm: Realm!

  private var listItemFactorySpy: ActivityListItemFactoryProtocolSpy!
  private var detailFactorySpy: ActivityDetailFactoryProtocolSpy!

  private var repository: ActivityRepositoryProtocol!

  private var imageHashMock: String {
    ImageHasher.hash(Self.imageDataMock)
  }

  private func registerMocks() {
    Container.shared.configureInMemoryDataStore()
    realm = try! Realm(configuration: Container.shared.realmDataStoreConfiguration())
    listItemFactorySpy = ActivityListItemFactoryProtocolSpy()
    detailFactorySpy = ActivityDetailFactoryProtocolSpy()

    Container.shared.activityListItemFactory.register { self.listItemFactorySpy }
    Container.shared.activityDetailFactory.register { self.detailFactorySpy }
  }

  private func createSuccessState() {
    listItemFactorySpy.callAsFunctionReturnValue = activityListItemMock
    detailFactorySpy.callAsFunctionReturnValue = activityDetailMock
  }

  private func createActivity(id: UUID = UUID(), createdAt: Date = Date(), imageHash: String? = nil) throws -> CredentialActivityEntity {
    let actorDisplay = try ActivityActorDisplayEntity.Mock.create(imageHash: imageHash, createParent: false)
    return try CredentialActivityEntity.Mock.create(id: id, createdAt: createdAt, actorDisplays: [actorDisplay], createParent: false)
  }
}
