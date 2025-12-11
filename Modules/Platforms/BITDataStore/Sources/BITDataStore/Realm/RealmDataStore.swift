import Factory
import Foundation
import Realm
import RealmSwift

// MARK: - RealmDataStore

public class RealmDataStore: RealmDataStoreProtocol {

  // MARK: Lifecycle

  public init(configuration: Realm.Configuration = Container.shared.realmDataStoreConfiguration()) {
    self.configuration = configuration
  }

  // MARK: Public

  public func get<T>(_ type: T.Type, configuration: Realm.Configuration) throws -> Results<T> where T: RealmFetchable {
    let realm = try Realm(configuration: configuration)
    return realm.objects(type)
  }

  public func get<T>(_ type: T.Type, forPrimaryKey key: some Any, configuration: Realm.Configuration) throws -> T? where T: RealmSwiftObject {
    let realm = try Realm(configuration: configuration)
    return realm.object(ofType: type.self, forPrimaryKey: key)
  }

  public func save(_ data: some Object, policy: Realm.UpdatePolicy, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.add(data, update: policy)
    }
  }

  public func save(_ data: [some Object], policy: Realm.UpdatePolicy, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.add(data, update: policy)
    }
  }

  public func delete(_ data: some Object, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.delete(data)
    }
  }

  public func delete(_ data: [some Object], configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.delete(data)
    }
  }

  public func delete(_ data: Results<some Object>, configuration: Realm.Configuration) throws {
    let realm = try Realm(configuration: configuration)
    try realm.write {
      realm.delete(data)
    }
  }

  @discardableResult
  public func write<Result>(configuration: Realm.Configuration, _ block: () throws -> Result) throws -> Result {
    let realm = try Realm(configuration: configuration)
    return try realm.write(block)
  }

  // MARK: Private

  private let configuration: Realm.Configuration

}
