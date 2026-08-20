extension CredentialEntity {

  // MARK: Public

  public var displayImages: Set<String> {
    issuerDisplayImages.union(credentialDisplayImages)
  }

  // MARK: Private

  private var issuerDisplayImages: Set<String> {
    Set(issuerDisplays.compactMap(\.imageHash))
  }

  private var credentialDisplayImages: Set<String> {
    Set(displays.compactMap(\.logoDataHash))
  }
}

extension Sequence<CredentialEntity> {
  public func displayImages() -> Set<String> {
    reduce(into: Set<String>()) { result, credential in
      result.formUnion(credential.displayImages)
    }
  }
}
