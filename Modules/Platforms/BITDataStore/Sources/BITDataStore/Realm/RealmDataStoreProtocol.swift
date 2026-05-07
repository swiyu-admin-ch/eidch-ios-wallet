import Factory
import Foundation
import Realm
import RealmSwift

// MARK: - RealmDataStoreProtocol

public protocol RealmDataStoreProtocol {
  func get<T: RealmFetchable>(_ type: T.Type, configuration: Realm.Configuration) throws -> Results<T>
  func get<T: RealmSwiftObject>(_ type: T.Type, forPrimaryKey: some Any, configuration: Realm.Configuration) throws -> T?

  func save(_ object: Object, policy: Realm.UpdatePolicy, configuration: Realm.Configuration) throws
  func save(_ objects: [Object], policy: Realm.UpdatePolicy, configuration: Realm.Configuration) throws

  func delete(_ object: Object, configuration: Realm.Configuration) throws
  func delete(_ objects: [Object], configuration: Realm.Configuration) throws
  func delete(_ objects: Results<some Object>, configuration: Realm.Configuration) throws

  @discardableResult
  func write<Result>(configuration: Realm.Configuration, _ block: () throws -> Result) throws -> Result
}

extension RealmDataStoreProtocol {

  public func get<T: RealmFetchable>(_ type: T.Type) throws -> Results<T> {
    try get(type, configuration: Container.shared.realmDataStoreConfiguration())
  }

  public func get<T: RealmSwiftObject>(_ type: T.Type, forPrimaryKey: some Any) throws -> T? {
    try get(type, forPrimaryKey: forPrimaryKey, configuration: Container.shared.realmDataStoreConfiguration())
  }

  public func save(_ object: Object) throws {
    try save(object, policy: .all, configuration: Container.shared.realmDataStoreConfiguration())
  }

  public func save(_ objects: [Object]) throws {
    try save(objects, policy: .all, configuration: Container.shared.realmDataStoreConfiguration())
  }

  public func delete(_ object: Object) throws {
    try delete(object, configuration: Container.shared.realmDataStoreConfiguration())
  }

  public func delete(_ objects: [Object]) throws {
    try delete(objects, configuration: Container.shared.realmDataStoreConfiguration())
  }

  public func delete(_ objects: Results<some Object>) throws {
    try delete(objects, configuration: Container.shared.realmDataStoreConfiguration())
  }

  @discardableResult
  public func write<Result>(_ block: () throws -> Result) throws -> Result {
    try write(configuration: Container.shared.realmDataStoreConfiguration(), block)
  }

}
