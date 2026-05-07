import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITCredentialShared
import BITOca
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - OcaCredentialGeneratorProtocol

@Spyable
protocol OcaCredentialGeneratorProtocol {
  func generate(for credentialsWithKeyBinding: [CredentialWithKeyBinding], ocaBundle: OcaBundle, context: CredentialGeneratorContext) throws -> VerifiableCredential
  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBindings: [KeyBinding],
    ocaBundle: OcaBundle,
    context: CredentialGeneratorContext) throws
    -> DeferredCredential
}

// MARK: - OcaCredentialGenerator

struct OcaCredentialGenerator: OcaCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for credentialsWithKeyBinding: [CredentialWithKeyBinding], ocaBundle: OcaBundle, context: CredentialGeneratorContext) throws -> VerifiableCredential {
    guard let primaryCredentialWithKeyBinding = credentialsWithKeyBinding.first else {
      throw CredentialError.invalidPayload
    }

    // For now we assume all credentials in the batch are equivalent and use the first.
    // Claim equality across credentials will be validated in a future iteration.
    let primaryCredential = primaryCredentialWithKeyBinding.credential
    let clusters = try createClusters(from: primaryCredential.claims, credentialFormat: primaryCredential.format, ocaBundle: ocaBundle)
    let captureBaseDisplays = captureBaseDisplayGenerator.generate(from: ocaBundle)
      .filter { $0.captureBaseDigest == ocaBundle.rootCaptureBaseDigest }
    let credentialDisplays = createCredentialDisplays(from: captureBaseDisplays, credentialId: context.credentialId)

    let bundleItems = try createBundleItems(from: credentialsWithKeyBinding)

    guard let firstBundleItem = bundleItems.first else {
      throw CredentialError.invalidPayload
    }

    return VerifiableCredential(
      id: context.credentialId,
      progressionState: .unaccepted,
      bundleItems: bundleItems,
      nextPresentableBundleItemId: firstBundleItem.id,
      clusters: clusters,
      format: primaryCredential.format,
      issuerUrl: context.issuerUrl,
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
    ocaBundle: OcaBundle,
    context: CredentialGeneratorContext) throws
    -> DeferredCredential
  {
    let captureBaseDisplays = captureBaseDisplayGenerator.generate(from: ocaBundle)
      .filter { $0.captureBaseDigest == ocaBundle.rootCaptureBaseDigest }
    let credentialDisplays = createCredentialDisplays(from: captureBaseDisplays, credentialId: context.credentialId)

    return DeferredCredential(
      transactionId: deferredCredentialContext.transactionId,
      endpoint: deferredCredentialContext.endpoint,
      format: deferredCredentialContext.format,
      issuerUrl: context.issuerUrl,
      issuerDisplays: context.issuerDisplays,
      displays: credentialDisplays,
      keyBindings: keyBindings,
      rawCredentialData: context.rawCredentialData,
      authentication: CredentialAuthentication(accessToken: deferredCredentialContext.accessToken, refreshToken: deferredCredentialContext.refreshToken))
  }

  // MARK: Private

  @Injected(\.captureBaseDisplayGenerator) private var captureBaseDisplayGenerator: CaptureBaseDisplayGeneratorProtocol
  @Injected(\.ocaClaimGenerator) private var ocaClaimGenerator: OcaClaimGeneratorProtocol

  private func createBundleItems(from credentialsWithKeyBinding: [CredentialWithKeyBinding]) throws -> [BundleItem] {
    try credentialsWithKeyBinding.map { credentialWithKeyBinding in
      guard let payload = credentialWithKeyBinding.credential.raw.data(using: .utf8) else {
        throw CredentialError.invalidPayload
      }
      return BundleItem(payload: payload, status: .unknown, keyBinding: credentialWithKeyBinding.keyBinding)
    }
  }

  private func createClusters(from claims: [any AnyClaim], credentialFormat: String, ocaBundle: OcaBundle) throws -> [CredentialClaimCluster] {
    let rootCluster = try createCluster(for: ocaBundle.rootCaptureBaseDigest, claims: claims, credentialFormat: credentialFormat, ocaBundle: ocaBundle)
    let clusters = rootCluster.claims.isEmpty && !rootCluster.childClusters.isEmpty ? rootCluster.childClusters : [rootCluster] // drop root cluster if there are only child clusters as there are no additional info on it (order & displays are not set)

    let attributes = ocaBundle.getAttributes()
    let claimsWithoutOca = claims.filter { claim in
      !attributes.contains(where: { $0.dataSources[credentialFormat]?.isPointing(at: claim.path) == true })
    }.compactMap(CredentialClaim.init)

    if claimsWithoutOca.isEmpty {
      return clusters
    }
    let additionalCluster = CredentialClaimCluster(claims: claimsWithoutOca)
    return clusters + [additionalCluster]
  }

  private func createCluster(for captureBaseDigest: String, claims: [any AnyClaim], credentialFormat: String, ocaBundle: OcaBundle, labels: [String: String] = [:], order: Int? = nil) throws -> CredentialClaimCluster {
    let attributes = ocaBundle.getAttributes(digest: captureBaseDigest)
    let childClusters = try createChildClusters(for: attributes, claims: claims, credentialFormat: credentialFormat, ocaBundle: ocaBundle)
    let claims = try createClaims(for: attributes, claims: claims, credentialFormat: credentialFormat)
    return CredentialClaimCluster(
      order: order ?? Int(Int16.max),
      claims: claims,
      childClusters: childClusters,
      displays: labels.map { locale, label in ClusterDisplay(locale: locale, name: label) })
  }

  private func createChildClusters(for attributes: [OverlayBundleAttribute], claims: [any AnyClaim], credentialFormat: String, ocaBundle: OcaBundle) throws -> [CredentialClaimCluster] {
    try attributes.compactMap { attribute in
      if case .reference(let digest) = attribute.attributeType {
        return try createCluster(for: digest, claims: claims, credentialFormat: credentialFormat, ocaBundle: ocaBundle, labels: attribute.labels, order: attribute.order)
      }
      return nil // only reference create child clusters
    }
  }

  private func createClaims(for ocaAttributes: [OverlayBundleAttribute], claims: [any AnyClaim], credentialFormat: String) throws -> [CredentialClaim] {
    try ocaAttributes.compactMap { attribute in
      guard !attribute.attributeType.isReferenceType else { return nil }
      guard
        let attributePath = attribute.dataSources[credentialFormat],
        let anyClaim = claims.first(where: { attributePath.isPointing(at: $0.path) })
      else { return nil }

      return try ocaClaimGenerator.generate(for: anyClaim, ocaAttribute: attribute)
    }
  }

  private func createCredentialDisplays(from displays: [CaptureBaseDisplay], credentialId: UUID) -> [CredentialDisplay] {
    displays.map { display in
      CredentialDisplay(
        name: display.metaName,
        backgroundColor: display.primaryBackgroundColor,
        theme: display.theme,
        locale: display.language,
        logoBase64: display.logo?.dataURLData,
        summary: display.primaryField ?? display.metaDescription,
        credentialId: credentialId)
    }
  }

}

extension AttributeType {
  fileprivate var isReferenceType: Bool {
    if case .reference = self {
      return true
    }
    return false
  }
}

extension CredentialClaim {

  #warning("AnyClaim only supports primitive value type for now")
  fileprivate init(_ anyClaim: AnyClaim) {
    self.init(
      path: anyClaim.path,
      value: anyClaim.value?.rawValue,
      order: Int(Int16.max))
  }
}
