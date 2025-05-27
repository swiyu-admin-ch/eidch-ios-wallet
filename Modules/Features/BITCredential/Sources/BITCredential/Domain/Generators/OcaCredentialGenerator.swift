import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITCrypto
import BITOca
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - OcaCredentialGeneratorProtocol

@Spyable
protocol OcaCredentialGeneratorProtocol {
  func generate(for anyCredential: AnyCredential, id: UUID, keyPair: KeyPair?, ocaBundle: OcaBundle, issuerDisplays: [CredentialIssuerDisplay]) throws -> Credential
}

// MARK: - OcaCredentialGenerator

struct OcaCredentialGenerator: OcaCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, id: UUID, keyPair: KeyPair?, ocaBundle: OcaBundle, issuerDisplays: [CredentialIssuerDisplay]) throws -> Credential {
    guard let payload = anyCredential.raw.data(using: .utf8) else {
      throw CredentialError.invalidPayload
    }
    let claims = try createClaims(from: anyCredential.claims, ocaBundle: ocaBundle, credentialId: id)
    let credentialDisplays = createCredentialDisplays(from: nil, credentialId: id)

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

  private func createClaims(from anyClaims: [AnyClaim], ocaBundle: OcaBundle, credentialId: UUID) throws -> [CredentialClaim] {
    var credentialClaims = [CredentialClaim]()
    for anyClaim in anyClaims {
      let ocaClaim = ocaBundle.getAttributeForJsonPath(jsonPath: "$." + anyClaim.key)
      guard let credentialClaim = createClaim(from: anyClaim, ocaClaim: ocaClaim, credentialId: credentialId) else { continue }
      credentialClaims.append(credentialClaim)
    }
    return credentialClaims
  }

  private func createClaim(from anyClaim: AnyClaim, ocaClaim: OverlayBundleAttribute?, credentialId: UUID) -> CredentialClaim? {
    guard let value = anyClaim.value?.rawValue else { return nil }
    let order = Int(Int16.max)
    let id = UUID()
    return CredentialClaim(
      id: id,
      key: anyClaim.key,
      valueType: ValueType(ocaClaim?.attributeType).rawValue,
      value: value,
      order: Int16(order),
      credentialId: credentialId,
      displays: createClaimDisplays(from: ocaClaim, claimId: id))
  }

  private func createClaimDisplays(from ocaClaim: OverlayBundleAttribute?, claimId: UUID) -> [CredentialClaimDisplay] {
    ocaClaim?.labels.map { label in
      CredentialClaimDisplay(locale: label.key, name: label.value, claimId: claimId)
    } ?? []
  }

  private func createCredentialDisplays(from overlays: [any Overlay]?, credentialId: UUID) -> [CredentialDisplay] {
    overlays?.compactMap { _ in
      nil
//      let logoBase64 = overlay.logo?.uri.flatMap { Data(base64Encoded: $0) }
//      return CredentialDisplay(
//        name: overlay.name,
//        backgroundColor: display.backgroundColor,
//        locale: overlay.locale ?? UserLocale.defaultLocaleIdentifier,
//        logoAltText: overlay.logo?.altText,
//        logoBase64: logoBase64,
//        summary: overlay.summary,
//        credentialId: credentialId)
    } ?? []
  }
}

extension ValueType {

  init(_ attributeType: AttributeType?) {
    guard let attributeType else {
      self = .string
      return
    }
    self = switch attributeType {
    case .text:
      .string
    case .boolean:
      .boolean
    case .array,
         .binary,
         .dateTime,
         .numeric,
         .reference:
      .string
    }
  }
}
