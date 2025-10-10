import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping force_try

final class OcaNestedCredentialGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    generator = OcaCredentialGenerator()
  }

  func testGenerate_nestedWithClaimsOnRoot_returnsCredentialWithOneCluster() throws {
    let anyCredential = createNestedAnyCredential()
    let credential = try generator.generate(for: anyCredential, id: idMock, keyBinding: keyBindingMock, ocaBundle: OcaBundle.Mock.nested, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 1)
    let cluster = credential.clusters.first!
    assertNestedCluster(cluster)
  }

  func testGenerate_nestedWithClaimsOnRootAndMissingOcaAttributes_returnsCredentialWithTwoClusters() throws {
    let anyCredential = createNestedAnyCredential()
    let additionalClaim = createTextClaim(jsonPath: "$.other_path", value: "other_value")
    anyCredential.claims.insert(additionalClaim, at: 1)
    let credential = try generator.generate(for: anyCredential, id: idMock, keyBinding: keyBindingMock, ocaBundle: OcaBundle.Mock.nested, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 2)
    let cluster = credential.clusters.first { !$0.childClusters.isEmpty }!
    assertNestedCluster(cluster)

    let additionalCluster = credential.clusters.first(where: \.childClusters.isEmpty)!
    XCTAssertEqual(additionalCluster.claims.count, 1)
    XCTAssertTrue(additionalCluster.claims[0].displays.isEmpty)
    XCTAssertEqual(additionalCluster.childClusters.count, 0)
  }

  func testGenerate_nestedWithoutClaimsOnRoot_returnsCredentialWithClusters() throws {
    let anyCredential = createSimpleNestedCredential()

    let credential = try generator.generate(for: anyCredential, id: idMock, keyBinding: keyBindingMock, ocaBundle: OcaBundle.Mock.simpleNested, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 3)
    assertSimpleNestedClusters(credential.clusters)
  }

  func testGenerate_nestedWithoutClaimsOnRootAndMissingOcaAttributes_returnsCredentialWithClusters() throws {
    let anyCredential = createSimpleNestedCredential()
    let additionalClaim = createTextClaim(jsonPath: "$.other_path", value: "other_value")
    anyCredential.claims.insert(additionalClaim, at: 1)

    let credential = try generator.generate(for: anyCredential, id: idMock, keyBinding: keyBindingMock, ocaBundle: OcaBundle.Mock.simpleNested, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 4)
    assertSimpleNestedClusters(credential.clusters)

    let additionalCluster = credential.clusters.first(where: \.displays.isEmpty)!
    XCTAssertEqual(additionalCluster.claims.count, 1)
    XCTAssertTrue(additionalCluster.claims[0].displays.isEmpty)
    XCTAssertEqual(additionalCluster.childClusters.count, 0)
  }

  // MARK: Private

  private static let captureBase1Claim1KeyMock = "capture_base_1_claim_1"
  private static let captureBase2Claim1KeyMock = "capture_base_2.claim_1"
  private static let captureBase3Claim1KeyMock = "capture_base_3.claim_1"
  private static let arrayCaptureBaseClaimKeyMock = "array_capture_base"
  private static let textArrayClaimKeyMock = "text_array_claim"

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let ocaBundleMock = OcaBundle.Mock.simpleSample

  private let idMock = UUID()
  private let issuerDisplaysMock = [CredentialIssuerDisplay(id: UUID(), credentialId: nil, image: nil)]
  private let rawCredentialDataMock = RawCredentialData()
  private let keyBindingMock = CredentialKeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)

  private var captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()

  private var generator = OcaCredentialGenerator()

  private func registerMocks() {
    captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    Container.shared.captureBaseDisplayGenerator.register { self.captureBaseDisplayGeneratorSpy }
  }

  private func success() {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = [
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "de-CH", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#ffffff", primaryField: "summary de-CH", metaName: "credential de-CH"),
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "en-US", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#000000", primaryField: "summary en-US", metaName: "credential en-US"),
    ]
  }

  private func createNestedAnyCredential() -> AnyCredentialSpy {
    let captureBase1Claim1 = createTextClaim(jsonPath: "$.\(Self.captureBase1Claim1KeyMock)", value: "captureBase1Claim1")
    let captureBase1Claim2 = createTextClaim(jsonPath: "$.capture_base_1_claim_2", value: "captureBase1Claim2")

    let captureBase2Claim1 = createTextClaim(jsonPath: "$.\(Self.captureBase2Claim1KeyMock)", value: "captureBase2Claim1")
    let captureBase2Claim2 = createTextClaim(jsonPath: "$.capture_base_2.claim_2", value: "captureBase2Claim2")
    let captureBase2Claim3 = createTextClaim(jsonPath: "$.capture_base_2.claim_3", value: "captureBase2Claim3")

    let arrayCaptureBase = AnyClaimSpy()
    arrayCaptureBase.key = "$.\(Self.arrayCaptureBaseClaimKeyMock)"
    let arrayCaptureBase0 = CodableValue.dictionary(["claim_1": .string("arrayCaptureBase0Claim1"), "claim_2": .string("arrayCaptureBase0Claim2")])
    let arrayCaptureBase1 = CodableValue.dictionary(["claim_1": .string("arrayCaptureBase1Claim1"), "claim_2": .string("arrayCaptureBase1Claim2")])
    arrayCaptureBase.value = .array([arrayCaptureBase0, arrayCaptureBase1])

    let textArrayClaim = AnyClaimSpy()
    textArrayClaim.key = "$.\(Self.textArrayClaimKeyMock)"
    textArrayClaim.value = .array([.string("textArrayClaim0"), .string("textArrayClaim1")])

    return createAnyCredential(claims: [captureBase1Claim1, captureBase1Claim2, captureBase2Claim1, captureBase2Claim2, captureBase2Claim3, arrayCaptureBase, textArrayClaim])
  }

  private func createTextClaim(jsonPath: String, value: String) -> AnyClaimSpy {
    let claim = AnyClaimSpy()
    claim.key = jsonPath
    claim.value = .string(value)
    return claim
  }

  private func createAnyCredential(claims: [AnyClaimSpy]) -> AnyCredentialSpy {
    let anyCredential = AnyCredentialSpy()
    anyCredential.format = formatMock
    anyCredential.issuer = issuerMock
    anyCredential.validFrom = validFromMock
    anyCredential.validUntil = validUntilMock
    anyCredential.raw = rawPayloadMock
    anyCredential.claims = claims
    return anyCredential
  }

  private func createSimpleNestedCredential() -> AnyCredentialSpy {
    let captureBase1Claim1 = createTextClaim(jsonPath: "$.\(Self.captureBase1Claim1KeyMock)", value: "captureBase1Claim1")
    let captureBase2Claim1 = createTextClaim(jsonPath: "$.\(Self.captureBase2Claim1KeyMock)", value: "captureBase2Claim1")
    let captureBase3Claim1 = createTextClaim(jsonPath: "$.\(Self.captureBase3Claim1KeyMock)", value: "captureBase3Claim1")
    return createAnyCredential(claims: [captureBase1Claim1, captureBase2Claim1, captureBase3Claim1])
  }

  private func assertBasicCredential(_ credential: VerifiableCredential) {
    XCTAssertEqual(credential.id, idMock)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential.keyBinding, keyBindingMock)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, rawCredentialDataMock)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, issuerDisplaysMock)
  }

  private func assertNestedCluster(_ cluster: CredentialClaimCluster) {
    assertRootCluster(cluster)
    XCTAssertEqual(cluster.childClusters.count, 1)
    let captureBase1Cluster = cluster.childClusters.first!
    assertCaptureBase1Cluster(captureBase1Cluster)
  }

  private func assertRootCluster(_ cluster: CredentialClaimCluster) {
    XCTAssertEqual(cluster.claims.count, 2)
    let arrayCaptureBaseClaim = cluster.claims.first { $0.key == Self.arrayCaptureBaseClaimKeyMock }!
    XCTAssertEqual(arrayCaptureBaseClaim.displays.count, 1)
    XCTAssertEqual(arrayCaptureBaseClaim.order, 2)
    let textArrayClaim = cluster.claims.first { $0.key == Self.textArrayClaimKeyMock }!
    XCTAssertEqual(textArrayClaim.displays.count, 1)
    XCTAssertEqual(textArrayClaim.order, 3)
  }

  private func assertCaptureBase1Cluster(_ cluster: CredentialClaimCluster) {
    XCTAssertEqual(cluster.displays.count, 2)
    XCTAssertEqual(cluster.claims.count, 2)
    XCTAssertEqual(cluster.order, 1)
    XCTAssertEqual(cluster.claims[0].displays.count, 1)
    XCTAssertEqual(cluster.claims[1].displays.count, 1)

    XCTAssertEqual(cluster.childClusters.count, 1)
    let captureBase2Cluster = cluster.childClusters.first!
    assertCaptureBase2Cluster(captureBase2Cluster)
  }

  private func assertCaptureBase2Cluster(_ captureBase2Cluster: CredentialClaimCluster) {
    XCTAssertEqual(captureBase2Cluster.displays.count, 1)
    XCTAssertTrue(captureBase2Cluster.childClusters.isEmpty)
    XCTAssertEqual(captureBase2Cluster.claims.count, 3)
    XCTAssertEqual(captureBase2Cluster.claims[0].displays.count, 2)
    XCTAssertEqual(captureBase2Cluster.claims[1].displays.count, 2)
    XCTAssertEqual(captureBase2Cluster.claims[2].displays.count, 2)
  }

  private func assertSimpleNestedClusters(_ clusters: [CredentialClaimCluster]) {
    let captureBase1Cluster = clusters.first { $0.claims.first?.key == Self.captureBase1Claim1KeyMock }!
    XCTAssertEqual(captureBase1Cluster.order, 1)
    XCTAssertEqual(captureBase1Cluster.displays.count, 1)

    let captureBase2Cluster = clusters.first { $0.claims.first?.key == Self.captureBase2Claim1KeyMock }!
    XCTAssertEqual(captureBase2Cluster.order, 2)
    XCTAssertEqual(captureBase2Cluster.displays.count, 1)

    let captureBase3Cluster = clusters.first { $0.claims.first?.key == Self.captureBase3Claim1KeyMock }!
    XCTAssertEqual(captureBase3Cluster.order, 3)
    XCTAssertEqual(captureBase3Cluster.displays.count, 1)
  }
}

// swiftlint:enable all
