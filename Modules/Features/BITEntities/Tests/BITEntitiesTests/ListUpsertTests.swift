import BITDataStore
import Factory
import RealmSwift
import XCTest
@testable import BITEntities

// MARK: - ListUpsertTests

final class ListUpsertTests: XCTestCase {

  // MARK: Internal

  func testReplaceWithUpserted_unmanagedList_replacesContents() {
    let list = List<ListUpsertTestItemEntity>()
    list.append(ListUpsertTestItemEntity(id: "existing", value: "old"))

    let replacement = [
      ListUpsertTestItemEntity(id: "item-1", value: "one"),
      ListUpsertTestItemEntity(id: "item-2", value: "two"),
    ]

    list.replaceWithUpserted(replacement, in: nil)

    XCTAssertEqual(list.count, 2)
    XCTAssertEqual(Array(list.map(\.id)), ["item-1", "item-2"])
    XCTAssertEqual(Array(list.map(\.value)), ["one", "two"])
  }

  func testReplaceWithUpserted_managedList_upsertsByPrimaryKey() throws {
    let realm = try makeRealm()
    let parentId = UUID().uuidString

    try realm.write {
      let parent = ListUpsertTestParentEntity()
      parent.id = parentId
      parent.items.append(ListUpsertTestItemEntity(id: "item-1", value: "old"))
      realm.add(parent)
    }

    try realm.write {
      let parent = try XCTUnwrap(realm.object(ofType: ListUpsertTestParentEntity.self, forPrimaryKey: parentId))
      parent.items.replaceWithUpserted(
        [
          ListUpsertTestItemEntity(id: "item-1", value: "new"),
          ListUpsertTestItemEntity(id: "item-2", value: "two"),
        ],
        in: realm)
    }

    let parent = try XCTUnwrap(realm.object(ofType: ListUpsertTestParentEntity.self, forPrimaryKey: parentId))
    XCTAssertEqual(parent.items.count, 2)
    XCTAssertEqual(parent.items[0].id, "item-1")
    XCTAssertEqual(parent.items[0].value, "new")
    XCTAssertEqual(parent.items[1].id, "item-2")
    XCTAssertEqual(parent.items[1].value, "two")
    XCTAssertEqual(realm.objects(ListUpsertTestItemEntity.self).count, 2)
  }

  func testUpserted_inRealm_updatesAndReturnsManagedObject() throws {
    let realm = try makeRealm()

    try realm.write {
      realm.add(ListUpsertTestItemEntity(id: "item-1", value: "old"))
    }

    let updated = ListUpsertTestItemEntity(id: "item-1", value: "new")
    let managed = try realm.write {
      updated.upserted(in: realm)
    }

    let persisted = try XCTUnwrap(realm.object(ofType: ListUpsertTestItemEntity.self, forPrimaryKey: "item-1"))
    XCTAssertNotNil(managed.realm)
    XCTAssertEqual(managed.id, "item-1")
    XCTAssertEqual(managed.value, "new")
    XCTAssertEqual(persisted.value, "new")
  }

  // MARK: Private

  private func makeRealm() throws -> Realm {
    Container.shared.configureInMemoryDataStore()
    return try Realm(configuration: Container.shared.realmDataStoreConfiguration())
  }
}

// MARK: - ListUpsertTestParentEntity

@objc(ListUpsertTestParentEntity)
final class ListUpsertTestParentEntity: Object {
  @Persisted(primaryKey: true) var id = ""
  @Persisted var items = List<ListUpsertTestItemEntity>()
}

// MARK: - ListUpsertTestItemEntity

@objc(ListUpsertTestItemEntity)
final class ListUpsertTestItemEntity: Object {

  // MARK: Lifecycle

  convenience init(id: String, value: String) {
    self.init()
    self.id = id
    self.value = value
  }

  // MARK: Internal

  @Persisted(primaryKey: true) var id = ""
  @Persisted var value = ""

}
