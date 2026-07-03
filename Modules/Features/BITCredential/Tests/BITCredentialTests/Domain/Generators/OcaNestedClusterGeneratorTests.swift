import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOca

// swiftlint:disable force_unwrapping force_try

final class OcaNestedClusterGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    generator = OcaClusterGenerator()
  }

  func testGenerate_nestedPayload_returnsNestedCluster() throws {
    let credential = makeAnyCredential(JSON.Mock.credentialNested)
    let clusters = try generator.generate(
      from: credential.getClaimsJSON(.nonTechnical),
      credentialFormat: credential.format,
      ocaBundle: ocaBundleMock)

    XCTAssertEqual(clusters.count, 1)

    let rootCluster = try XCTUnwrap(clusters.first)
    try assertRootCluster(rootCluster)
    try assertNestedClusters(in: clusters)
  }

  func testGenerate_nestedPayloadWithMissingRootOcaAttribute_addsFallbackCluster() throws {
    let credential = makeAnyCredential(JSON.Mock.credentialNestedWithClaimNotInOCA)
    let clusters = try generator.generate(
      from: credential.getClaimsJSON(.nonTechnical),
      credentialFormat: credential.format,
      ocaBundle: ocaBundleMock)

    XCTAssertEqual(clusters.count, 2)

    let rootCluster = try XCTUnwrap(clusters.first)
    try assertRootCluster(rootCluster)
    try assertNestedClusters(in: clusters)

    let fallbackCluster = try XCTUnwrap(clusters.last)
    XCTAssertEqual(fallbackCluster.path, [])
    XCTAssertTrue(fallbackCluster.childClusters.isEmpty)

    let notInOcaClaim = try XCTUnwrap(Self.notInOcaClaimPath.findClaim(in: fallbackCluster))
    XCTAssertEqual(notInOcaClaim.value, "notInOcaClaim")
    XCTAssertEqual(notInOcaClaim.order, Int(Int16.max))
    XCTAssertTrue(notInOcaClaim.displays.isEmpty)
  }

  // MARK: Private

  private static let stringPath: ClaimsPathPointer = [.string("string")]
  private static let doublePath: ClaimsPathPointer = [.string("double")]
  private static let nullPath: ClaimsPathPointer = [.string("null")]
  private static let imageDataUrlJpgPath: ClaimsPathPointer = [.string("image_data_url_jpg")]

  private static let arrayStringsPath: ClaimsPathPointer = [.string("array_strings"), .null]
  private static let arrayStringsItem0Path: ClaimsPathPointer = [.string("array_strings"), .index(0)]
  private static let arrayStringsItem1Path: ClaimsPathPointer = [.string("array_strings"), .index(1)]

  private static let arrayObjectsPath: ClaimsPathPointer = [.string("array_objects"), .null]
  private static let arrayObjectsItem0Path: ClaimsPathPointer = [.string("array_objects"), .index(0)]
  private static let arrayObjectsItem1Path: ClaimsPathPointer = [.string("array_objects"), .index(1)]
  private static let arrayObjectsItem0ClaimPath: ClaimsPathPointer = [.string("array_objects"), .index(0), .string("claim")]
  private static let arrayObjectsItem1ClaimPath: ClaimsPathPointer = [.string("array_objects"), .index(1), .string("claim")]

  private static let objectPath: ClaimsPathPointer = [.string("object")]
  private static let objectClaimPath: ClaimsPathPointer = [.string("object"), .string("claim")]
  private static let objectArrayIntegersPath: ClaimsPathPointer = [.string("object"), .string("array_integers"), .null]
  private static let objectArrayIntegersItem0Path: ClaimsPathPointer = [.string("object"), .string("array_integers"), .index(0)]
  private static let objectArrayIntegersItem1Path: ClaimsPathPointer = [.string("object"), .string("array_integers"), .index(1)]
  private static let objectArrayObjectsPath: ClaimsPathPointer = [.string("object"), .string("array_objects"), .null]
  private static let objectArrayObjectsItem0Path: ClaimsPathPointer = [.string("object"), .string("array_objects"), .index(0)]
  private static let objectArrayObjectsItem1Path: ClaimsPathPointer = [.string("object"), .string("array_objects"), .index(1)]
  private static let objectArrayObjectsItem0ClaimPath: ClaimsPathPointer = [.string("object"), .string("array_objects"), .index(0), .string("claim")]
  private static let objectArrayObjectsItem1ClaimPath: ClaimsPathPointer = [.string("object"), .string("array_objects"), .index(1), .string("claim")]
  private static let objectObjectPath: ClaimsPathPointer = [.string("object"), .string("object")]
  private static let objectObjectClaimPath: ClaimsPathPointer = [.string("object"), .string("object"), .string("claim")]

  private static let notInOcaClaimPath: ClaimsPathPointer = [.string("not_in_oca_claim")]
  private static let otherNestedClaimPath: ClaimsPathPointer = [.string("object"), .string("other_nested_claim")]

  private let formatMock = "vc+sd-jwt"
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

  private func assertRootCluster(_ rootCluster: CredentialClaimCluster) throws {
    XCTAssertEqual(rootCluster.path, [])
    XCTAssertEqual(rootCluster.claims.count, 12)
    XCTAssertEqual(rootCluster.childClusters.count, 3)

    let stringClaim = try XCTUnwrap(Self.stringPath.findClaim(in: rootCluster))
    XCTAssertEqual(stringClaim.value, "rootString")
    XCTAssertEqual(stringClaim.order, 1)
    XCTAssertEqual(stringClaim.displays.count, 5)

    let doubleClaim = try XCTUnwrap(Self.doublePath.findClaim(in: rootCluster))
    XCTAssertEqual(doubleClaim.value, "12.34")
    XCTAssertEqual(doubleClaim.order, 3)
    XCTAssertTrue(doubleClaim.isSensitive)

    let imageClaim = try XCTUnwrap(Self.imageDataUrlJpgPath.findClaim(in: rootCluster))
    XCTAssertEqual(imageClaim.value, "/9j/4AAQSkZJRgABAQAAAQABAAD/2w==")
    XCTAssertEqual(imageClaim.order, 11)
    XCTAssertTrue(imageClaim.isSensitive)
  }

  private func assertNestedClusters(in clusters: [CredentialClaimCluster]) throws {
    let arrayStringsCluster = try XCTUnwrap(Self.arrayStringsPath.findCluster(in: clusters))
    XCTAssertEqual(arrayStringsCluster.order, 14)
    XCTAssertEqual(arrayStringsCluster.displays.count, 5)
    XCTAssertEqual(arrayStringsCluster.claims.count, 2)
    XCTAssertTrue(arrayStringsCluster.childClusters.isEmpty)

    let arrayStringsItem0 = try XCTUnwrap(Self.arrayStringsItem0Path.findClaim(in: arrayStringsCluster))
    XCTAssertEqual(arrayStringsItem0.value, "rootArrayString0")
    XCTAssertEqual(arrayStringsItem0.order, 0)
    XCTAssertTrue(arrayStringsItem0.displays.isEmpty)

    let arrayStringsItem1 = try XCTUnwrap(Self.arrayStringsItem1Path.findClaim(in: arrayStringsCluster))
    XCTAssertEqual(arrayStringsItem1.value, "rootArrayString1")
    XCTAssertEqual(arrayStringsItem1.order, 1)
    XCTAssertTrue(arrayStringsItem1.displays.isEmpty)

    let arrayObjectsCluster = try XCTUnwrap(Self.arrayObjectsPath.findCluster(in: clusters))
    XCTAssertEqual(arrayObjectsCluster.order, 15)
    XCTAssertTrue(arrayObjectsCluster.displays.isEmpty)
    XCTAssertTrue(arrayObjectsCluster.claims.isEmpty)
    XCTAssertEqual(arrayObjectsCluster.childClusters.count, 2)

    let arrayObjectsItem0 = try XCTUnwrap(Self.arrayObjectsItem0Path.findCluster(in: clusters))
    XCTAssertEqual(arrayObjectsItem0.order, 0)
    XCTAssertEqual(arrayObjectsItem0.claims.count, 1)
    XCTAssertEqual(arrayObjectsItem0.displays.count, 5)

    let arrayObjectsItem0Claim = try XCTUnwrap(Self.arrayObjectsItem0ClaimPath.findClaim(in: arrayObjectsItem0))
    XCTAssertEqual(arrayObjectsItem0Claim.value, "rootArrayObjectClaim0")
    XCTAssertEqual(arrayObjectsItem0Claim.order, Int(Int16.max))
    XCTAssertEqual(arrayObjectsItem0Claim.displays.count, 5)
    XCTAssertFalse(arrayObjectsItem0Claim.isSensitive)

    let arrayObjectsItem1 = try XCTUnwrap(Self.arrayObjectsItem1Path.findCluster(in: clusters))
    XCTAssertEqual(arrayObjectsItem1.order, 1)
    XCTAssertEqual(arrayObjectsItem1.claims.count, 1)
    XCTAssertEqual(arrayObjectsItem1.displays.count, 5)

    let arrayObjectsItem1Claim = try XCTUnwrap(Self.arrayObjectsItem1ClaimPath.findClaim(in: arrayObjectsItem1))
    XCTAssertEqual(arrayObjectsItem1Claim.value, "rootArrayObjectClaim1")
    XCTAssertEqual(arrayObjectsItem1Claim.order, Int(Int16.max))
    XCTAssertEqual(arrayObjectsItem1Claim.displays.count, 5)
    XCTAssertFalse(arrayObjectsItem1Claim.isSensitive)

    let objectCluster = try XCTUnwrap(Self.objectPath.findCluster(in: clusters))
    XCTAssertEqual(objectCluster.order, 16)
    XCTAssertEqual(objectCluster.displays.count, 5)
    XCTAssertEqual(objectCluster.claims.count, 1)
    XCTAssertEqual(objectCluster.childClusters.count, 3)

    let objectClaim = try XCTUnwrap(Self.objectClaimPath.findClaim(in: objectCluster))
    XCTAssertEqual(objectClaim.value, "objectClaimLevel1")
    XCTAssertEqual(objectClaim.order, 1)
    XCTAssertEqual(objectClaim.displays.count, 5)

    let objectArrayIntegersCluster = try XCTUnwrap(Self.objectArrayIntegersPath.findCluster(in: clusters))
    XCTAssertEqual(objectArrayIntegersCluster.order, 2)
    XCTAssertEqual(objectArrayIntegersCluster.displays.count, 5)
    XCTAssertEqual(objectArrayIntegersCluster.claims.count, 2)
    XCTAssertTrue(objectArrayIntegersCluster.childClusters.isEmpty)

    let objectArrayInteger0 = try XCTUnwrap(Self.objectArrayIntegersItem0Path.findClaim(in: objectArrayIntegersCluster))
    XCTAssertEqual(objectArrayInteger0.value, "7")
    XCTAssertEqual(objectArrayInteger0.order, 0)
    XCTAssertTrue(objectArrayInteger0.displays.isEmpty)

    let objectArrayInteger1 = try XCTUnwrap(Self.objectArrayIntegersItem1Path.findClaim(in: objectArrayIntegersCluster))
    XCTAssertEqual(objectArrayInteger1.value, "8")
    XCTAssertEqual(objectArrayInteger1.order, 1)
    XCTAssertTrue(objectArrayInteger1.displays.isEmpty)

    let objectArrayObjectsCluster = try XCTUnwrap(Self.objectArrayObjectsPath.findCluster(in: clusters))
    XCTAssertEqual(objectArrayObjectsCluster.order, 3)
    XCTAssertTrue(objectArrayObjectsCluster.displays.isEmpty)
    XCTAssertTrue(objectArrayObjectsCluster.claims.isEmpty)
    XCTAssertEqual(objectArrayObjectsCluster.childClusters.count, 2)

    let objectArrayObjectsItem0 = try XCTUnwrap(Self.objectArrayObjectsItem0Path.findCluster(in: clusters))
    XCTAssertEqual(objectArrayObjectsItem0.order, 0)
    XCTAssertEqual(objectArrayObjectsItem0.claims.count, 1)
    XCTAssertEqual(objectArrayObjectsItem0.displays.count, 5)

    let objectArrayObjectsItem0Claim = try XCTUnwrap(Self.objectArrayObjectsItem0ClaimPath.findClaim(in: objectArrayObjectsItem0))
    XCTAssertEqual(objectArrayObjectsItem0Claim.value, "objectArrayObjectClaim0")
    XCTAssertEqual(objectArrayObjectsItem0Claim.order, Int(Int16.max))
    XCTAssertEqual(objectArrayObjectsItem0Claim.displays.count, 5)

    let objectArrayObjectsItem1 = try XCTUnwrap(Self.objectArrayObjectsItem1Path.findCluster(in: clusters))
    XCTAssertEqual(objectArrayObjectsItem1.order, 1)
    XCTAssertEqual(objectArrayObjectsItem1.claims.count, 1)
    XCTAssertEqual(objectArrayObjectsItem1.displays.count, 5)

    let objectArrayObjectsItem1Claim = try XCTUnwrap(Self.objectArrayObjectsItem1ClaimPath.findClaim(in: objectArrayObjectsItem1))
    XCTAssertEqual(objectArrayObjectsItem1Claim.value, "objectArrayObjectClaim1")
    XCTAssertEqual(objectArrayObjectsItem1Claim.order, Int(Int16.max))
    XCTAssertEqual(objectArrayObjectsItem1Claim.displays.count, 5)

    let objectObjectCluster = try XCTUnwrap(Self.objectObjectPath.findCluster(in: clusters))
    XCTAssertEqual(objectObjectCluster.order, 4)
    XCTAssertEqual(objectObjectCluster.displays.count, 5)
    XCTAssertEqual(objectObjectCluster.claims.count, 1)
    XCTAssertTrue(objectObjectCluster.childClusters.isEmpty)

    let objectObjectClaim = try XCTUnwrap(Self.objectObjectClaimPath.findClaim(in: objectObjectCluster))
    XCTAssertEqual(objectObjectClaim.value, "objectClaimLevel2")
    XCTAssertEqual(objectObjectClaim.order, Int(Int16.max))
    XCTAssertEqual(objectObjectClaim.displays.count, 5)
  }

  private func makeAnyCredential(_ payload: JSON) -> AnyCredentialSpy {
    let credential = AnyCredentialSpy()
    credential.format = formatMock
    let data = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
    credential.raw = String(decoding: data, as: UTF8.self)
    credential.getClaimsJSONReturnValue = payload
    return credential
  }
}
