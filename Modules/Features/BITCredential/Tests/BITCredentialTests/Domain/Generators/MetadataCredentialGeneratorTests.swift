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

  func testGenerate_withKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyBinding: keyBindingMock, selectedCredential: selectedCredentialMock, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertEqual(credential.id, idMock)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertEqual(credential.keyBinding, keyBindingMock)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, rawCredentialDataMock)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertEqual(credential.validUntil, validUntilMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, issuerDisplaysMock)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyBinding: nil, selectedCredential: selectedCredentialMock, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertEqual(credential.id, idMock)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertNil(credential.keyBinding)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, rawCredentialDataMock)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertEqual(credential.issuerDisplays, issuerDisplaysMock)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutClaimsOrder_returnsCredentialWithMaxOrder() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutOrder.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyBinding: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, isOrderMaxValue: true)
  }

  func testGenerate_withoutValueType_returnsCredentialWithStringValue() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutValueType.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyBinding: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, valueType: ValueType.string)
  }

  func testGenerate_withoutClaimDisplay_returnsCredentialClaimWithoutDisplay() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyBinding: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      XCTAssertTrue(claim.displays.isEmpty)
    }
  }

  func testGenerate_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyBinding: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

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
  private let idMock = UUID()
  private let issuerDisplaysMock = [CredentialIssuerDisplay(id: UUID(), credentialId: nil, image: nil)]
  private let rawCredentialDataMock = RawCredentialData()
  private let keyBindingMock = CredentialKeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)

  private var anyCredentialSpy = AnyCredentialSpy()
  private var claim1 = AnyClaimSpy()
  private var claim2 = AnyClaimSpy()
  private var claim3 = AnyClaimSpy()
  private var claim4 = AnyClaimSpy()

  private var generator = MetadataCredentialGenerator()

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
