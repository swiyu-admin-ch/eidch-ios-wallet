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
    let credential = try generator.generate(for: anyCredentialSpy, selectedCredential: selectedCredentialMock, context: mockCredentialGeneratorContext)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContext.credentialId)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential.keyBinding, mockCredentialGeneratorContext.keyBinding)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContext.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContext.issuerDisplays)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, selectedCredential: selectedCredentialMock, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertEqual(credential.id, mockCredentialGeneratorContextWithoutKeyBinding.credentialId)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertNil(credential.keyBinding)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, mockCredentialGeneratorContextWithoutKeyBinding.rawCredentialData)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, mockCredentialGeneratorContextWithoutKeyBinding.issuerDisplays)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutClaimsOrder_returnsCredentialWithMaxOrder() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutOrder.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, selectedCredential: selectedCredential, context: mockCredentialGeneratorContextWithoutKeyBinding)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, isOrderMaxValue: true)
  }

  func testGenerate_withoutValueType_returnsCredentialWithStringValue() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutValueType.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, selectedCredential: selectedCredential, context: mockCredentialGeneratorContextWithoutKeyBinding)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, valueType: ValueType.string)
  }

  func testGenerate_withoutClaimDisplay_returnsCredentialClaimWithoutDisplay() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, selectedCredential: selectedCredential, context: mockCredentialGeneratorContextWithoutKeyBinding)

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      XCTAssertTrue(claim.displays.isEmpty)
    }
  }

  func testGenerate_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, selectedCredential: selectedCredential, context: mockCredentialGeneratorContextWithoutKeyBinding)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: - Generate Deferred credential

  func testGenerateDeferredCredential_withKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(mockDeferredCredentialRequest, selectedCredential: selectedCredentialMock, context: mockCredentialGeneratorContext)

    assertDeferredCredential(credential, context: mockCredentialGeneratorContext)
  }

  func testGenerateDeferredCredential_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generateDeferred(mockDeferredCredentialRequest, selectedCredential: selectedCredentialMock, context: mockCredentialGeneratorContextWithoutKeyBinding)

    assertDeferredCredential(credential, context: mockCredentialGeneratorContextWithoutKeyBinding)
  }

  func testGenerateDeferredCredential_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generateDeferred(mockDeferredCredentialRequest, selectedCredential: selectedCredential, context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
  }

  // MARK: Private

  private static let credentialNameMock = "credentialName"

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let rawPayloadMock = "rawPayload"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let selectedCredentialMock = CredentialMetadata.Mock.simpleSample.credentialConfigurationsSupported.first!.value

  private let mockDeferredCredentialRequest = DeferredCredentialRequest.Mock.sample

  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialGeneratorContextWithoutKeyBinding = CredentialGeneratorContext.Mock.sampleWithoutKeyBinding

  private var anyCredentialSpy = AnyCredentialSpy()
  private var claim1 = AnyClaimSpy()
  private var claim2 = AnyClaimSpy()
  private var claim3 = AnyClaimSpy()
  private var claim4 = AnyClaimSpy()

  private var generator = MetadataCredentialGenerator()

  private func assertDeferredCredential(_ deferredCredential: DeferredCredential, context: CredentialGeneratorContext) {
    XCTAssertEqual(deferredCredential.transactionId, mockDeferredCredentialRequest.transactionId)
    XCTAssertEqual(deferredCredential.accessToken, mockDeferredCredentialRequest.accessToken)
    XCTAssertEqual(deferredCredential.endpoint, mockDeferredCredentialRequest.endpoint)
    XCTAssertEqual(deferredCredential.format, mockDeferredCredentialRequest.format)
    XCTAssertEqual(deferredCredential.keyBinding, context.keyBinding)
    XCTAssertEqual(deferredCredential.rawCredentialData, context.rawCredentialData)
    XCTAssertEqual(deferredCredential.issuerDisplays, context.issuerDisplays)

    assertCredentialDisplays(deferredCredential.displays, credentialId: context.credentialId)
  }

  private func registerMocks() {
    anyCredentialSpy = AnyCredentialSpy()
    anyCredentialSpy.format = formatMock
    anyCredentialSpy.issuer = issuerMock
    anyCredentialSpy.validFrom = validFromMock
    anyCredentialSpy.validUntil = validUntilMock
    anyCredentialSpy.raw = rawPayloadMock

    claim1 = AnyClaimSpy()
    claim1.key = "$.lastName"
    claim1.value = .string("lastName")

    claim2 = AnyClaimSpy()
    claim2.key = "$.isOver18"
    claim2.value = .bool(true)

    claim3 = AnyClaimSpy()
    claim3.key = "$.height"
    claim3.value = .int(165)

    claim4 = AnyClaimSpy()
    claim4.key = "$.nullableClaim"
    claim4.value = nil

    anyCredentialSpy.claims = [claim1, claim2, claim3, claim4]
  }

  private func assertClaims(_ claims: [CredentialClaim], isOrderMaxValue: Bool = false, valueType: ValueType? = nil) {
    let locales = ["de-CH", "en-US"]
    let expectedClaims = [
      ExpectedClaim(
        key: claim1.key,
        value: claim1.value?.rawValue,
        valueType: valueType != nil ? valueType! : .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 1,
        locales: locales),
      ExpectedClaim(
        key: claim2.key,
        value: claim2.value?.rawValue,
        valueType: valueType != nil ? valueType! : .boolean,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 0,
        locales: locales),
      ExpectedClaim(
        key: claim3.key,
        value: claim3.value?.rawValue,
        valueType: valueType != nil ? valueType! : .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 2,
        locales: locales),
      ExpectedClaim(
        key: claim4.key,
        value: claim4.value?.rawValue,
        valueType: valueType != nil ? valueType! : .string,
        valueDisplayInfo: nil,
        order: isOrderMaxValue ? Int16.max : 3,
        locales: locales),
    ]
    assertClaimsEqual(claims, expectedClaims: expectedClaims)
  }
}

// swiftlint:enable all
