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

final class OcaCredentialGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    success()
    generator = OcaCredentialGenerator()
  }

  func testGenerate_withKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: keyPairMock, ocaBundle: ocaBundleMock, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertEqual(credential.id, idMock)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential.keyBindingIdentifier, Self.keyPairIdentifier)
    XCTAssertEqual(credential.keyBindingAlgorithm, Self.keyPairAlgorithm)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, rawCredentialDataMock)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertNil(credential.updatedAt)
    XCTAssertEqual(credential.issuerDisplays, issuerDisplaysMock)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id, derivedFromOCA: true)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, ocaBundle: ocaBundleMock, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertEqual(credential.id, idMock)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertNil(credential.keyBindingIdentifier)
    XCTAssertNil(credential.keyBindingAlgorithm)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, rawCredentialDataMock)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertNil(credential.updatedAt)
    XCTAssertEqual(credential.issuerDisplays, issuerDisplaysMock)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id, derivedFromOCA: true)
  }

  func testGenerate_withoutLabelAttributes_returnsCredentialClaimWithoutDisplay() throws {
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, ocaBundle: .Mock.emptyLabelOverlay, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      XCTAssertTrue(claim.displays.isEmpty)
    }
  }

  func testGenerate_noCaptureBaseDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []
    let captureBase = CaptureBase1x0(digest: ocaBundleMock.rootCaptureBaseDigest, attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, ocaBundle: ocaBundle, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, ocaBundle: ocaBundle, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: Private

  private static let mockPrivateKey: SecKey = SecKeyTestsHelper.createPrivateKey()
  private static let keyPairIdentifier = UUID()
  private static let keyPairAlgorithm = "ES512"
  private static let credentialNameMock = "credentialName"

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let ocaBundleMock = OcaBundle.Mock.simpleSample

  private let idMock = UUID()
  private let issuerDisplaysMock = [CredentialIssuerDisplay(id: UUID(), credentialId: nil, image: nil)]
  private let rawCredentialDataMock = RawCredentialData()

  private var keyPairMock = KeyPair(identifier: keyPairIdentifier, algorithm: keyPairAlgorithm, privateKey: mockPrivateKey)
  private var anyCredentialSpy = AnyCredentialSpy()
  private var firstClaim = AnyClaimSpy()
  private var secondClaim = AnyClaimSpy()
  private var thirdClaim = AnyClaimSpy()

  private var captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()

  private var generator = OcaCredentialGenerator()

  private func registerMocks() {
    captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    Container.shared.captureBaseDisplayGenerator.register { self.captureBaseDisplayGeneratorSpy }

    firstClaim = AnyClaimSpy()
    firstClaim.key = "$.lastName"
    firstClaim.value = .string("lastName")

    secondClaim = AnyClaimSpy()
    secondClaim.key = "$.isOver18"
    secondClaim.value = .bool(true)

    thirdClaim = AnyClaimSpy()
    thirdClaim.key = "$.height"
    thirdClaim.value = .int(165)

    anyCredentialSpy = createAnyCredential(claims: [firstClaim, secondClaim, thirdClaim])
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

  private func success() {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = [
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "de-CH", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#ffffff", primaryField: "summary de-CH", metaName: "credential de-CH"),
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "en-US", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#000000", primaryField: "summary en-US", metaName: "credential en-US"),
    ]
  }

  private func assertClaims(_ claims: [CredentialClaim], isOrderMaxValue: Bool = false, valueType: ValueType? = nil) {
    let locales = ["de-CH", "en-US"]
    let expectedClaims = [
      ExpectedClaim(
        key: firstClaim.key,
        value: firstClaim.value!.rawValue,
        valueType: valueType != nil ? valueType! : .string,
        order: isOrderMaxValue ? Int16.max : 1,
        locales: locales),
      ExpectedClaim(
        key: secondClaim.key,
        value: secondClaim.value!.rawValue,
        valueType: valueType != nil ? valueType! : .boolean,
        order: isOrderMaxValue ? Int16.max : 2,
        locales: locales),
      ExpectedClaim(
        key: thirdClaim.key,
        value: thirdClaim.value!.rawValue,
        valueType: valueType != nil ? valueType! : .string,
        order: isOrderMaxValue ? Int16.max : 3,
        locales: locales),
    ]
    assertClaimsEqual(claims, expectedClaims: expectedClaims)
  }
}

// swiftlint:enable all
