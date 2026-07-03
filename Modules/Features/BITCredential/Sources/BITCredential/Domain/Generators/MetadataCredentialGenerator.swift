import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITCore
import BITCredentialShared
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - MetadataCredentialGeneratorProtocol

@Spyable
protocol MetadataCredentialGeneratorProtocol {
  func generate(for credentialsWithKeyBinding: [CredentialWithKeyBinding], selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported, context: CredentialGeneratorContext) throws -> VerifiableCredential
  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBindings: [KeyBinding],
    selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported,
    context: CredentialGeneratorContext) throws
    -> DeferredCredential
}

// MARK: - MetadataCredentialGenerator

struct MetadataCredentialGenerator: MetadataCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for credentialsWithKeyBinding: [CredentialWithKeyBinding], selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported, context: CredentialGeneratorContext) throws -> VerifiableCredential {
    guard let primaryCredentialWithKeyBinding = credentialsWithKeyBinding.first else {
      throw CredentialError.invalidPayload
    }

    // For now we assume all credentials in the batch are equivalent and use the first.
    // Claim equality across credentials will be validated in a future iteration.
    let primaryCredential = primaryCredentialWithKeyBinding.credential
    let cluster = try createCluster(from: primaryCredential.getClaimsJSON(.nonTechnical), metadataClaims: selectedCredential.credentialMetadata?.claims ?? [])
    let credentialDisplays = createCredentialDisplays(from: selectedCredential.credentialMetadata?.display, credentialId: context.credentialId)

    let bundleItems = try createBundleItems(from: credentialsWithKeyBinding)

    guard let firstBundleItem = bundleItems.first else {
      throw CredentialError.invalidPayload
    }

