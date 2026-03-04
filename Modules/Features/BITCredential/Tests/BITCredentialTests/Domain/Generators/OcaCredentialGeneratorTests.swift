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

  func testGenerate_withKeyPair_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialSpy, ocaBundle: ocaBundleMock, context: mockCredentialGeneratorContext)

    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromCallsCount, 1)
    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromReceivedOcaBundle?.rootCaptureBaseDigest, ocaBundleMock.rootCaptureBaseDigest)

    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeCallsCount, 1)
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.anyClaim.key, anyClaimSpy.key)
    let expectedAttribute = try ocaBundleMock.getAttributeForJsonPath(jsonPath: JsonPath(rawString: anyClaimSpy.key))
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.ocaAttribute, expectedAttribute)
  }

  func testGenerate_withKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, ocaBundle: ocaBundleMock, context: mockCredentialGeneratorContext)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContext.credentialId)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential.keyBinding, mockCredentialGeneratorContext.keyBinding)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8), rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContext.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuerUrl, mockCredentialGeneratorContext.issuerUrl)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContext.issuerDisplays)
    XCTAssertEqual(credential.clusters.count, 1)
    XCTAssertEqual(credential.progressionState, .unaccepted)

    let claims = try XCTUnwrap(credential.clusters.first?.claims)
    XCTAssertEqual(claims.count, 1)
    XCTAssertEqual(claims.first, claimMock)
    assertCredentialDisplays(credential.displays, credentialId: credential.id, derivedFromOCA: true)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, ocaBundle: ocaBundleMock, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContextWithoutKeyBinding.credentialId)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertNil(credential.keyBinding)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8), rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContextWithoutKeyBinding.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuerUrl, mockCredentialGeneratorContextWithoutKeyBinding.issuerUrl)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContextWithoutKeyBinding.issuerDisplays)
    XCTAssertEqual(credential.clusters.count, 1)

    let claims = try XCTUnwrap(credential.clusters.first?.claims)
    XCTAssertEqual(claims.count, 1)
    XCTAssertEqual(claims.first, claimMock)
    assertCredentialDisplays(credential.displays, credentialId: credential.id, derivedFromOCA: true)
  }

  func testGenerate_multipleClaims_returnsCredentialWithClaims() throws {
    let keyValuePairs: [String: CodableValue] = [
      "$.lastName": .string("lastName"),
      "$.isOver18": .bool(true),
      "$.height": .int(165),
      "$.dateOfBirth": .string("dateTime"),
    ]
    let anyClaims = keyValuePairs.map { key, value in
      let anyClaim = AnyClaimSpy()
      anyClaim.key = key
      anyClaim.value = value
      return anyClaim
    }
    let anyCredential = createAnyCredential(claims: anyClaims)
    let ocaBundle = OcaBundle.Mock.simpleSample

    let credential = try generator.generate(for: anyCredential, ocaBundle: ocaBundle, context: mockCredentialGeneratorContextWithoutKeyBinding)

    let claims = try XCTUnwrap(credential.clusters.first?.claims)
    XCTAssertEqual(claims.count, 4)
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeCallsCount, 4)
    for anyClaim in anyClaims {
      let invocation = try XCTUnwrap(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedInvocations.first {
        $0.anyClaim.key == anyClaim.key
      })
      let expectedAttribute = try ocaBundle.getAttributeForJsonPath(jsonPath: JsonPath(rawString: anyClaim.key))
      XCTAssertEqual(invocation.ocaAttribute, expectedAttribute)
    }
  }

  func testGenerate_noCaptureBaseDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []
    let captureBase = CaptureBase1x0(digest: ocaBundleMock.rootCaptureBaseDigest, attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(for: anyCredentialSpy, ocaBundle: ocaBundle, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(for: anyCredentialSpy, ocaBundle: ocaBundle, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: - Generate Deferred credential

  func testGenerateDeferredCredential_withKeyPair_argumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialContext, ocaBundle: ocaBundleMock, context: mockCredentialGeneratorContext)

    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromCallsCount, 1)
    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromReceivedOcaBundle?.rootCaptureBaseDigest, ocaBundleMock.rootCaptureBaseDigest)
  }

  func testGenerateDeferredCredential_withKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(mockDeferredCredentialContext, ocaBundle: ocaBundleMock, context: mockCredentialGeneratorContext)
    assertDeferredCredential(credential, context: mockCredentialGeneratorContext)
  }

  func testGenerateDeferredCredential_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(mockDeferredCredentialContext, ocaBundle: ocaBundleMock, context: mockCredentialGeneratorContextWithoutKeyBinding)
    assertDeferredCredential(credential, context: mockCredentialGeneratorContextWithoutKeyBinding)
  }

  func testGenerateDeferredCredential_noCaptureBaseDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []
    let captureBase = CaptureBase1x0(digest: ocaBundleMock.rootCaptureBaseDigest, attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generateDeferred(mockDeferredCredentialContext, ocaBundle: ocaBundle, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerateDeferredCredential_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generateDeferred(mockDeferredCredentialContext, ocaBundle: ocaBundle, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: Private

  private static let credentialNameMock = "credentialName"
  private static let keyMock = "key"
  private static let valueMock = "value"

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let ocaBundleMock = OcaBundle.Mock.oneAttribute

  private let mockDeferredCredentialContext = DeferredCredentialContext.Mock.sample

  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialGeneratorContextWithoutKeyBinding = CredentialGeneratorContext.Mock.sampleWithoutKeyBinding

  private var anyCredentialSpy = AnyCredentialSpy()
  private let anyClaimSpy = AnyClaimSpy()
  private let claimMock = CredentialClaim(key: keyMock, value: valueMock)

  private var captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
  private var ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()

  private var generator = OcaCredentialGenerator()

  private func registerMocks() {
    captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    Container.shared.captureBaseDisplayGenerator.register { self.captureBaseDisplayGeneratorSpy }

    ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()
    Container.shared.ocaClaimGenerator.register { self.ocaClaimGeneratorSpy }

    anyClaimSpy.key = "$.\(Self.keyMock)"
    anyClaimSpy.value = .string(Self.valueMock)
    anyCredentialSpy = createAnyCredential(claims: [anyClaimSpy])
  }

  private func assertDeferredCredential(_ deferredCredential: DeferredCredential, context: CredentialGeneratorContext) {
    XCTAssertEqual(deferredCredential.transactionId, mockDeferredCredentialContext.transactionId)
    XCTAssertEqual(deferredCredential.accessToken, mockDeferredCredentialContext.accessToken)
    XCTAssertEqual(deferredCredential.endpoint, mockDeferredCredentialContext.endpoint)
    XCTAssertEqual(deferredCredential.format, mockDeferredCredentialContext.format)
    XCTAssertEqual(deferredCredential.issuerUrl, context.issuerUrl)
    XCTAssertEqual(deferredCredential.keyBinding, context.keyBinding)
    XCTAssertEqual(deferredCredential.rawCredentialData, context.rawCredentialData)
    XCTAssertEqual(deferredCredential.issuerDisplays, context.issuerDisplays)

    assertCredentialDisplays(deferredCredential.displays, credentialId: context.credentialId, derivedFromOCA: true)
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
    ocaClaimGeneratorSpy.generateForOcaAttributeReturnValue = claimMock
  }
}

// swiftlint:enable all
