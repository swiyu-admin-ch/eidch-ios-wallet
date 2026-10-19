import Factory
import Foundation
import Realm
import RealmSwift

// MARK: - RealmDataStore

public struct RealmDataStore: RealmDataStoreProtocol {

  // MARK: Public

  public func get<T: RealmFetchable>(_ type: T.Type, configuration: Realm.Configuration) throws -> Results<T> {
    let realm = try Realm(configuration: configuration)
    return realm.objects(type)
  }

  public func get<T: RealmSwiftObject>(_ type: T.Type, forPrimaryKey key: some Any, configuration: Realm.Configuration) throws -> T? {
    let realm = try Realm(configuration: configuration)
    return realm.object(ofType: type.self, forPrimaryKey: key)
  }

  public func save(_ object: some Object, policy: Realm.UpdatePolicy, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.add(object, update: policy)
    }
  }

  public func save(_ objects: [some Object], policy: Realm.UpdatePolicy, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.add(objects, update: policy)
    }
  }

  public func delete(_ object: some Object, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      delete(object, from: realm, configuration: configuration)
    }
  }

  public func delete(_ objects: [some Object], configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      for object in objects {
        delete(object, from: realm, configuration: configuration)
      }
    }
  }

  public func delete(_ objects: Results<some Object>, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      for object in objects {
        delete(object, from: realm, configuration: configuration)
      }
    }
  }

  @discardableResult
  public func write<Result>(configuration: Realm.Configuration, _ block: () throws -> Result) throws -> Result {
    let realm = try Realm(configuration: configuration)
    return try realm.write(block)
  }

  // MARK: Private

  @Injected(\.contentHasher) private var contentHasher

  /// Content-hashed children are shared by every owner of the same content, so a delete stops at
  /// them instead of cascading into rows another owner still points at.
  private func delete(_ object: some Object, from realm: Realm, configuration: Realm.Configuration) {
    for property in object.objectSchema.properties {
      guard property.objectClassName != nil, property.type != .linkingObjects else { continue }

      if let childObject = object[property.name] as? Object {
        guard !contentHasher.isContentHashed(childObject) else { continue }
        delete(childObject, from: realm, configuration: configuration)
      } else if property.isArray {
        let childList = object.dynamicList(property.name)
        for child in childList where !contentHasher.isContentHashed(child) {
          delete(child, from: realm, configuration: configuration)
        }
      }
    }
    realm.delete(object)
  }
}
