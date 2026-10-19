import Factory
import FactoryTesting
import Foundation
import Realm
import RealmSwift
import Testing
@testable import BITDataStore

// MARK: - RealmDataStoreTests

@MainActor
@Suite(.container)
struct RealmDataStoreTests {

  // MARK: Lifecycle

  init() throws {
    realm = try Realm(configuration: configuration)
    dataStore = RealmDataStore()
  }

  // MARK: Internal

  enum SavePayload: CaseIterable {
    case singleObject
    case multipleObjects

    var count: Int {
      switch self {
      case .singleObject: 1
      case .multipleObjects: 2
      }
    }
  }

  @Test(arguments: [0, 2])
  func get_returnsEveryStoredObject(count: Int) throws {
    try realm.write {
      for _ in 0..<count {
        realm.add(TestObject())
      }
    }

    let objects = try dataStore.get(TestObject.self, configuration: configuration)

    #expect(objects.count == count)
  }

  @Test(arguments: [true, false])
  func get_byPrimaryKey_returnsTheObjectOnlyForAKnownId(isKnownId: Bool) throws {
    let id = UUID()
    try realm.write {
      realm.add(TestObject(value: [id]))
    }

    let object = try dataStore.get(TestObject.self, forPrimaryKey: isKnownId ? id : UUID(), configuration: configuration)

    #expect((object != nil) == isKnownId)
  }

  @Test(arguments: SavePayload.allCases)
  func save_createsEveryObject(payload: SavePayload) throws {
    let objects = (0..<payload.count).map { _ in TestObject() }

    switch payload {
    case .singleObject:
      try dataStore.save(objects[0], policy: .all, configuration: configuration)
    case .multipleObjects:
      try dataStore.save(objects, policy: .all, configuration: configuration)
    }

    #expect(realm.objects(TestObject.self).count == payload.count)
    for object in objects {
      #expect(object == realm.object(ofType: TestObject.self, forPrimaryKey: object.id))
    }
  }

  @Test
  func delete_simpleObject_deletesObject() throws {
    let object = TestObject()
    try realm.write {
      realm.add(object)
    }
    #expect(object == realm.object(ofType: TestObject.self, forPrimaryKey: object.id))

    try dataStore.delete(object, configuration: configuration)

    #expect(realm.objects(TestObject.self).isEmpty)
  }

  @Test
  func delete_nestedObject_deletesObjectAndChildren() throws {
    let childObject = TestObject()
    let subParentObject1 = SubParentTestObject(value: [UUID(), childObject])
    let subParentObject2 = SubParentTestObject()
    let parentObject = ParentTestObject(value: [UUID(), [subParentObject1, subParentObject2]])
    try realm.write {
      realm.add(parentObject)
    }
    #expect(realm.objects(ParentTestObject.self).count == 1)
    #expect(realm.objects(SubParentTestObject.self).count == 2)
    #expect(realm.objects(TestObject.self).count == 1)

    try dataStore.delete(parentObject, configuration: configuration)

    #expect(realm.objects(ParentTestObject.self).isEmpty)
    #expect(realm.objects(SubParentTestObject.self).isEmpty)
    #expect(realm.objects(TestObject.self).isEmpty)
  }

  @Test
  func delete_contentHashedObject_isNotCascaded() throws {
    let firstId = UUID()
    let secondId = UUID()
    let shared = SharedFixture(value: ["shared-hash"])
    let first = OwnerFixture(value: [firstId, shared])
    let second = OwnerFixture(value: [secondId, shared])
    try realm.write {
      realm.add(first)
      realm.add(second, update: .modified)
    }

    try dataStore.delete(first, configuration: configuration)

    #expect(realm.object(ofType: OwnerFixture.self, forPrimaryKey: firstId) == nil)
    #expect(realm.object(ofType: OwnerFixture.self, forPrimaryKey: secondId) != nil)
    #expect(realm.object(ofType: SharedFixture.self, forPrimaryKey: "shared-hash") != nil)
  }

  // MARK: Private

  private let configuration = Realm.Configuration(inMemoryIdentifier: UUID().uuidString)

  private let realm: Realm
  private let dataStore: RealmDataStore
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

// MARK: - SharedFixture

@objc(SharedFixture)
private class SharedFixture: Object {
  @Persisted(primaryKey: true) var contentHash: String
}

// MARK: - OwnerFixture

@objc(OwnerFixture)
private class OwnerFixture: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var shared: SharedFixture?
}
