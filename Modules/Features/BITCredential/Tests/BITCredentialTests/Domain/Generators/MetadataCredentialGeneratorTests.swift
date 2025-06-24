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
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: keyPairMock, selectedCredential: selectedCredentialMock, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

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
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, selectedCredential: selectedCredentialMock, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    XCTAssertEqual(credential.id, idMock)
    XCTAssertEqual(credential.status, .unknown)
    XCTAssertNil(credential.keyBindingIdentifier)
    XCTAssertNil(credential.keyBindingAlgorithm)
    XCTAssertEqual(String(data: credential.payload, encoding: .utf8)!, rawPayloadMock)
    XCTAssertEqual(credential.rawCredentialData, rawCredentialDataMock)
    XCTAssertEqual(credential.format, formatMock)
    XCTAssertEqual(credential.issuer, issuerMock)
    XCTAssertEqual(credential.validFrom, validFromMock)
    XCTAssertNotNil(credential.createdAt)
    XCTAssertNil(credential.updatedAt)
    XCTAssertEqual(credential.issuerDisplays, issuerDisplaysMock)
    XCTAssertEqual(credential.clusters.count, 1)

    assertClaims(credential.clusters.first?.claims ?? [])
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  func testGenerate_withoutClaimsOrder_returnsCredentialWithMaxOrder() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutOrder.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, isOrderMaxValue: true)
  }

  func testGenerate_withoutValueType_returnsCredentialWithStringValue() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutValueType.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    assertClaims(claims, valueType: ValueType.string)
  }

  func testGenerate_withoutClaimDisplay_returnsCredentialClaimWithoutDisplay() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

    let claims = credential.clusters.first?.claims ?? []
    for claim in claims {
      XCTAssertTrue(claim.displays.isEmpty)
    }
  }

  func testGenerate_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = CredentialMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first!.value

    let credential = try generator.generate(for: anyCredentialSpy, id: idMock, keyPair: nil, selectedCredential: selectedCredential, issuerDisplays: issuerDisplaysMock, rawCredentialData: rawCredentialDataMock)

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
  private let selectedCredentialMock = CredentialMetadata.Mock.simpleSample.credentialConfigurationsSupported.first!.value
  private let idMock = UUID()
  private let issuerDisplaysMock = [CredentialIssuerDisplay(id: UUID(), credentialId: nil, image: nil)]
  private let rawCredentialDataMock = RawCredentialData()

  private var keyPairMock = KeyPair(identifier: keyPairIdentifier, algorithm: keyPairAlgorithm, privateKey: mockPrivateKey)
  private var anyCredentialSpy = AnyCredentialSpy()
  private var firstClaim = AnyClaimSpy()
  private var secondClaim = AnyClaimSpy()
  private var thirdClaim = AnyClaimSpy()

  private var generator = MetadataCredentialGenerator()

  private func registerMocks() {
    anyCredentialSpy = AnyCredentialSpy()
    anyCredentialSpy.format = formatMock
    anyCredentialSpy.issuer = issuerMock
    anyCredentialSpy.validFrom = validFromMock
    anyCredentialSpy.validUntil = validUntilMock
    anyCredentialSpy.raw = rawPayloadMock

    firstClaim = AnyClaimSpy()
    firstClaim.key = "$.lastName"
    firstClaim.value = .string("lastName")

    secondClaim = AnyClaimSpy()
    secondClaim.key = "$.isOver18"
    secondClaim.value = .bool(true)

    thirdClaim = AnyClaimSpy()
    thirdClaim.key = "$.height"
    thirdClaim.value = .int(165)

    anyCredentialSpy.claims = [firstClaim, secondClaim, thirdClaim]
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
        order: isOrderMaxValue ? Int16.max : 0,
        locales: locales),
      ExpectedClaim(
        key: thirdClaim.key,
        value: thirdClaim.value!.rawValue,
        valueType: valueType != nil ? valueType! : .string,
        order: isOrderMaxValue ? Int16.max : 2,
        locales: locales),
    ]
    assertClaimsEqual(claims, expectedClaims: expectedClaims)
  }
}

// swiftlint:enable all
