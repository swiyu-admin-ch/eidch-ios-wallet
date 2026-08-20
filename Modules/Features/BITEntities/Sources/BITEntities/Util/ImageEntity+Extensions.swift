import BITDataStore

extension RealmDataStoreProtocol {

  // MARK: Public

  public func removeUnreferencedImages(_ hashes: Set<String>) throws {
    guard !hashes.isEmpty else { return }

    let referencedImages = try getReferencedImages()
    let unreferencedImages = hashes.subtracting(referencedImages)

    for hash in unreferencedImages {
      guard let image = try get(ImageEntity.self, forPrimaryKey: hash) else { continue }
      try delete(image)
    }
  }

  // MARK: Private

  private func getReferencedImages() throws -> Set<String> {
    let activityImages = try get(CredentialActivityEntity.self).actorImages()
    let credentialImages = try get(CredentialEntity.self).displayImages()
    return activityImages.union(credentialImages)
  }
}
