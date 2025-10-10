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
  func generate(for anyCredential: AnyCredential, id: UUID, keyBinding: CredentialKeyBinding?, ocaBundle: OcaBundle, issuerDisplays: [CredentialIssuerDisplay], rawCredentialData: RawCredentialData) throws -> VerifiableCredential
}

// MARK: - OcaCredentialGenerator

struct OcaCredentialGenerator: OcaCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, id: UUID, keyBinding: CredentialKeyBinding?, ocaBundle: OcaBundle, issuerDisplays: [CredentialIssuerDisplay], rawCredentialData: RawCredentialData) throws -> VerifiableCredential {
    guard let payload = anyCredential.raw.data(using: .utf8) else {
      throw CredentialError.invalidPayload
    }
    let clusters = createClusters(from: anyCredential.claims, ocaBundle: ocaBundle)
    let captureBaseDisplays = captureBaseDisplayGenerator.generate(from: ocaBundle)
      .filter { $0.captureBaseDigest == ocaBundle.rootCaptureBaseDigest }
    let credentialDisplays = createCredentialDisplays(from: captureBaseDisplays, credentialId: id)

    return VerifiableCredential(
      id: id,
      payload: payload,
      status: .unknown,
      clusters: clusters,
      format: anyCredential.format,
      issuer: anyCredential.issuer,
      keyBinding: keyBinding,
      rawCredentialData: rawCredentialData,
      issuerDisplays: issuerDisplays,
      displays: credentialDisplays,
      validFrom: anyCredential.validFrom,
      validUntil: anyCredential.validUntil)
  }

  // MARK: Private

  @Injected(\.captureBaseDisplayGenerator) private var captureBaseDisplayGenerator: CaptureBaseDisplayGeneratorProtocol
  @Injected(\.ocaClaimGenerator) private var ocaClaimGenerator: OcaClaimGeneratorProtocol

  private func createClusters(from claims: [any AnyClaim], ocaBundle: OcaBundle) -> [CredentialClaimCluster] {
    let rootCluster = createCluster(for: ocaBundle.rootCaptureBaseDigest, claims: claims, ocaBundle: ocaBundle)
    let clusters = rootCluster.claims.isEmpty && !rootCluster.childClusters.isEmpty ? rootCluster.childClusters : [rootCluster] // drop root cluster if there are only child clusters as there are no additional info on it (order & displays are not set)

    let claimsWithoutOca = claims.filter {
      guard let jsonPath = (try? JsonPath(rawString: $0.key)) else { return true }
      return ocaBundle.getAttributeForJsonPath(jsonPath: jsonPath) == nil
    }.compactMap(CredentialClaim.init)

    if claimsWithoutOca.isEmpty {
      return clusters
    }
    let additionalCluster = CredentialClaimCluster(claims: claimsWithoutOca)
    return clusters + [additionalCluster]
  }

  private func createCluster(for captureBaseDigest: String, claims: [any AnyClaim], ocaBundle: OcaBundle, labels: [String: String] = [:], order: Int? = nil) -> CredentialClaimCluster {
    let attributes = ocaBundle.getAttributes(digest: captureBaseDigest)
    let childClusters = createChildClusters(for: attributes, claims: claims, ocaBundle: ocaBundle)
    let claims = createClaims(for: attributes, claims: claims)
    return CredentialClaimCluster(
      order: order ?? Int(Int16.max),
      claims: claims,
      childClusters: childClusters,
      displays: labels.map { locale, label in ClusterDisplay(locale: locale, name: label) })
  }

  private func createChildClusters(for attributes: [OverlayBundleAttribute], claims: [AnyClaim], ocaBundle: OcaBundle) -> [CredentialClaimCluster] {
    attributes.compactMap { attribute in
      if case .reference(let digest) = attribute.attributeType {
        return createCluster(for: digest, claims: claims, ocaBundle: ocaBundle, labels: attribute.labels, order: attribute.order)
      }
      return nil // only reference create child clusters
    }
  }

  private func createClaims(for ocaAttributes: [OverlayBundleAttribute], claims: [any AnyClaim]) -> [CredentialClaim] {
    ocaAttributes.compactMap { attribute in
      guard !attribute.attributeType.isReferenceType else { return nil }
      let anyClaim = claims.first {
        guard let jsonPath = (try? JsonPath(rawString: $0.key)) else { return false }
        return attribute.dataSources.values.contains(jsonPath)
      }
      guard let anyClaim else { return nil }
      return ocaClaimGenerator.generate(for: anyClaim, ocaAttribute: attribute)
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

  fileprivate init(_ anyClaim: AnyClaim) {
    self.init(
      key: anyClaim.key.replacing("$.", with: ""),
      value: anyClaim.value?.rawValue,
      order: Int(Int16.max))
  }
}
