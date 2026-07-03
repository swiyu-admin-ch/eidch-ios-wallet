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
    Container.shared.reset()
    registerMocks()
    success()
    generator = OcaCredentialGenerator()
  }

  func testGenerate_returnsCredentialWithGeneratedClusters() throws {
    let anyCredential = makeAnyCredential(JSON.Mock.credentialNested)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: mockCredentialKeyBinding)],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    assertCredential(credential, selectedKeyBinding: mockCredentialKeyBinding, rawPayload: anyCredential.raw)
    XCTAssertEqual(credential.clusters.count, 1)
  }

  func testGenerate_multipleCredentials_returnsCredentialWithMultipleBundleItems() throws {
    let credential = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: makeAnyCredential(rawPayload: rawPayloadMock1), keyBinding: mockCredentialKeyBinding),
        CredentialWithKeyBinding(credential: makeAnyCredential(rawPayload: rawPayloadMock2), keyBinding: mockCredentialKeyBinding),
      ],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    XCTAssertEqual(credential.bundleItems.count, 2)
    XCTAssertEqual(String(data: credential.bundleItems[0].payload, encoding: .utf8), rawPayloadMock1)
    XCTAssertEqual(credential.bundleItems[0].keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(String(data: credential.bundleItems[1].payload, encoding: .utf8), rawPayloadMock2)
    XCTAssertEqual(credential.bundleItems[1].keyBinding, mockCredentialKeyBinding)
  }

  func testGenerate_noCaptureBaseDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: makeAnyCredential(), keyBinding: nil)],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: makeAnyCredential(), keyBinding: nil)],
      ocaBundle: ocaBundle,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_withBatchSize_setsBatchData() throws {
    let context = makeContext(batchSize: 3)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: makeAnyCredential(), keyBinding: nil)],
      ocaBundle: ocaBundleMock,
      context: context)

    XCTAssertEqual(credential.batchData, BatchData(batchSize: 3))
  }

  func testGenerate_withAuthentication_setsAuthentication() throws {
    let context = makeContext(authentication: mockAuthentication)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: makeAnyCredential(), keyBinding: nil)],
      ocaBundle: ocaBundleMock,
      context: context)

    XCTAssertEqual(credential.authentication, mockAuthentication)
  }

  func testGenerateDeferredCredential_returnsDeferredCredential() throws {
    let deferredCredential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    assertDeferredCredential(
      deferredCredential,
      context: mockCredentialGeneratorContext,
      keyBindings: mockCredentialKeyBindings,
      deferredCredentialContext: mockDeferredCredentialContext)
  }

  func testGenerateDeferredCredential_withoutCredentialDisplays_returnsCredentialWithoutDisplays() throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []

    let deferredCredential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: [],
      ocaBundle: ocaBundleMock,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(deferredCredential.displays.isEmpty)
  }

  func testGenerateDeferredCredential_withAuthentication_setsAuthentication() throws {
    let context = makeContext(authentication: mockAuthentication)

    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      ocaBundle: ocaBundleMock,
      context: context)

    XCTAssertEqual(credential.authentication, mockAuthentication)
  }

  // MARK: Private

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let rawPayloadMock1 = "rawPayloadMock1"
  private let rawPayloadMock2 = "rawPayloadMock2"
  private let ocaBundleMock = try! OcaBundler().createOcaBundle(OcaBundle.Mock.chasseralData)

  private let mockDeferredCredentialContext = DeferredCredentialContext.Mock.sample
  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)
  private lazy var mockCredentialKeyBindings = [mockCredentialKeyBinding]
  private let mockAuthentication = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")

  private var captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
  private var ocaClusterGeneratorSpy = OcaClusterGeneratorProtocolSpy()
  private var ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()
  private var imageValidatorSpy = ImageValidatorProtocolSpy()
  private var overlayAttributeDateParserSpy = OverlayAttributeDateParserProtocolSpy()
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var generator = OcaCredentialGenerator()

  private func registerMocks() {
    captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    ocaClusterGeneratorSpy = OcaClusterGeneratorProtocolSpy()
    ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()
    imageValidatorSpy = ImageValidatorProtocolSpy()
    overlayAttributeDateParserSpy = OverlayAttributeDateParserProtocolSpy()

    Container.shared.captureBaseDisplayGenerator.register { self.captureBaseDisplayGeneratorSpy }
    Container.shared.ocaClusterGenerator.register { self.ocaClusterGeneratorSpy }
    Container.shared.ocaClaimGenerator.register { self.ocaClaimGeneratorSpy }
    Container.shared.imageValidator.register { self.imageValidatorSpy }
    Container.shared.overlayAttributeDateParser.register { self.overlayAttributeDateParserSpy }
  }

  private func assertCredential(_ credential: VerifiableCredential, selectedKeyBinding: KeyBinding?, rawPayload: String?) {
    let selectedBundleItem = try? selectCredentialBundleItemUseCaseSpy(credential)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContext.credentialId)
    XCTAssertEqual(selectedBundleItem?.status, .unknown)
    XCTAssertEqual(selectedBundleItem?.keyBinding, selectedKeyBinding)
    XCTAssertEqual(String(data: selectedBundleItem?.payload ?? Data(), encoding: .utf8), rawPayload)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContext.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuerUrl, mockCredentialGeneratorContext.issuerUrl)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContext.issuerDisplays)
    assertCredentialDisplays(credential.displays, credentialId: credential.id, derivedFromOCA: true)
  }

  private func assertDeferredCredential(
    _ deferredCredential: DeferredCredential,
    context: CredentialGeneratorContext,
    keyBindings: [KeyBinding],
    deferredCredentialContext: DeferredCredentialContext)
  {
    XCTAssertEqual(deferredCredential.transactionId, deferredCredentialContext.transactionId)
    XCTAssertEqual(deferredCredential.authentication.accessToken, context.authentication.accessToken)
    XCTAssertEqual(deferredCredential.endpoint, deferredCredentialContext.endpoint)
    XCTAssertEqual(deferredCredential.format, deferredCredentialContext.format)
    XCTAssertEqual(deferredCredential.issuerUrl, context.issuerUrl)
    XCTAssertEqual(deferredCredential.keyBindings, keyBindings)
    XCTAssertEqual(deferredCredential.rawCredentialData, context.rawCredentialData)
    XCTAssertEqual(deferredCredential.issuerDisplays, context.issuerDisplays)
    XCTAssertEqual(deferredCredential.authentication.refreshToken, context.authentication.refreshToken)
    XCTAssertEqual(deferredCredential.selectedConfigurationId, context.credentialConfigurationId)

    assertCredentialDisplays(deferredCredential.displays, credentialId: context.credentialId, derivedFromOCA: true)
  }

  private func makeContext(
    batchSize: Int? = nil,
    authentication: CredentialAuthentication = CredentialAuthentication(accessToken: "accessToken"))
    -> CredentialGeneratorContext
  {
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

  private func makeAnyCredential(
    _ payload: JSON = JSON.Mock.credentialNested,
    rawPayload: String? = nil)
    -> AnyCredentialSpy
  {
    let credential = AnyCredentialSpy()
    credential.format = formatMock
    credential.issuer = issuerMock
    credential.validFrom = validFromMock
    credential.validUntil = validUntilMock
    if let rawPayload {
      credential.raw = rawPayload
    } else {
      let data = (try? JSONSerialization.data(withJSONObject: payload)) ?? Data()
      credential.raw = String(decoding: data, as: UTF8.self)
    }
    credential.getClaimsJSONReturnValue = payload
    return credential
  }

  private func success() {
    ocaClusterGeneratorSpy.generateFromCredentialFormatOcaBundleReturnValue = [CredentialClaimCluster.Mock.singleLevel]
    ocaClaimGeneratorSpy.generatePathValueOcaAttributeOrderReturnValue = CredentialClaim.Mock.noDisplays

    captureBaseDisplayGeneratorSpy.generateFromReturnValue = [
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "de-CH", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#ffffff", primaryField: "summary de-CH", metaName: "credential de-CH"),
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "en-US", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#000000", primaryField: "summary en-US", metaName: "credential en-US"),
    ]

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }
}
