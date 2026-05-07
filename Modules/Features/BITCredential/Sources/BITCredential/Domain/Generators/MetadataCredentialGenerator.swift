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
    let cluster = try createCluster(from: primaryCredential.claims, metadataClaims: selectedCredential.credentialMetadata?.claims)
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
      authentication: CredentialAuthentication(accessToken: deferredCredentialContext.accessToken, refreshToken: deferredCredentialContext.refreshToken))
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

  private func createCluster(from anyClaims: [AnyClaim], metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim]?) throws -> CredentialClaimCluster {
    #warning("object and array claims will be implemented in a future story")
    let credentialClaim = try anyClaims.map { anyClaim in
      let metadataClaim = getMetadataClaim(from: anyClaim, metadataClaims ?? [])
      var index = Int(Int16.max)
      if let metadataClaim {
        index = metadataClaims?.firstIndex(of: metadataClaim) ?? Int(Int16.max)
      }

      return try createClaim(anyClaim: anyClaim, metadataClaim: metadataClaim, index: index)
    }

    return CredentialClaimCluster(claims: credentialClaim)
  }

  private func getMetadataClaim(
    from anyClaim: AnyClaim,
    _ metadataClaims: [CredentialIssuerMetadata.CredentialMetadata.Claim])
    -> CredentialIssuerMetadata.CredentialMetadata.Claim?
  {
    metadataClaims.first(where: { metadataClaim in
      guard
        let keyElement = metadataClaim.path.last,
        case .string(let key) = keyElement
      else {
        return false
      }

      return key == anyClaim.key
    })
  }

  private func createClaim(
    anyClaim: AnyClaim,
    metadataClaim: CredentialIssuerMetadata.CredentialMetadata.Claim?,
    index: Int)
    throws -> CredentialClaim
  {
    let valueType = valueTypeResolver(anyClaim) ?? .string
    let value = getClaimValue(from: anyClaim, valueType: valueType)

    if valueType.isImage, let value {
      try imageValidator.validate(base64Image: value, against: valueType)
    }

    return CredentialClaim(
      path: metadataClaim?.path ?? [ClaimsPathPointerElement.string(anyClaim.key)],
      value: value,
      valueType: valueType.rawValue,
      order: index,
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

  private func getClaimValue(from anyClaim: AnyClaim, valueType: ValueType) -> String? {
    guard let value = anyClaim.value else { return nil }

    if
      valueType.isImage,
      case .string(let stringValue) = value,
      let imageValue = URL(string: stringValue)?.dataURLDataString
    {
      return imageValue
    }

    return value.rawValue
  }
}
