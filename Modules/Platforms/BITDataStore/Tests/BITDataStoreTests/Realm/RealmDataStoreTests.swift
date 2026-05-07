// swiftlint: disable implicitly_unwrapped_optional force_try
import Factory
import Foundation
import Realm
import RealmSwift
import XCTest
@testable import BITDataStore

// MARK: - RealmDataStoreTests

final class RealmDataStoreTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    resetRealm()
    dataStore = RealmDataStore()
  }

  func testGet_noObjects_returnsEmptyList() throws {
    let objects = try dataStore.get(TestObject.self, configuration: configuration)

    XCTAssertEqual(objects.count, 0)
  }

  func testGet_multipleObjects_returnsAll() throws {
    try realm.write {
      realm.add(TestObject())
      realm.add(TestObject())
    }

    let objects = try dataStore.get(TestObject.self, configuration: configuration)

    XCTAssertEqual(objects.count, 2)
  }

  func testGet_invalidId_returnsNil() throws {
    try realm.write {
      realm.add(TestObject())
    }

    let object = try dataStore.get(TestObject.self, forPrimaryKey: UUID(), configuration: configuration)

    XCTAssertNil(object)
  }

  func testGet_validId_returnsObject() throws {
    let id = UUID()
    try realm.write {
      realm.add(TestObject(value: [id]))
    }

    let object = try dataStore.get(TestObject.self, forPrimaryKey: id, configuration: configuration)

    XCTAssertNotNil(object)
  }

  func testSave_singleObject_createsObject() throws {
    let object = TestObject()

    try dataStore.save(object, policy: .all, configuration: configuration)

    XCTAssertEqual(realm.objects(TestObject.self).count, 1)
    XCTAssertEqual(object, realm.object(ofType: TestObject.self, forPrimaryKey: object.id))
  }

  func testSave_multipleObjects_createsObjects() throws {
    let object1 = TestObject()
    let object2 = TestObject()

    try dataStore.save([object1, object2], policy: .all, configuration: configuration)

    XCTAssertEqual(realm.objects(TestObject.self).count, 2)
    XCTAssertEqual(object1, realm.object(ofType: TestObject.self, forPrimaryKey: object1.id))
    XCTAssertEqual(object2, realm.object(ofType: TestObject.self, forPrimaryKey: object2.id))
  }

  func testDelete_simpleObject_deletesObject() throws {
    let object = TestObject()
    try realm.write {
      realm.add(object)
    }
    XCTAssertEqual(object, realm.object(ofType: TestObject.self, forPrimaryKey: object.id))

    try dataStore.delete(object, configuration: configuration)

    XCTAssertEqual(realm.objects(TestObject.self).count, 0)
  }

  func testDelete_nestedObject_deletesObjectAndChildren() throws {
    let childObject = TestObject()
    let subParentObject1 = SubParentTestObject(value: [UUID(), childObject])
    let subParentObject2 = SubParentTestObject()
    let parentObject = ParentTestObject(value: [UUID(), [subParentObject1, subParentObject2]])
    try realm.write {
      realm.add(parentObject)
    }
    XCTAssertEqual(realm.objects(ParentTestObject.self).count, 1)
    XCTAssertEqual(realm.objects(SubParentTestObject.self).count, 2)
    XCTAssertEqual(realm.objects(TestObject.self).count, 1)

    try dataStore.delete(parentObject, configuration: configuration)

    XCTAssertEqual(realm.objects(ParentTestObject.self).count, 0)
    XCTAssertEqual(realm.objects(SubParentTestObject.self).count, 0)
    XCTAssertEqual(realm.objects(TestObject.self).count, 0)
  }

  // MARK: Private

  private var dataStore: RealmDataStore!
  private var configuration = Realm.Configuration(inMemoryIdentifier: "inMemory")
  private var realm: Realm!

  private func resetRealm() {
    realm = try! Realm(configuration: configuration)
    try! realm.write {
      realm.deleteAll()
    }
  }
}

// MARK: - ParentTestObject

@objc(ParentTestObject)
private class ParentTestObject: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var childrenList = List<SubParentTestObject>()
}

// MARK: - SubParentTestObject

@objc(SubParentTestObject)
private class SubParentTestObject: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var childObject: TestObject?
}

// MARK: - TestObject

@objc(TestObject)
private class TestObject: Object {
  @Persisted(primaryKey: true) var id: UUID
}
