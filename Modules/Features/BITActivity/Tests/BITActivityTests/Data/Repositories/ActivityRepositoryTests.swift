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
    Container.shared.reset()
    Container.shared.realmDataStoreConfiguration.register { Realm.Configuration(inMemoryIdentifier: "inMemory") }
    try! createCredential(credentialId: credentialIdMock)
    repository = ActivityRepository()
  }

  func testCreate_success() throws {
    let created = try repository.create(.Mock.issueTrusted, credentialId: credentialIdMock)

    XCTAssertEqual(.Mock.issueTrusted, created)

    let images = created.actorDisplays.compactMap(\.image)
    let imageHashes = images.map { ImageHasher.hash($0) }
    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())

    for hash in imageHashes {
      XCTAssertNotNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: hash))
    }
    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: credentialIdMock)
    XCTAssertEqual(credential?.activities.count, 1)
    XCTAssertEqual(credential?.activities[0].id, created.id)
  }

  func testGet_success() throws {
    let created = try repository.create(.Mock.issueTrusted, credentialId: credentialIdMock)
    let fetched = try repository.get(created.id)

    XCTAssertEqual(created, fetched)
  }

  func testGet_noActivity_notFound() throws {
    XCTAssertThrowsError(try repository.get(UUID())) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testGetAll_noLimit_returnsAll() throws {
    let earlierActivity = Activity.Mock.issueTrusted
    let laterActivity = Activity.Mock.presentationAcceptedTrusted

    _ = try repository.create(earlierActivity, credentialId: credentialIdMock)
    _ = try repository.create(laterActivity, credentialId: credentialIdMock)

    let activities = try repository.getAll(for: credentialIdMock)

    XCTAssertEqual(activities, [laterActivity, earlierActivity])
  }

  func testGetAll_limit_returnsSpecifiedNumber() throws {
    let earlierActivity = Activity.Mock.issueTrusted
    let laterActivity = Activity.Mock.presentationAcceptedTrusted

    _ = try repository.create(earlierActivity, credentialId: credentialIdMock)
    _ = try repository.create(laterActivity, credentialId: credentialIdMock)

    let activities = try repository.getAll(for: credentialIdMock, limit: 1)

    XCTAssertEqual(activities, [laterActivity])
  }

  func testGetAll_biggerLimit_returnsAll() throws {
    let earlierActivity = Activity.Mock.issueTrusted
    let laterActivity = Activity.Mock.presentationAcceptedTrusted

    _ = try repository.create(earlierActivity, credentialId: credentialIdMock)
    _ = try repository.create(laterActivity, credentialId: credentialIdMock)

    let activities = try repository.getAll(for: credentialIdMock, limit: 3)

    XCTAssertEqual(activities, [laterActivity, earlierActivity])
  }

  func testGetAll_notFound() throws {
    XCTAssertThrowsError(try repository.getAll(for: UUID())) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testDelete_success() throws {
    let created = try repository.create(.Mock.issueTrusted, credentialId: credentialIdMock)
    let fetched = try repository.get(created.id)
    XCTAssertEqual(created, fetched)

    try repository.delete(created.id)

    XCTAssertThrowsError(try repository.get(created.id)) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testDelete_unreferencedImage_removesImage() throws {
    let imageData = Data("image".utf8)
    let activity = createActivity(imageData)

    let created = try repository.create(activity, credentialId: credentialIdMock)
    let hash = ImageHasher.hash(imageData)

    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())
    XCTAssertNotNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: hash))

    try repository.delete(created.id)

    XCTAssertNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: hash))
  }

  func testDelete_keepsImageWhenStillReferenced() throws {
    let imageData = Data("image".utf8)
    let activity1 = createActivity(imageData)
    let activity2 = createActivity(imageData)

    let activity1Created = try repository.create(activity1, credentialId: credentialIdMock)
    _ = try repository.create(activity2, credentialId: credentialIdMock)

    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())

    try repository.delete(activity1Created.id)
    let hash = ImageHasher.hash(imageData)

    XCTAssertNotNil(realm.object(ofType: ImageEntity.self, forPrimaryKey: hash))
  }

  func testDelete_notFound() throws {
    XCTAssertThrowsError(try repository.delete(UUID())) { error in
      XCTAssertEqual(error as? ActivityRepositoryError, .notFound)
    }
  }

  func testDeleteAll_success() throws {
    _ = try repository.create(.Mock.issueTrusted, credentialId: credentialIdMock)
    _ = try repository.create(.Mock.presentationAcceptedTrusted, credentialId: credentialIdMock)

    let otherCredentialId = UUID()
    try createCredential(credentialId: otherCredentialId)
    _ = try repository.create(.Mock.issueTrusted, credentialId: otherCredentialId)

    try repository.deleteAll()

    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())
    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: credentialIdMock)

    XCTAssertEqual(credential?.activities.count, 0)
  }

  func testDeleteAll_removesCachedImages() throws {
    let imageData = Data("image".utf8)
    let activity1 = createActivity(imageData)
    let activity2 = createActivity(imageData)

    _ = try repository.create(activity1, credentialId: credentialIdMock)
    _ = try repository.create(activity2, credentialId: credentialIdMock)

    try repository.deleteAll()

    let hash = ImageHasher.hash(imageData)
    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())

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

    try repository.setActivityHistoryEnabled(true)

    let result = UserDefaults.standard.bool(forKey: Self.activityHistoryEnabledKey)
    XCTAssertTrue(result)
  }

  // MARK: Private

  private static let activityHistoryEnabledKey = "isActivityHistoryEnabled"

  private var repository: ActivityRepositoryProtocol!
  private let credentialIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a1")!
  private let activityIdMock = UUID(uuidString: "9d0e30cd-e8ff-43b4-ba46-efe9047770a2")!

  private func createActivity(_ imageData: Data) -> Activity {
    Activity(
      type: .issuance,
      actorTrust: .trusted,
      vcSchemaTrust: .trusted,
      nonComplianceData: nil,
      actorDisplays: [ActivityActorDisplay(image: Data("image".utf8))])
  }

  private func createCredential(credentialId: UUID) throws {
    let realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())

    try realm.write {
      let credential = CredentialEntity()
      credential.id = credentialId
      realm.add(credential, update: .modified)
    }
  }
}
