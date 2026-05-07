import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping force_try

final class MetadataCredentialGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    generator = MetadataCredentialGenerator()
  }

  // MARK: - Generate Verifiable credential

  func testGenerate_withKeyPair_returnsCredential() throws {
    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: mockCredentialKeyBinding)],
      selectedCredential: selectedCredentialMock,
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

    XCTAssertEqual(valueTypeResolverSpy.callAsFunctionCallsCount, 5)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredentialMock,
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
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContext.issuerDisplays)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_multipleCredentials_returnsCredentialWithMultipleBundleItems() throws {
    let secondRawPayload = "secondRawPayload"
    let secondCredential = AnyCredentialSpy()
    secondCredential.format = anyCredentialSpy.format
    secondCredential.issuer = anyCredentialSpy.issuer
    secondCredential.validFrom = anyCredentialSpy.validFrom
    secondCredential.validUntil = anyCredentialSpy.validUntil
    secondCredential.raw = secondRawPayload
    secondCredential.claims = anyCredentialSpy.claims

    var secondKeybinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)

    let credential = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: mockCredentialKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: secondKeybinding),
      ],
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    XCTAssertEqual(credential.bundleItems.count, 2)
    XCTAssertEqual(String(data: credential.bundleItems[0].payload, encoding: .utf8), rawPayloadMock)
    XCTAssertEqual(credential.bundleItems[0].keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(String(data: credential.bundleItems[1].payload, encoding: .utf8), secondRawPayload)
    XCTAssertEqual(credential.bundleItems[1].keyBinding, secondKeybinding)
  }

  func testGenerate_stringValueType_returnsCredentialWithStringValue() throws {
    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, valueType: ValueType.string)
    XCTAssertEqual(imageValidator.validateBase64ImageAgainstCallsCount, 0)
  }

  func testGenerate_withoutClaimDisplay_returnsCredentialClaimWithoutDisplay() throws {
    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first?.value)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredential,
      context: mockCredentialGeneratorContext)

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      XCTAssertTrue(claim.displays.isEmpty)
    }
  }

  func testGenerate_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first?.value)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredential,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  func testGenerate_imageValidatorThrowsError_throwsError() throws {
    valueTypeResolverSpy.callAsFunctionReturnValue = .imageJpg
    imageValidator.validateBase64ImageAgainstThrowableError = TestingError.error

    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSample.credentialConfigurationsSupported.first?.value)

    XCTAssertThrowsError(
      try generator.generate(
        for: [credentialWithoutKeyBinding],
        selectedCredential: selectedCredential,
        context: mockCredentialGeneratorContext))
  }

  func testGenerate_withBatchSize_setsBatchData() throws {
    let context = makeContext(batchSize: 3)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredentialMock,
      context: context)

    XCTAssertEqual(credential.batchData, BatchData(batchSize: 3))
  }

  func testGenerate_withAuthentication_setsAuthentication() throws {
    let context = makeContext(authentication: mockAuthentication)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredentialMock,
      context: context)

    XCTAssertEqual(credential.authentication, mockAuthentication)
  }

  // MARK: - Generate Deferred credential

  func testGenerateDeferredCredential_withKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    assertDeferredCredential(credential, context: mockCredentialGeneratorContext, keyBindings: mockCredentialKeyBindings, deferredCredentialContext: mockDeferredCredentialContext)
  }

  func testGenerateDeferredCredential_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: [],
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    assertDeferredCredential(credential, context: mockCredentialGeneratorContext, keyBindings: [], deferredCredentialContext: mockDeferredCredentialContext)
  }

  func testGenerateDeferredCredential_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first?.value)

    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      selectedCredential: selectedCredential,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: Private

  private static let credentialNameMock = "credentialName"

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let selectedCredentialMock = CredentialIssuerMetadata.Mock.simpleSample.credentialConfigurationsSupported.first!.value

  private let mockAuthentication = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")
  private let mockPngDataURL = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="

  private let mockDeferredCredentialContext = DeferredCredentialContext.Mock.sample

  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)
  private lazy var mockCredentialKeyBindings = [mockCredentialKeyBinding]

  private var anyCredentialSpy = AnyCredentialSpy()
  private var claim1 = AnyClaimSpy()
  private var claim2 = AnyClaimSpy()
  private var claim3 = AnyClaimSpy()
  private var claim4 = AnyClaimSpy()
  private var claim5 = AnyClaimSpy()
  private var imageValidator = ImageValidatorProtocolSpy()
  private var valueTypeResolverSpy = ValueTypeResolverProtocolSpy()

  private lazy var credentialWithoutKeyBinding = CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)

  private var generator = MetadataCredentialGenerator()

  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private func assertDeferredCredential(
    _ deferredCredential: DeferredCredential,
    context: CredentialGeneratorContext,
    keyBindings: [KeyBinding], deferredCredentialContext: DeferredCredentialContext)
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

    assertCredentialDisplays(deferredCredential.displays, credentialId: context.credentialId)
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

  private func registerMocks() {
    imageValidator = ImageValidatorProtocolSpy()
    valueTypeResolverSpy = ValueTypeResolverProtocolSpy()

    Container.shared.imageValidator.register { self.imageValidator }
    Container.shared.valueTypeResolver.register { self.valueTypeResolverSpy }

    valueTypeResolverSpy.callAsFunctionReturnValue = .string

    anyCredentialSpy = AnyCredentialSpy()
    anyCredentialSpy.format = formatMock
    anyCredentialSpy.issuer = issuerMock
    anyCredentialSpy.validFrom = validFromMock
    anyCredentialSpy.validUntil = validUntilMock
    anyCredentialSpy.raw = rawPayloadMock

    claim1 = AnyClaimSpy()
    claim1.key = "lastName"
    claim1.path = [.string("lastName")]
    claim1.value = .string("lastName")

    claim2 = AnyClaimSpy()
    claim2.key = "isOver18"
    claim2.path = [.string("isOver18")]
    claim2.value = .bool(true)

    claim3 = AnyClaimSpy()
    claim3.key = "height"
    claim3.path = [.string("height")]
    claim3.value = .int(165)

    claim4 = AnyClaimSpy()
    claim4.key = "nullableClaim"
    claim4.path = [.string("nullableClaim")]
    claim4.value = nil

    claim5 = AnyClaimSpy()
    claim5.key = "photo"
    claim5.path = [.string("photo")]
    claim5.value = .string(mockPngDataURL)

    anyCredentialSpy.claims = [claim1, claim2, claim3, claim4, claim5]

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }

  private func assertClaims(_ claims: [CredentialClaim], isOrderMaxValue: Bool = false, valueType: ValueType? = nil) {
    let locales = ["de-CH", "en-US"]
    let expectedClaims = [
      ExpectedClaim(
        path: [.string(claim1.key)],
        value: claim1.value?.rawValue,
        valueType: .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 0,
        locales: locales),
      ExpectedClaim(
        path: [.string(claim2.key)],
        value: claim2.value?.rawValue,
        valueType: .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 1,
        locales: locales),
      ExpectedClaim(
        path: [.string(claim3.key)],
        value: claim3.value?.rawValue,
        valueType: .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 2,
        locales: locales),
      ExpectedClaim(
        path: [.string(claim4.key)],
        value: claim4.value?.rawValue,
        valueType: .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 3,
        locales: locales),
      ExpectedClaim(
        path: [.string(claim5.key)],
        value: valueType == .string ? claim5.value?.rawValue : mockPngDataURL,
        valueType: .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 4,
        locales: locales),
    ]
    assertClaimsEqual(claims, expectedClaims: expectedClaims)
  }
}

// swiftlint:enable all
