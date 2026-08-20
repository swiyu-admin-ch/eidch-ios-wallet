// swiftlint:disable force_unwrapping force_try
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

class OcaClusterGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    generator = OcaClusterGenerator()
  }

  func testGenerate_returnsNestedClusters() throws {
    let clusters = try generator.generate(
      from: JSON.Mock.credentialNested,
      credentialFormat: formatMock,
      ocaBundle: ocaBundleMock)

    let rootCluster = try XCTUnwrap(clusters.first)
    XCTAssertEqual(rootCluster.path, [])
    XCTAssertEqual(rootCluster.claims.count, 12)

    let arrayStringsCluster = try XCTUnwrap(Self.arrayStringsClusterPath.findCluster(in: rootCluster.childClusters))
    XCTAssertEqual(arrayStringsCluster.path, Self.arrayStringsClusterPath)

    let arrayObjectsCluster = try XCTUnwrap(Self.arrayObjectsClusterPath.findCluster(in: rootCluster.childClusters))
    XCTAssertEqual(arrayObjectsCluster.path, Self.arrayObjectsClusterPath)

    let objectCluster = try XCTUnwrap(Self.objectClusterPath.findCluster(in: rootCluster.childClusters))
    XCTAssertEqual(objectCluster.path, Self.objectClusterPath)
  }

  func testGenerate_missingAttribute_addsFallbackCluster() throws {
    let clusters = try generator.generate(
      from: JSON.Mock.credentialNestedWithClaimNotInOCA,
      credentialFormat: formatMock,
      ocaBundle: ocaBundleMock)

    XCTAssertEqual(clusters.count, 2)

    let fallbackCluster = try XCTUnwrap(clusters.last)
    XCTAssertEqual(fallbackCluster.path, [])
    XCTAssertTrue(fallbackCluster.childClusters.isEmpty)
    XCTAssertEqual(fallbackCluster.claims.count, 4)

    let notInOcaClaim = try XCTUnwrap(Self.notInOcaClaimPath.findClaim(in: fallbackCluster))
    XCTAssertEqual(notInOcaClaim.value, "notInOcaClaim")
    XCTAssertEqual(notInOcaClaim.order, Int(Int16.max))

    let nestedNotInOcaClaim = try XCTUnwrap(Self.nestedNotInOcaClaimPath.findClaim(in: fallbackCluster))
    XCTAssertEqual(nestedNotInOcaClaim.value, "nestedNotInOcaClaim")
    XCTAssertEqual(nestedNotInOcaClaim.order, Int(Int16.max))

    let arrayObjectNotInOcaClaim0 = try XCTUnwrap(Self.arrayObjectNotInOcaClaim0Path.findClaim(in: fallbackCluster))
    XCTAssertEqual(arrayObjectNotInOcaClaim0.value, "arrayObjectNotInOcaClaim0")
    XCTAssertEqual(arrayObjectNotInOcaClaim0.order, Int(Int16.max))

    let arrayObjectNotInOcaClaim1 = try XCTUnwrap(Self.arrayObjectNotInOcaClaim1Path.findClaim(in: fallbackCluster))
    XCTAssertEqual(arrayObjectNotInOcaClaim1.value, "arrayObjectNotInOcaClaim1")
    XCTAssertEqual(arrayObjectNotInOcaClaim1.order, Int(Int16.max))
  }

  func testGenerate_referenceAttributeWithoutDataSource_returnsOcaClusters() throws {
    let clusters = try generator.generate(
      from: JSON.Mock.credentialOcaOnlyClusters,
      credentialFormat: formatMock,
      ocaBundle: OcaBundle.Mock.ocaClusters)

    XCTAssertEqual(clusters.count, 2)

    let cluster1 = try XCTUnwrap(clusters.first { $0.displays.first?.name == "Claim 1" })
    XCTAssertEqual(cluster1.path, [])
    XCTAssertEqual(cluster1.order, 0)
    XCTAssertEqual(cluster1.claims.count, 1)
    XCTAssertTrue(cluster1.childClusters.isEmpty)

    let claim1 = try XCTUnwrap(Self.element1Path.findClaim(in: cluster1))
    XCTAssertEqual(claim1.value, "claimValue1")

    let clustr2 = try XCTUnwrap(clusters.first { $0.displays.first?.name == "Claim 2" })
    XCTAssertEqual(clustr2.path, [])
    XCTAssertEqual(clustr2.order, 1)
    XCTAssertTrue(clustr2.isSensitive)
    XCTAssertEqual(clustr2.claims.count, 1)
    XCTAssertTrue(clustr2.childClusters.isEmpty)

    let claim2 = try XCTUnwrap(Self.element2Path.findClaim(in: clustr2))
    XCTAssertEqual(claim2.value, "claimValue2")
  }

  func testGenerate_nestedPayloadWithOneCaptureBase_returnsRootCluster() throws {
    let clusters = try generator.generate(
      from: JSON.Mock.credentialNestedOneCaptureBase,
      credentialFormat: formatMock,
      ocaBundle: OcaBundle.Mock.oneCaptureBase)

    XCTAssertEqual(clusters.count, 1)

    let rootCluster = try XCTUnwrap(clusters.first)
    XCTAssertEqual(rootCluster.path, [])
    XCTAssertEqual(rootCluster.order, 0)
    XCTAssertEqual(rootCluster.claims.count, 2)
    XCTAssertTrue(rootCluster.childClusters.isEmpty)

    let claim1 = try XCTUnwrap(Self.nestedElement1Path.findClaim(in: rootCluster))
    XCTAssertEqual(claim1.value, "claimValue1")

    let claim2 = try XCTUnwrap(Self.nestedElement2Path.findClaim(in: rootCluster))
    XCTAssertEqual(claim2.value, "claimValue2")
  }

  func testGenerate_dataSourceWithNested_resolvesClusterPath() throws {
    let clusters = try generator.generate(
      from: JSON.Mock.credentialArrayObjectNestedClaim,
      credentialFormat: formatMock,
      ocaBundle: OcaBundle.Mock.arrayObjectNestedClaim)

    XCTAssertEqual(clusters.count, 2)

    let item0Cluster = try XCTUnwrap(Self.item0ClusterPath.findCluster(in: clusters))
    let item0Claim = try XCTUnwrap(Self.item0NestedClaimPath.findClaim(in: item0Cluster))
    XCTAssertEqual(item0Claim.value, "item0")

    let item1Cluster = try XCTUnwrap(Self.item1ClusterPath.findCluster(in: clusters))
    let item1Claim = try XCTUnwrap(Self.item1NestedClaimPath.findClaim(in: item1Cluster))
    XCTAssertEqual(item1Claim.value, "item1")
  }

  // MARK: Private

  private static let arrayStringsClusterPath: ClaimsPathPointer = [.string("array_strings"), .null]
  private static let arrayObjectsClusterPath: ClaimsPathPointer = [.string("array_objects"), .null]
  private static let objectClusterPath: ClaimsPathPointer = [.string("object")]
  private static let notInOcaClaimPath: ClaimsPathPointer = [.string("not_in_oca_claim")]
  private static let nestedNotInOcaClaimPath: ClaimsPathPointer = [.string("object"), .string("nested_not_in_oca_claim")]
  private static let arrayObjectNotInOcaClaim0Path: ClaimsPathPointer = [.string("array_objects"), .index(0), .string("array_object_not_in_oca_claim")]
  private static let arrayObjectNotInOcaClaim1Path: ClaimsPathPointer = [.string("array_objects"), .index(1), .string("array_object_not_in_oca_claim")]
  private static let namePath: ClaimsPathPointer = [.string("name")]
  private static let detailPath: ClaimsPathPointer = [.string("detail")]
  private static let element1Path: ClaimsPathPointer = [.string("key1")]
  private static let element2Path: ClaimsPathPointer = [.string("key2")]
  private static let nestedElement1Path: ClaimsPathPointer = [.string("key1"), .string("key3")]
  private static let nestedElement2Path: ClaimsPathPointer = [.string("key2"), .string("key4")]
  private static let itemsClusterPath: ClaimsPathPointer = [.string("items"), .null]
  private static let item0ClusterPath: ClaimsPathPointer = [.string("items"), .index(0)]
  private static let item1ClusterPath: ClaimsPathPointer = [.string("items"), .index(1)]
  private static let item0NestedClaimPath: ClaimsPathPointer = [.string("items"), .index(0), .string("details"), .string("claim")]
  private static let item1NestedClaimPath: ClaimsPathPointer = [.string("items"), .index(1), .string("details"), .string("claim")]

  private let formatMock = CredentialFormat.vcSdJwt
  private let ocaBundleMock = try! OcaBundler().createOcaBundle(OcaBundle.Mock.chasseralData)

  private var imageValidatorSpy = ImageValidatorProtocolSpy()
  private var overlayAttributeDateParserSpy = OverlayAttributeDateParserProtocolSpy()

  private var generator = OcaClusterGenerator()

  private func registerMocks() {
    imageValidatorSpy = ImageValidatorProtocolSpy()
    overlayAttributeDateParserSpy = OverlayAttributeDateParserProtocolSpy()

    Container.shared.ocaClaimGenerator.register { OcaClaimGenerator() }
    Container.shared.imageValidator.register { self.imageValidatorSpy }
    Container.shared.overlayAttributeDateParser.register { self.overlayAttributeDateParserSpy }
  }
}
