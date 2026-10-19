extension CredentialRenderingEntity {

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

extension CredentialEntity {
  public var displayImages: Set<String> {
    credentialRendering?.displayImages ?? []
  }
}

extension Sequence<CredentialRenderingEntity> {
  public func displayImages() -> Set<String> {
    reduce(into: Set<String>()) { result, rendering in
      result.formUnion(rendering.displayImages)
    }
  }
}
