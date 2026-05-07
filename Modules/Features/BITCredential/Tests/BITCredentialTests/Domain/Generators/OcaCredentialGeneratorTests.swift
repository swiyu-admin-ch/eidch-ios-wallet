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

final class OcaCredentialGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    success()
    generator = OcaCredentialGenerator()
  }

  func testGenerate_withKeyPair_argumentsPassed() throws {
    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromCallsCount, 1)
    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromReceivedOcaBundle?.rootCaptureBaseDigest, ocaBundleMock.rootCaptureBaseDigest)

    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeCallsCount, 1)
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.anyClaim.key, anyClaimSpy.key)
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.ocaAttribute.captureBaseDigest, "IL00eAbH9tHLBN0s6qIZyVVmm6vYA3wsakyqnFMU1nL4")
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.ocaAttribute.name, "key")
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.ocaAttribute.attributeType, .text)
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedArguments?.ocaAttribute.dataSources, [formatMock: [.string("key")]])
  }

  func testGenerate_withKeyPair_returnsCredential() throws {
    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)
    let selectedBundleItem = try? selectCredentialBundleItemUseCaseSpy(credential)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContext.credentialId)
    XCTAssertEqual(selectedBundleItem?.status, .unknown)
    XCTAssertEqual(selectedBundleItem?.keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(String(data: selectedBundleItem?.payload ?? Data(), encoding: .utf8), rawPayloadMock)
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
    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)
    let selectedBundleItem = try? selectCredentialBundleItemUseCaseSpy(credential)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContext.credentialId)
    XCTAssertEqual(selectedBundleItem?.status, .unknown)
    XCTAssertNil(selectedBundleItem?.keyBinding)
    XCTAssertEqual(String(data: selectedBundleItem?.payload ?? Data(), encoding: .utf8), rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContext.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuerUrl, mockCredentialGeneratorContext.issuerUrl)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContext.issuerDisplays)

    XCTAssertEqual(credential.clusters.count, 1)

    let claims = try XCTUnwrap(credential.clusters.first?.claims)
    XCTAssertEqual(claims.count, 1)
    XCTAssertEqual(claims.first, claimMock)
    assertCredentialDisplays(credential.displays, credentialId: credential.id, derivedFromOCA: true)
  }

  func testGenerate_multipleCredentials_returnsCredentialWithMultipleBundleItems() throws {
    let secondRawPayload = "secondRawPayload"
    let secondCredential = createAnyCredential(claims: [anyClaimSpy])
    secondCredential.raw = secondRawPayload

    let secondKeybinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)

    let credential = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: mockCredentialKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: secondKeybinding),
      ],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    XCTAssertEqual(credential.bundleItems.count, 2)
    XCTAssertEqual(String(data: credential.bundleItems[0].payload, encoding: .utf8), rawPayloadMock)
    XCTAssertEqual(credential.bundleItems[0].keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(String(data: credential.bundleItems[1].payload, encoding: .utf8), secondRawPayload)
    XCTAssertEqual(credential.bundleItems[1].keyBinding, secondKeybinding)
  }

  func testGenerate_multipleClaims_returnsCredentialWithClaims() throws {
    let keyValuePairs: [String: CodableValue] = [
      "lastName": .string("lastName"),
      "isOver18": .bool(true),
      "height": .int(165),
      "dateOfBirth": .string("dateTime"),
    ]
    let anyClaims = keyValuePairs.map { key, value in
      let anyClaim = AnyClaimSpy()
      anyClaim.key = key
      anyClaim.path = [.string(key)]
      anyClaim.value = value
      return anyClaim
    }
    let anyCredential = createAnyCredential(claims: anyClaims)
    let ocaBundle = OcaBundle.Mock.simpleSample

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: nil)],
      ocaBundle: ocaBundle,
      context: mockCredentialGeneratorContext)

    let claims = try XCTUnwrap(credential.clusters.first?.claims)
    XCTAssertEqual(claims.count, 4)
    XCTAssertEqual(ocaClaimGeneratorSpy.generateForOcaAttributeCallsCount, 4)
    for anyClaim in anyClaims {
      let invocation = try XCTUnwrap(ocaClaimGeneratorSpy.generateForOcaAttributeReceivedInvocations.first {
        $0.anyClaim.key == anyClaim.key
      })
      XCTAssertEqual(invocation.ocaAttribute.name, anyClaim.key)
    }
  }

  func testGenerate_noCaptureBaseDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []
    let captureBase = CaptureBase1x0(digest: ocaBundleMock.rootCaptureBaseDigest, attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)],
      ocaBundle: ocaBundle,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)],
      ocaBundle: ocaBundle,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_withBatchSize_setsBatchData() throws {
    let context = makeContext(batchSize: 3)

    let credential = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)], ocaBundle: ocaBundleMock, context: context)

    XCTAssertEqual(credential.batchData, BatchData(batchSize: 3))
  }

  func testGenerate_withAuthentication_setsAuthentication() throws {
    let context = makeContext(authentication: mockAuthentication)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)],
      ocaBundle: ocaBundleMock,
      context: context)

    XCTAssertEqual(credential.authentication, mockAuthentication)
  }

  // MARK: - Generate Deferred credential

  func testGenerateDeferredCredential_withKeyPair_argumentsPassed() throws {
    _ = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromCallsCount, 1)
    XCTAssertEqual(captureBaseDisplayGeneratorSpy.generateFromReceivedOcaBundle?.rootCaptureBaseDigest, ocaBundleMock.rootCaptureBaseDigest)
  }

  func testGenerateDeferredCredential_withKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)
    assertDeferredCredential(credential, context: mockCredentialGeneratorContext, keyBindings: mockCredentialKeyBindings, deferredCredentialContext: mockDeferredCredentialContext)
  }

  func testGenerateDeferredCredential_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: [],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)
    assertDeferredCredential(credential, context: mockCredentialGeneratorContext, keyBindings: [], deferredCredentialContext: mockDeferredCredentialContext)
  }

  func testGenerateDeferredCredential_noCaptureBaseDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []
    let captureBase = CaptureBase1x0(digest: ocaBundleMock.rootCaptureBaseDigest, attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: [],
      ocaBundle: ocaBundle,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerateDeferredCredential_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: [],
      ocaBundle: ocaBundle,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: Private

  private static let credentialNameMock = "credentialName"
  private static let pathMock: ClaimsPathPointer = [.string("key")]
  private static let valueMock = "value"

  private let formatMock = "vc+sd-jwt"

  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let ocaBundleMock = OcaBundle.Mock.oneAttribute

  private let mockDeferredCredentialContext = DeferredCredentialContext.Mock.sample

  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)
  private lazy var mockCredentialKeyBindings = [mockCredentialKeyBinding]

  private var anyCredentialSpy = AnyCredentialSpy()
  private let anyClaimSpy = AnyClaimSpy()
  private let claimMock = CredentialClaim(path: pathMock, value: valueMock)
  private let mockAuthentication = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")

  private var captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
  private var ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()

  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var generator = OcaCredentialGenerator()

  private func registerMocks() {
    captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    Container.shared.captureBaseDisplayGenerator.register { self.captureBaseDisplayGeneratorSpy }

    ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()
    Container.shared.ocaClaimGenerator.register { self.ocaClaimGeneratorSpy }

    anyClaimSpy.key = "key"
    anyClaimSpy.path = [.string("key")]
    anyClaimSpy.value = .string(Self.valueMock)
    anyCredentialSpy = createAnyCredential(claims: [anyClaimSpy])

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }

  private func assertDeferredCredential(
    _ deferredCredential: DeferredCredential,
    context: CredentialGeneratorContext,
    keyBindings: [KeyBinding],
    deferredCredentialContext: DeferredCredentialContext)
  {
    XCTAssertEqual(deferredCredential.transactionId, mockDeferredCredentialContext.transactionId)
    XCTAssertEqual(deferredCredential.authentication.accessToken, mockDeferredCredentialContext.accessToken)
    XCTAssertEqual(deferredCredential.endpoint, mockDeferredCredentialContext.endpoint)
    XCTAssertEqual(deferredCredential.format, mockDeferredCredentialContext.format)
    XCTAssertEqual(deferredCredential.issuerUrl, context.issuerUrl)
    XCTAssertEqual(deferredCredential.keyBindings, keyBindings)
    XCTAssertEqual(deferredCredential.rawCredentialData, context.rawCredentialData)
    XCTAssertEqual(deferredCredential.issuerDisplays, context.issuerDisplays)
    XCTAssertEqual(deferredCredential.authentication.refreshToken, deferredCredentialContext.refreshToken)

    assertCredentialDisplays(deferredCredential.displays, credentialId: context.credentialId, derivedFromOCA: true)
  }

  private func makeContext(batchSize: Int? = nil, authentication: CredentialAuthentication = CredentialAuthentication(accessToken: "accessToken")) -> CredentialGeneratorContext {
    let batchData = batchSize.map(BatchData.init)

    return CredentialGeneratorContext(
      credentialId: mockCredentialGeneratorContext.credentialId,
      issuerUrl: mockCredentialGeneratorContext.issuerUrl,
      credentialConfigurationId: mockCredentialGeneratorContext.credentialConfigurationId,
      batchData: batchData,
      authentication: authentication,
      issuerDisplays: mockCredentialGeneratorContext.issuerDisplays,
      rawCredentialData: mockCredentialGeneratorContext.rawCredentialData)
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