    return VerifiableCredential(
      id: context.credentialId,
      progressionState: .unaccepted,
      bundleItems: bundleItems,
      nextPresentableBundleItemId: firstBundleItem.id,
      clusters: [cluster],
      format: primaryCredential.format,
      issuerUrl: context.issuerUrl,
      selectedConfigurationId: context.credentialConfigurationId,
      issuer: primaryCredential.issuer,
      batchData: context.batchData,
      authentication: context.authentication,
      rawCredentialData: context.rawCredentialData,
      issuerDisplays: context.issuerDisplays,
      displays: credentialDisplays,
      validFrom: primaryCredential.validFrom,
      validUntil: primaryCredential.validUntil)
  }

  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBindings: [KeyBinding],
    selectedCredential: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported,
    context: CredentialGeneratorContext) throws
    -> DeferredCredential
  {
    let credentialDisplays = createCredentialDisplays(from: selectedCredential.credentialMetadata?.display, credentialId: context.credentialId)

    return DeferredCredential(
      transactionId: deferredCredentialContext.transactionId,
      endpoint: deferredCredentialContext.endpoint,
      format: deferredCredentialContext.format,
      issuerUrl: context.issuerUrl,
      selectedConfigurationId: context.credentialConfigurationId,
      issuerDisplays: context.issuerDisplays,
      displays: credentialDisplays,
      keyBindings: keyBindings,
      rawCredentialData: context.rawCredentialData,
      authentication: context.authentication)
  }

  // MARK: Private

  @Injected(\.imageValidator) private var imageValidator: ImageValidatorProtocol
  @Injected(\.valueTypeResolver) private var valueTypeResolver: ValueTypeResolverProtocol

  private func createBundleItems(from credentialsWithKeyBinding: [CredentialWithKeyBinding]) throws -> [BundleItem] {
    try credentialsWithKeyBinding.map { credentialWithKeyBinding in
      guard let payload = credentialWithKeyBinding.credential.raw.data(using: .utf8) else {
        throw CredentialError.invalidPayload
      }
      return BundleItem(payload: payload, status: .unknown, keyBinding: credentialWithKeyBinding.keyBinding)
    }
  }

  private func createCluster(
    from object: JSON,
    metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim],
    path: ClaimsPathPointer = [],
    order: Int? = nil) throws
    -> CredentialClaimCluster
  {
    let elements = try Array(object).compactMap { entry in
      let path = path + [.string(entry.key)]
      return try createElement(
        from: entry.value,
        path: path,
        metadataClaims: metadataClaims,
        order: getOrder(for: path, in: metadataClaims))
    }

    return CredentialClaimCluster(
      path: path,
      order: order ?? Int(Int16.max),
      claims: elements.compactMap(\.claim),
      childClusters: elements.compactMap(\.cluster),
      displays: createClusterDisplays(for: path, metadataClaims: metadataClaims))
  }

  private func createArrayCluster(
    from array: [Any],
    metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim],
    path: ClaimsPathPointer,
    order: Int) throws
    -> CredentialClaimCluster
  {
    let arrayPath = path + [.null]
    let elements = try array.enumerated().map { index, element in
      try createElement(
        from: element,
        path: path + [.index(index)],
        metadataClaims: metadataClaims,
        order: index)
    }

    return CredentialClaimCluster(
      path: arrayPath,
      order: order,
      claims: elements.compactMap(\.claim),
      childClusters: elements.compactMap(\.cluster),
      displays: createClusterDisplays(for: arrayPath, metadataClaims: metadataClaims))
  }

  private func createElement(
    from element: Any,
    path: ClaimsPathPointer,
    metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim],
    order: Int) throws
    -> GeneratedElement
  {
    if let object = element as? JSON {
      return try .cluster(createCluster(
        from: object,
        metadataClaims: metadataClaims,
        path: path,
        order: order))
    }

    if let array = element as? [Any] {
      return try .cluster(createArrayCluster(
        from: array,
        metadataClaims: metadataClaims,
        path: path,
        order: order))
    }

    let metadataClaim = getMetadataClaim(for: path, metadataClaims)
    return try .claim(createClaim(
      from: element,
      path: path,
      metadataClaim: metadataClaim,
      order: order))
  }

  private func getMetadataClaim(
    for path: ClaimsPathPointer,
    _ metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim])
    -> CredentialIssuerMetadata.CredentialMetadata.Claim?
  {
    metadataClaims.first(where: { metadataClaim in
      metadataClaim.path.last != .null && metadataClaim.path.pointsAtSetOf(path, enforceLength: true)
    })
  }

  private func createClaim(
    from value: Any,
    path: ClaimsPathPointer,
    metadataClaim: CredentialIssuerMetadata.CredentialMetadata.Claim?,
    order: Int) throws
    -> CredentialClaim
  {
    let valueType = valueTypeResolver(value) ?? .string
    let claimValue = getClaimValue(from: value, valueType: valueType)

    if valueType.isImage, let claimValue {
      try imageValidator.validate(base64Image: claimValue, against: valueType)
    }

    return CredentialClaim(
      path: path,
      value: claimValue,
      valueType: valueType.rawValue,
      order: order,
      displays: createClaimDisplays(from: metadataClaim?.display))
  }

  private func createClaimDisplays(from displays: [CredentialIssuerMetadata.CredentialMetadata.Claim.Display]?) -> [CredentialClaimDisplay] {
    displays?.map { display in
      CredentialClaimDisplay(locale: display.locale, name: display.name)
    } ?? []
  }

  private func createCredentialDisplays(from displays: [CredentialIssuerMetadata.CredentialMetadata.Display]?, credentialId: UUID) -> [CredentialDisplay] {
    displays?.map { display in
      CredentialDisplay(
        name: display.name,
        backgroundColor: display.backgroundColor,
        locale: display.locale ?? UserLocale.defaultLocaleIdentifier,
        logoAltText: display.logo?.altText,
        logoBase64: display.logo?.url?.dataURLData,
        summary: display.description,
        credentialId: credentialId)
    } ?? []
  }

  private func getOrder(for path: ClaimsPathPointer, in claims: [CredentialIssuerMetadata.CredentialMetadata.Claim]) -> Int {
    claims.firstIndex(where: { $0.path.removedTrailingNull.pointsAtSetOf(path, enforceLength: true) }) ?? Int(Int16.max)
  }

  private func getClaimValue(from value: Any, valueType: ValueType) -> String? {
    let primitiveString = JsonPrimitive(value)?.stringValue

    if
      valueType.isImage,
      let primitiveString,
      let imageValue = URL(string: primitiveString)?.dataURLDataString
    {
      return imageValue
    }

    return primitiveString
  }

  private func createClusterDisplays(for path: ClaimsPathPointer, metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim]) -> [ClusterDisplay]
  {
    let metadataClaim = metadataClaims.first(where: { $0.path.removedTrailingNull == path.removedTrailingNull })

    return metadataClaim?.display?.compactMap { display in
      guard let name = display.name else {
        return nil
      }
      return ClusterDisplay(locale: display.locale ?? UserLocale.defaultLocaleIdentifier, name: name)
    } ?? []
  }
}
