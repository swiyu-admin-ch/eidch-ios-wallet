import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
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
    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: OcaBundle.Mock.nested,
      context: mockCredentialGeneratorContext)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 1)
    let cluster = try XCTUnwrap(credential.clusters.first)
    assertNestedCluster(cluster)
  }

  func testGenerate_nestedWithClaimsOnRootAndMissingOcaAttributes_returnsCredentialWithTwoClusters() throws {
    let anyCredential = createNestedAnyCredential()
    let additionalClaim = createTextClaim(key: "other_path", value: "other_value", path: [.string("other_path")])
    anyCredential.claims.insert(additionalClaim, at: 1)
    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: OcaBundle.Mock.nested,
      context: mockCredentialGeneratorContext)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 2)
    let cluster = try XCTUnwrap(credential.clusters.first { !$0.childClusters.isEmpty })
    assertNestedCluster(cluster)

    let additionalCluster = try XCTUnwrap(credential.clusters.first(where: \.childClusters.isEmpty))
    XCTAssertEqual(additionalCluster.claims.count, 1)
    XCTAssertEqual(additionalCluster.claims[0].path, Self.otherPathMock)
    XCTAssertTrue(additionalCluster.claims[0].displays.isEmpty)
    XCTAssertEqual(additionalCluster.childClusters.count, 0)
  }

  func testGenerate_nestedWithoutClaimsOnRoot_returnsCredentialWithClusters() throws {
    let anyCredential = createSimpleNestedCredential()

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: OcaBundle.Mock.simpleNested,
      context: mockCredentialGeneratorContext)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 3)
    assertSimpleNestedClusters(credential.clusters)
  }

  func testGenerate_nestedWithoutClaimsOnRootAndMissingOcaAttributes_returnsCredentialWithClusters() throws {
    let anyCredential = createSimpleNestedCredential()
    let additionalClaim = createTextClaim(key: "other_path", value: "other_value", path: [.string("other_path")])
    anyCredential.claims.insert(additionalClaim, at: 1)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: OcaBundle.Mock.simpleNested,
      context: mockCredentialGeneratorContext)

    assertBasicCredential(credential)
    XCTAssertEqual(credential.clusters.count, 4)
    assertSimpleNestedClusters(credential.clusters)

    let additionalCluster = try XCTUnwrap(credential.clusters.first(where: \.displays.isEmpty))
    XCTAssertEqual(additionalCluster.claims.count, 1)
    XCTAssertEqual(additionalCluster.claims[0].path, Self.otherPathMock)
    XCTAssertTrue(additionalCluster.claims[0].displays.isEmpty)
    XCTAssertEqual(additionalCluster.childClusters.count, 0)
  }

  // MARK: Private

  private static let captureBase1Claim1KeyMock = "capture_base_1_claim_1"
  private static let captureBase2Claim1KeyMock = "capture_base_2.claim_1"
  private static let captureBase3Claim1KeyMock = "capture_base_3.claim_1"
  private static let arrayCaptureBaseClaimKeyMock = "array_capture_base"
  private static let textArrayClaimKeyMock = "text_array_claim"
  private static let captureBase1Claim1PathMock: ClaimsPathPointer = [.string("capture_base_1_claim_1")]
  private static let captureBase2Claim1PathMock: ClaimsPathPointer = [.string("capture_base_2"), .string("claim_1")]
  private static let captureBase2Claim2PathMock: ClaimsPathPointer = [.string("capture_base_2"), .string("claim_2")]
  private static let captureBase2Claim3PathMock: ClaimsPathPointer = [.string("capture_base_2"), .string("claim_3")]
  private static let captureBase3Claim1PathMock: ClaimsPathPointer = [.string("capture_base_3"), .string("claim_1")]
  private static let arrayCaptureBaseClaimPathMock: ClaimsPathPointer = [.string("array_capture_base"), .null]
  private static let textArrayClaimPathMock: ClaimsPathPointer = [.string("text_array_claim"), .null]
  private static let otherPathMock: ClaimsPathPointer = [.string("other_path")]

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let ocaBundleMock = OcaBundle.Mock.simpleSample

  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)

  private var captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()

  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var generator = OcaCredentialGenerator()

  private func registerMocks() {
    captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    Container.shared.captureBaseDisplayGenerator.register { self.captureBaseDisplayGeneratorSpy }

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }

  private func success() {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = [
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "de-CH", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#ffffff", primaryField: "summary de-CH", metaName: "credential de-CH"),
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "en-US", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#000000", primaryField: "summary en-US", metaName: "credential en-US"),
    ]
  }

  private func createNestedAnyCredential() -> AnyCredentialSpy {
    let captureBase1Claim1 = createTextClaim(key: Self.captureBase1Claim1KeyMock, value: "captureBase1Claim1", path: Self.captureBase1Claim1PathMock)
    let captureBase1Claim2 = createTextClaim(key: "capture_base_1_claim_2", value: "captureBase1Claim2", path: [.string("capture_base_1_claim_2")])

    let captureBase2Claim1 = createTextClaim(key: Self.captureBase2Claim1KeyMock, value: "captureBase2Claim1", path: Self.captureBase2Claim1PathMock)
    let captureBase2Claim2 = createTextClaim(key: "capture_base_2_claim_2", value: "captureBase2Claim2", path: Self.captureBase2Claim2PathMock)
    let captureBase2Claim3 = createTextClaim(key: "capture_base_2_claim_3", value: "captureBase2Claim3", path: Self.captureBase2Claim3PathMock)

    let arrayCaptureBase = AnyClaimSpy()
    arrayCaptureBase.key = Self.arrayCaptureBaseClaimKeyMock
    let arrayCaptureBase0 = CodableValue.dictionary(["claim_1": .string("arrayCaptureBase0Claim1"), "claim_2": .string("arrayCaptureBase0Claim2")])
    let arrayCaptureBase1 = CodableValue.dictionary(["claim_1": .string("arrayCaptureBase1Claim1"), "claim_2": .string("arrayCaptureBase1Claim2")])
    arrayCaptureBase.path = [.string(Self.arrayCaptureBaseClaimKeyMock), .null]
    arrayCaptureBase.value = .array([arrayCaptureBase0, arrayCaptureBase1])

    let textArrayClaim = AnyClaimSpy()
    textArrayClaim.key = Self.textArrayClaimKeyMock
    textArrayClaim.path = [.string(Self.textArrayClaimKeyMock), .null]
    textArrayClaim.value = .array([.string("textArrayClaim0"), .string("textArrayClaim1")])

    return createAnyCredential(claims: [captureBase1Claim1, captureBase1Claim2, captureBase2Claim1, captureBase2Claim2, captureBase2Claim3, arrayCaptureBase, textArrayClaim])
  }

  private func createTextClaim(key: String, value: String, path: ClaimsPathPointer) -> AnyClaimSpy {
    let claim = AnyClaimSpy()
    claim.key = key
    claim.path = path
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
    let captureBase1Claim1 = createTextClaim(key: Self.captureBase1Claim1KeyMock, value: "captureBase1Claim1", path: Self.captureBase1Claim1PathMock)
    let captureBase2Claim1 = createTextClaim(key: Self.captureBase2Claim1KeyMock, value: "captureBase2Claim1", path: Self.captureBase2Claim1PathMock)
    let captureBase3Claim1 = createTextClaim(key: Self.captureBase3Claim1KeyMock, value: "captureBase3Claim1", path: Self.captureBase3Claim1PathMock)
    return createAnyCredential(claims: [captureBase1Claim1, captureBase2Claim1, captureBase3Claim1])
  }

  private func assertBasicCredential(_ credential: VerifiableCredential) {
    let selectedBundleItem = try? selectCredentialBundleItemUseCaseSpy(credential)
    XCTAssertEqual(credential.id, mockCredentialGeneratorContext.credentialId)
    XCTAssertEqual(selectedBundleItem?.status, .unknown)
    XCTAssertEqual(selectedBundleItem?.keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(String(data: selectedBundleItem?.payload ?? Data(), encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContext.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContext.issuerDisplays)
  }

  private func assertNestedCluster(_ cluster: CredentialClaimCluster) {
    assertRootCluster(cluster)
    XCTAssertEqual(cluster.childClusters.count, 1)
    let captureBase1Cluster = cluster.childClusters.first!
    assertCaptureBase1Cluster(captureBase1Cluster)
  }

  private func assertRootCluster(_ cluster: CredentialClaimCluster) {
    XCTAssertEqual(cluster.claims.count, 2)
    let arrayCaptureBaseClaim = cluster.claims.first { $0.path == Self.arrayCaptureBaseClaimPathMock }!
    XCTAssertEqual(arrayCaptureBaseClaim.displays.count, 1)
    XCTAssertEqual(arrayCaptureBaseClaim.order, 2)
    let textArrayClaim = cluster.claims.first { $0.path == Self.textArrayClaimPathMock }!
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
    XCTAssertNotNil(captureBase2Cluster.claims.map(\.path).contains(Self.captureBase2Claim1PathMock))
    XCTAssertNotNil(captureBase2Cluster.claims.map(\.path).contains(Self.captureBase2Claim2PathMock))
    XCTAssertNotNil(captureBase2Cluster.claims.map(\.path).contains(Self.captureBase2Claim3PathMock))
    XCTAssertEqual(captureBase2Cluster.claims[0].displays.count, 2)
    XCTAssertEqual(captureBase2Cluster.claims[1].displays.count, 2)
    XCTAssertEqual(captureBase2Cluster.claims[2].displays.count, 2)
  }

  private func assertSimpleNestedClusters(_ clusters: [CredentialClaimCluster]) {
    let captureBase1Cluster = clusters.first { $0.claims.first?.path == Self.captureBase1Claim1PathMock }!
    XCTAssertEqual(captureBase1Cluster.order, 1)
    XCTAssertEqual(captureBase1Cluster.displays.count, 1)

    let captureBase2Cluster = clusters.first { $0.claims.first?.path == Self.captureBase2Claim1PathMock }!
    XCTAssertEqual(captureBase2Cluster.order, 2)
    XCTAssertEqual(captureBase2Cluster.displays.count, 1)

    let captureBase3Cluster = clusters.first { $0.claims.first?.path == Self.captureBase3Claim1PathMock }!
    XCTAssertEqual(captureBase3Cluster.order, 3)
    XCTAssertEqual(captureBase3Cluster.displays.count, 1)
  }
}
