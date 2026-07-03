// swiftlint: disable force_unwrapping force_try implicitly_unwrapped_optional
import Factory
import Foundation
import XCTest
@testable import BITClaimsPathPointer
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - SdJWSDecoderTests

final class SdJWSTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    success()
    decoder = SdJWSDecoder()
    sdJws = try! decoder.decode(FlatJWT.self, from: FlatJWT.Mock.data)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringAllPaths_ReturnsWhole() {
    let result = sdJws.createSelectiveDisclosure(for: [Self.path1, Self.path2, Self.path3])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 4)
    XCTAssertEqual(splitSdJwt[0], FlatJWT.Mock.JWS)
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure1))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure2))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure3))
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresAndKeyBindingRequiringAllPaths_ReturnsWhole() throws {
    let sdJws = try decoder.decode(FlatJWT.self, from: FlatJWT.Mock.dataWithKeyBinding)

    let result = sdJws.createSelectiveDisclosure(for: [Self.path1, Self.path2, Self.path3])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 5)
    XCTAssertEqual(splitSdJwt[0], FlatJWT.Mock.JWS)
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure1))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure2))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure3))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.keyBindingJwt))
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringSomePaths_ReturnsJwtWithRequiredDisclosures() {
    let result = sdJws.createSelectiveDisclosure(for: [Self.path2])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 2)
    XCTAssertEqual(splitSdJwt[0], FlatJWT.Mock.JWS)
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure2))
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresAndKeyBindingRequiringSomePaths_ReturnsJwtWithRequiredDisclosuresAndKeyBinding() throws {
    let sdJws = try decoder.decode(FlatJWT.self, from: FlatJWT.Mock.dataWithKeyBinding)

    let result = sdJws.createSelectiveDisclosure(for: [Self.path2])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 3)
    XCTAssertEqual(splitSdJwt[0], FlatJWT.Mock.JWS)
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.disclosure2))
    XCTAssertTrue(splitSdJwt.contains(FlatJWT.Mock.keyBindingJwt))
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringNoPaths_ReturnsJwt() {
    let result = sdJws.createSelectiveDisclosure(for: [])

    XCTAssertEqual(sdJws.rawJWS + SdJWSDecoder.sdJWTSeparator, result)
  }

  func testCreateSelectiveDisclosure_withFlatDisclosuresRequiringOtherPaths_ReturnsJwt() {
    let result = sdJws.createSelectiveDisclosure(for: [[.string("otherKey")], [.string("otherKey2")]])

    XCTAssertEqual(sdJws.rawJWS + SdJWSDecoder.sdJWTSeparator, result)
  }

  func testCreateSelectiveDisclosure_withFlatArrayRequestingArray_ReturnsWhole() throws {
    let sdJws = try decoder.decode(FlatSimpleArrayJWT.self, from: FlatSimpleArrayJWT.Mock.arrayOnlyData)

    let result = sdJws.createSelectiveDisclosure(for: [[.string("array_key"), .null]])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 3)
    XCTAssertEqual(splitSdJwt[0], sdJws.rawJWS)
    XCTAssertTrue(splitSdJwt.contains(FlatSimpleArrayJWT.Mock.disclosureElement1))
    XCTAssertTrue(splitSdJwt.contains(FlatSimpleArrayJWT.Mock.disclosureElement2))
  }

  func testCreateSelectiveDisclosure_withFlatArrayRequestingOneElement_ReturnsJwtWithElement() throws {
    let sdJws = try decoder.decode(FlatSimpleArrayJWT.self, from: FlatSimpleArrayJWT.Mock.arrayOnlyData)

    let result = sdJws.createSelectiveDisclosure(for: [[.string("array_key"), .index(1)]])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 2)
    XCTAssertEqual(splitSdJwt[0], sdJws.rawJWS)
    XCTAssertTrue(splitSdJwt.contains(FlatSimpleArrayJWT.Mock.disclosureElement2))
  }

  func testCreateSelectiveDisclosure_withRecursiveObjectRequiringRootObject_ReturnsWhole() throws {
    let sdJws = try decoder.decode(RecursiveJWT.self, from: RecursiveJWT.Mock.data)

    let result = sdJws.createSelectiveDisclosure(for: [[.string("test_key_1")]])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 3)
    XCTAssertEqual(splitSdJwt[0], sdJws.rawJWS)
    XCTAssertTrue(splitSdJwt.contains(RecursiveJWT.Mock.disclosure1))
    XCTAssertTrue(splitSdJwt.contains(RecursiveJWT.Mock.disclosure2))
  }

  func testCreateSelectiveDisclosure_withRecursiveObjectRequiringElement_ReturnsWhole() throws {
    let sdJws = try decoder.decode(RecursiveJWT.self, from: RecursiveJWT.Mock.data)

    let result = sdJws.createSelectiveDisclosure(for: [[.string("test_key_1"), .string("test_key_2")]])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 3)
    XCTAssertEqual(splitSdJwt[0], sdJws.rawJWS)
    XCTAssertTrue(splitSdJwt.contains(RecursiveJWT.Mock.disclosure1))
    XCTAssertTrue(splitSdJwt.contains(RecursiveJWT.Mock.disclosure2))
  }

  func testCreateSelectiveDisclosure_withComplexObjectRequiringNestedObject_ReturnsJwtWithNestedObjectDisclosures() throws {
    let sdJws = try decoder.decode(ComplexJWT.self, from: ComplexJWT.Mock.data)

    let result = sdJws.createSelectiveDisclosure(for: [[.string("key_object_partly_disclosed")]])

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 11)
    XCTAssertEqual(splitSdJwt[0], sdJws.rawJWS)
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_2))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_2_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_2_1_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3_2))
  }

  func testCreateSelectiveDisclosure_withComplexObjectRequiringPartsOfObject_ReturnsJwtWithRequestedDisclosures() throws {
    let sdJws = try decoder.decode(ComplexJWT.self, from: ComplexJWT.Mock.data)
    let paths: [ClaimsPathPointer] = [
      ComplexJWT.PartlyDisclosedObject12.key1Path,
      ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0),
      ComplexJWT.PartlyDisclosedObject.key3Path,
    ]

    let result = sdJws.createSelectiveDisclosure(for: paths)

    let splitSdJwt = result.split(separator: SdJWSDecoder.sdJWTSeparator).map(String.init)
    XCTAssertEqual(splitSdJwt.count, 8)
    XCTAssertEqual(splitSdJwt[0], sdJws.rawJWS)
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_2_3_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3_1))
    XCTAssertTrue(splitSdJwt.contains(ComplexJWT.Mock.objectPartlyDisclosedDisclosure1_3_2))
  }

  func testGetPresentingPaths_withComplexObjectRequiringNestedObject_ReturnsAllPathsInNestedObject() throws {
    let sdJws = try decoder.decode(ComplexJWT.self, from: ComplexJWT.Mock.data)

    let result = sdJws.getPresentingPaths(for: [[.string("key_object_partly_disclosed")]])

    XCTAssertEqual(result.count, 13)
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key2Path))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key3Path + [.null]))

    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key1Path))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key2Path))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.null]))

    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.index(0)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.index(1)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0) + [.null]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 1) + [.null]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0) + [.index(0)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 1) + [.index(0)]))

    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key3Path + [.index(0)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key3Path + [.index(1)]))
  }

  func testGetPresentingPaths_withComplexObjectRequiringPartsOfObject_ReturnsOnlyPartialPaths() throws {
    let sdJws = try decoder.decode(ComplexJWT.self, from: ComplexJWT.Mock.data)
    let paths: [ClaimsPathPointer] = [
      ComplexJWT.PartlyDisclosedObject12.key1Path,
      ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0),
      ComplexJWT.PartlyDisclosedObject.key3Path,
    ]

    let result = sdJws.getPresentingPaths(for: paths)

    XCTAssertEqual(result.count, 10)

    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key2Path))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key1Path))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key2Path))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.null]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject12.key3Path + [.index(0)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0) + [.null]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject123.getKeyPath(index: 0) + [.index(0)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key3Path + [.null]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key3Path + [.index(0)]))
    XCTAssertTrue(result.contains(ComplexJWT.PartlyDisclosedObject.key3Path + [.index(1)]))
  }

  // MARK: Private

  private static let path1: ClaimsPathPointer = [.string("test_key_1")]
  private static let path2: ClaimsPathPointer = [.string("test_key_2")]
  private static let path3: ClaimsPathPointer = [.string("test_key_3")]

  private static let keyIdentifierDidMock = "did:tdw:example"

  private var didResolverHelperSpy: DidResolverHelperProtocolSpy!

  private var decoder = SdJWSDecoder()
  private var sdJws: SdJWS<FlatJWT>!

  private func registerMocks() {
    didResolverHelperSpy = DidResolverHelperProtocolSpy()
    Container.shared.didResolverHelper.register { self.didResolverHelperSpy }
  }

  private func success() {
    didResolverHelperSpy.getDidFromReturnValue = Self.keyIdentifierDidMock
  }
}
