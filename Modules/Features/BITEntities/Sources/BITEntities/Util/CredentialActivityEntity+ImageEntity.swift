extension CredentialActivityEntity {
  public var actorImages: Set<String> {
    Set(actorDisplays.compactMap(\.imageHash))
  }
}

extension Sequence<CredentialActivityEntity> {
  public func actorImages() -> Set<String> {
    reduce(into: Set<String>()) { result, activity in
      result.formUnion(activity.actorImages)
    }
  }
}
