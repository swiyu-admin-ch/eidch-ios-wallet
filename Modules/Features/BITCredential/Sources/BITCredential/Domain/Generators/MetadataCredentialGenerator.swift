import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITCrypto
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - MetadataCredentialGeneratorProtocol

@Spyable
protocol MetadataCredentialGeneratorProtocol {
  func generate(for anyCredential: AnyCredential, id: UUID, keyBinding: CredentialKeyBinding?, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, issuerDisplays: [CredentialIssuerDisplay], rawCredentialData: RawCredentialData) throws -> Credential
}

// MARK: - MetadataCredentialGenerator

struct MetadataCredentialGenerator: MetadataCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, id: UUID, keyBinding: CredentialKeyBinding?, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, issuerDisplays: [CredentialIssuerDisplay], rawCredentialData: RawCredentialData) throws -> Credential {
    guard let payload = anyCredential.raw.data(using: .utf8) else {
      throw CredentialError.invalidPayload
    }
    let cluster = createCluster(from: anyCredential.claims, selectedCredential: selectedCredential)
    let credentialDisplays = createCredentialDisplays(from: selectedCredential.display, credentialId: id)

    return Credential(
      id: id,
      status: .unknown,
      keyBinding: keyBinding,
      payload: payload,
      rawCredentialData: rawCredentialData,
      format: anyCredential.format,
      issuer: anyCredential.issuer,
      validFrom: anyCredential.validFrom,
      validUntil: anyCredential.validUntil,
      createdAt: Date(),
      updatedAt: nil,
      clusters: [cluster],
      issuerDisplays: issuerDisplays,
      displays: credentialDisplays)
  }

  // MARK: Private

  private func createCluster(from anyClaims: [AnyClaim], selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported) -> CredentialClaimCluster {
    let claims = anyClaims.map { anyClaim in
      let metadataClaim = selectedCredential.claims.first(where: { "$." + $0.key == anyClaim.key })
      return createClaim(from: anyClaim, metadataClaim: metadataClaim)
    }
    return CredentialClaimCluster(claims: claims)
  }

  private func createClaim(from anyClaim: AnyClaim, metadataClaim: CredentialMetadata.Claim?) -> CredentialClaim {
    CredentialClaim(
      key: anyClaim.key.replacing("$.", with: ""),
      value: anyClaim.value?.rawValue,
      valueType: metadataClaim?.valueType?.rawValue ?? ValueType.string.rawValue,
      order: metadataClaim?.order ?? Int(Int16.max),
      displays: createClaimDisplays(from: metadataClaim))
  }

  private func createClaimDisplays(from metadataClaim: CredentialMetadata.Claim?) -> [CredentialClaimDisplay] {
    metadataClaim?.display?.map { display in
      CredentialClaimDisplay(locale: display.locale, name: display.name)
    } ?? []
  }

  private func createCredentialDisplays(from displays: [CredentialMetadata.CredentialSupportedDisplay]?, credentialId: UUID) -> [CredentialDisplay] {
    displays?.map { display in
      CredentialDisplay(
        name: display.name,
        backgroundColor: display.backgroundColor,
        locale: display.locale ?? UserLocale.defaultLocaleIdentifier,
        logoAltText: display.logo?.altText,
        logoBase64: display.logo?.url?.dataURLData,
        summary: display.summary,
        credentialId: credentialId)
    } ?? []
  }
}
