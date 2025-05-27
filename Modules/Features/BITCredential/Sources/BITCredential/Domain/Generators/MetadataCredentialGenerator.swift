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
  func generate(for anyCredential: AnyCredential, id: UUID, keyPair: KeyPair?, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, issuerDisplays: [CredentialIssuerDisplay]) throws -> Credential
}

// MARK: - MetadataCredentialGenerator

struct MetadataCredentialGenerator: MetadataCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, id: UUID, keyPair: KeyPair?, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, issuerDisplays: [CredentialIssuerDisplay]) throws -> Credential {
    guard let payload = anyCredential.raw.data(using: .utf8) else {
      throw CredentialError.invalidPayload
    }
    let claims = try createClaims(from: anyCredential.claims, selectedCredential: selectedCredential, credentialId: id)
    let credentialDisplays = createCredentialDisplays(from: selectedCredential.display, credentialId: id)

    return Credential(
      id: id,
      status: .unknown,
      keyBindingIdentifier: keyPair?.identifier,
      keyBindingAlgorithm: keyPair?.algorithm,
      payload: payload,
      format: anyCredential.format,
      issuer: anyCredential.issuer,
      validFrom: anyCredential.validFrom,
      validUntil: anyCredential.validUntil,
      createdAt: Date(),
      updatedAt: nil,
      claims: claims,
      issuerDisplays: issuerDisplays,
      displays: credentialDisplays)
  }

  // MARK: Private

  private func createClaims(from anyClaims: [AnyClaim], selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, credentialId: UUID) throws -> [CredentialClaim] {
    var credentialClaims = [CredentialClaim]()
    for anyClaim in anyClaims {
      let metadataClaim = selectedCredential.claims.first(where: { $0.key == anyClaim.key })
      guard let credentialClaim = createClaim(from: anyClaim, metadataClaim: metadataClaim, credentialId: credentialId) else { continue }
      credentialClaims.append(credentialClaim)
    }
    return credentialClaims
  }

  private func createClaim(from anyClaim: AnyClaim, metadataClaim: CredentialMetadata.Claim?, credentialId: UUID) -> CredentialClaim? {
    guard let value = anyClaim.value?.rawValue else { return nil }
    let order = metadataClaim?.order ?? Int(Int16.max)
    let id = UUID()
    return CredentialClaim(
      id: id,
      key: anyClaim.key,
      valueType: metadataClaim?.valueType?.rawValue ?? ValueType.string.rawValue,
      value: value,
      order: Int16(order),
      credentialId: credentialId,
      displays: createClaimDisplays(from: metadataClaim, claimId: id))
  }

  private func createClaimDisplays(from metadataClaim: CredentialMetadata.Claim?, claimId: UUID) -> [CredentialClaimDisplay] {
    metadataClaim?.display?.map { display in
      CredentialClaimDisplay(locale: display.locale, name: display.name, claimId: claimId)
    } ?? []
  }

  private func createCredentialDisplays(from displays: [CredentialMetadata.CredentialSupportedDisplay]?, credentialId: UUID) -> [CredentialDisplay] {
    displays?.map { display in
      let logoBase64 = display.logo?.uri.flatMap { Data(base64Encoded: $0) }
      return CredentialDisplay(
        name: display.name,
        backgroundColor: display.backgroundColor,
        locale: display.locale ?? UserLocale.defaultLocaleIdentifier,
        logoAltText: display.logo?.altText,
        logoBase64: logoBase64,
        summary: display.summary,
        credentialId: credentialId)
    } ?? []
  }
}
