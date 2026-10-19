import Factory
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping force_try

// MARK: - OcaCredentialGeneratorTests

@Suite(.serialized)
struct OcaCredentialGeneratorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let captureBaseDisplayGeneratorSpy = CaptureBaseDisplayGeneratorProtocolSpy()
    let ocaClusterGeneratorSpy = OcaClusterGeneratorProtocolSpy()
    let ocaClaimGeneratorSpy = OcaClaimGeneratorProtocolSpy()
    let imageValidatorSpy = ImageValidatorProtocolSpy()
    let overlayAttributeDateParserSpy = OverlayAttributeDateParserProtocolSpy()

    Container.shared.captureBaseDisplayGenerator.register { captureBaseDisplayGeneratorSpy }
    Container.shared.ocaClusterGenerator.register { ocaClusterGeneratorSpy }
    Container.shared.ocaClaimGenerator.register { ocaClaimGeneratorSpy }
    Container.shared.imageValidator.register { imageValidatorSpy }
    Container.shared.overlayAttributeDateParser.register { overlayAttributeDateParserSpy }

    let ocaBundleMock = try! OcaBundler().createOcaBundle(OcaBundle.Mock.chasseralData)
    ocaClusterGeneratorSpy.generateFromCredentialFormatOcaBundleReturnValue = [CredentialClaimCluster.Mock.singleLevel]
    ocaClaimGeneratorSpy.generatePathValueOcaAttributeOrderReturnValue = CredentialClaim.Mock.noDisplays
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = [
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "de-CH", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#ffffff", primaryField: "summary de-CH", metaName: "credential de-CH"),
      CaptureBaseDisplay(captureBaseDigest: ocaBundleMock.rootCaptureBaseDigest, language: "en-US", theme: "light", logo: URL(string: "data:image/png;base64,"), primaryBackgroundColor: "#000000", primaryField: "summary en-US", metaName: "credential en-US"),
    ]

    self.captureBaseDisplayGeneratorSpy = captureBaseDisplayGeneratorSpy
    self.ocaBundleMock = ocaBundleMock
    generator = OcaCredentialGenerator()

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }

  // MARK: Internal

  @Test
  func generate_returnsCredentialWithGeneratedClusters() throws {
    let anyCredential = Self.makeAnyCredential(JSON.Mock.credentialNested)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredential, keyBinding: Self.credentialKeyBinding)],
      ocaBundle: ocaBundleMock,
      context: Self.credentialGeneratorContextMock)

    assertCredential(credential, selectedKeyBinding: Self.credentialKeyBinding, rawPayload: anyCredential.raw)
    #expect(credential.clusters.count == 1)
  }

  @Test
  func generate_multipleCredentials_returnsCredentialWithMultipleBundleItems() throws {
    let credential = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: Self.makeAnyCredential(rawPayload: Self.rawPayloadMock1), keyBinding: Self.credentialKeyBinding),
        CredentialWithKeyBinding(credential: Self.makeAnyCredential(rawPayload: Self.rawPayloadMock2), keyBinding: Self.credentialKeyBinding),
      ],
      ocaBundle: ocaBundleMock,
      context: Self.credentialGeneratorContextMock)

    #expect(credential.bundleItems.count == 2)
    #expect(String(data: credential.bundleItems[0].payload, encoding: .utf8) == Self.rawPayloadMock1)
    #expect(credential.bundleItems[0].keyBinding == Self.credentialKeyBinding)
    #expect(String(data: credential.bundleItems[1].payload, encoding: .utf8) == Self.rawPayloadMock2)
    #expect(credential.bundleItems[1].keyBinding == Self.credentialKeyBinding)
  }

  @Test(arguments: [false, true])
  func generate_noCaptureBaseDisplays_returnsCredentialWithoutDisplays(isDeferred: Bool) throws {
    captureBaseDisplayGeneratorSpy.generateFromReturnValue = []

    let displays: [CredentialDisplay] = if isDeferred {
      try generator.generateDeferred(
        Self.deferredCredentialContextMock,
        keyBindings: [],
        ocaBundle: ocaBundleMock,
        context: Self.credentialGeneratorContextMock).displays
    } else {
      try generator.generate(
        for: [CredentialWithKeyBinding(credential: Self.makeAnyCredential(), keyBinding: nil)],
        ocaBundle: ocaBundleMock,
        context: Self.credentialGeneratorContextMock).displays
    }

    #expect(displays.isEmpty)
  }

  @Test
  func generate_noRootCaptureBaseDigest_returnsCredentialWithoutDisplays() throws {
    let captureBase = CaptureBase1x0(digest: "digest", attributes: [:], classification: nil, flaggedAttributes: nil)
    let ocaBundle = try OcaBundle(captureBases: [captureBase], overlays: [])

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: Self.makeAnyCredential(), keyBinding: nil)],
      ocaBundle: ocaBundle,
      context: Self.credentialGeneratorContextMock)

    #expect(credential.displays.isEmpty)
  }

  @Test
  func generate_withBatchSize_setsBatchData() throws {
    let context = makeContext(batchSize: 3)

    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: Self.makeAnyCredential(), keyBinding: nil)],
      ocaBundle: ocaBundleMock,
      context: context)

    #expect(credential.batchData == BatchData(batchSize: 3))
  }

  @Test(arguments: [false, true])
  func generate_withAuthentication_setsAuthentication(isDeferred: Bool) throws {
    let context = makeContext(authentication: Self.authenticationMock)

    let authentication: CredentialAuthentication = if isDeferred {
      try generator.generateDeferred(
        Self.deferredCredentialContextMock,
        keyBindings: Self.credentialKeyBindings,
        ocaBundle: ocaBundleMock,
        context: context).authentication
    } else {
      try generator.generate(
        for: [CredentialWithKeyBinding(credential: Self.makeAnyCredential(), keyBinding: nil)],
        ocaBundle: ocaBundleMock,
        context: context).authentication
    }

    #expect(authentication == Self.authenticationMock)
  }

  @Test
  func generateDeferredCredential_returnsDeferredCredential() throws {
    let deferredCredential = try generator.generateDeferred(
      Self.deferredCredentialContextMock,
      keyBindings: Self.credentialKeyBindings,
      ocaBundle: ocaBundleMock,
      context: Self.credentialGeneratorContextMock)

    assertDeferredCredential(
      deferredCredential,
      context: Self.credentialGeneratorContextMock,
      keyBindings: Self.credentialKeyBindings,
      deferredCredentialContext: Self.deferredCredentialContextMock)
  }

  // MARK: Private

  private static let formatMock = CredentialFormat.vcSdJwt
  private static let issuerMock = "issuer"
  private static let validFromMock = Date()
  private static let validUntilMock = Date()
  private static let rawPayloadMock1 = "rawPayloadMock1"
  private static let rawPayloadMock2 = "rawPayloadMock2"

  private static let deferredCredentialContextMock = DeferredCredentialContext.Mock.sample
  private static let credentialGeneratorContextMock = CredentialGeneratorContext.Mock.sample
  private static let credentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)
  private static let credentialKeyBindings = [credentialKeyBinding]
  private static let authenticationMock = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")

  private let ocaBundleMock: OcaBundle
  private let captureBaseDisplayGeneratorSpy: CaptureBaseDisplayGeneratorProtocolSpy
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()
  private let generator: OcaCredentialGenerator

  private static func makeAnyCredential(
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

  private func assertCredential(_ credential: VerifiableCredential, selectedKeyBinding: KeyBinding?, rawPayload: String?) {
    let selectedBundleItem = try? selectCredentialBundleItemUseCaseSpy(credential)

    #expect(credential.id == Self.credentialGeneratorContextMock.credentialId)
    #expect(selectedBundleItem?.status == .unknown)
    #expect(selectedBundleItem?.keyBinding == selectedKeyBinding)
    #expect(String(data: selectedBundleItem?.payload ?? Data(), encoding: .utf8) == rawPayload)
    #expect(credential.rawCredentialData == Self.credentialGeneratorContextMock.rawCredentialData)
    #expect(credential.format == Self.formatMock)
    #expect(credential.issuerUrl == Self.credentialGeneratorContextMock.issuerUrl)
    #expect(credential.selectedConfigurationId == Self.credentialGeneratorContextMock.credentialConfigurationId)
    #expect(credential.issuer == Self.issuerMock)
    #expect(credential.validFrom == Self.validFromMock)
    #expect(credential.validUntil == Self.validUntilMock)
    #expect(credential.issuerDisplays == Self.credentialGeneratorContextMock.issuerDisplays)
    assertCredentialDisplays(credential.displays, derivedFromOCA: true)
  }

  private func assertDeferredCredential(
    _ deferredCredential: DeferredCredential,
    context: CredentialGeneratorContext,
    keyBindings: [KeyBinding],
    deferredCredentialContext: DeferredCredentialContext)
  {
    #expect(deferredCredential.transactionId == deferredCredentialContext.transactionId)
    #expect(deferredCredential.authentication.accessToken == context.authentication.accessToken)
    #expect(deferredCredential.endpoint == deferredCredentialContext.endpoint)
    #expect(deferredCredential.format == deferredCredentialContext.format)
    #expect(deferredCredential.issuerUrl == context.issuerUrl)
    #expect(deferredCredential.keyBindings == keyBindings)
    #expect(deferredCredential.rawCredentialData == context.rawCredentialData)
    #expect(deferredCredential.issuerDisplays == context.issuerDisplays)
    #expect(deferredCredential.authentication.refreshToken == context.authentication.refreshToken)
    #expect(deferredCredential.selectedConfigurationId == context.credentialConfigurationId)

    assertCredentialDisplays(deferredCredential.displays, derivedFromOCA: true)
  }

  private func makeContext(
    batchSize: Int? = nil,
    authentication: CredentialAuthentication = CredentialAuthentication(accessToken: "accessToken"))
    -> CredentialGeneratorContext
  {
    let batchData = batchSize.map(BatchData.init)

    return CredentialGeneratorContext(
      credentialId: Self.credentialGeneratorContextMock.credentialId,
      issuerUrl: Self.credentialGeneratorContextMock.issuerUrl,
      credentialConfigurationId: Self.credentialGeneratorContextMock.credentialConfigurationId,
      batchData: batchData,
      authentication: authentication,
      issuerDisplays: Self.credentialGeneratorContextMock.issuerDisplays,
      rawCredentialData: Self.credentialGeneratorContextMock.rawCredentialData)
  }
}

// swiftlint:enable force_unwrapping force_try
