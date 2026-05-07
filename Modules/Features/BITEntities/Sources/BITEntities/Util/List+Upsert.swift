import RealmSwift

extension List where Element: Object {

  public func replaceWithUpserted(_ objects: [Element], in realm: Realm?) {
    removeAll()

    guard let realm else {
      append(objectsIn: objects)
      return
    }

    for object in objects {
      let managedObject = realm.create(Element.self, value: object, update: .modified)
      append(managedObject)
    }
  }
}

extension Object {

  public func upserted(in realm: Realm?) -> Self {
    guard let realm else { return self }
    return realm.create(Self.self, value: self, update: .modified)
  }
}
