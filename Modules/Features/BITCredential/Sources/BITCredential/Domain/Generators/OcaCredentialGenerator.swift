import BITAnyCredentialFormat
import BITCore
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
    let clusters = try ocaClusterGenerator.generate(
      from: primaryCredential.getClaimsJSON(.nonTechnical),
      credentialFormat: primaryCredential.format,
      ocaBundle: ocaBundle)
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
      selectedConfigurationId: context.credentialConfigurationId,
      issuerDisplays: context.issuerDisplays,
      displays: credentialDisplays,
      keyBindings: keyBindings,
      rawCredentialData: context.rawCredentialData,
      authentication: context.authentication)
  }

  // MARK: Private

  @Injected(\.captureBaseDisplayGenerator) private var captureBaseDisplayGenerator: CaptureBaseDisplayGeneratorProtocol
  @Injected(\.ocaClusterGenerator) private var ocaClusterGenerator: OcaClusterGeneratorProtocol

  private func createBundleItems(from credentialsWithKeyBinding: [CredentialWithKeyBinding]) throws -> [BundleItem] {
    try credentialsWithKeyBinding.map { credentialWithKeyBinding in
      guard let payload = credentialWithKeyBinding.credential.raw.data(using: .utf8) else {
        throw CredentialError.invalidPayload
      }
      return BundleItem(payload: payload, status: .unknown, keyBinding: credentialWithKeyBinding.keyBinding)
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
