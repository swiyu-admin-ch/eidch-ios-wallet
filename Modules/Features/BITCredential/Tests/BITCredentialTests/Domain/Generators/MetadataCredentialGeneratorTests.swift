import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
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
    Container.shared.reset()
    registerMocks()
    generator = MetadataCredentialGenerator()
  }

  // MARK: - Generate Verifiable credential

  func testGenerate_withKeyPair_returnsCredential() throws {
    let credential = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: mockCredentialKeyBinding)],
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    assertCredential(credential, selectedKeyBinding: mockCredentialKeyBinding, rawPayload: anyCredentialSpy.raw)
    try assertClusters(in: credential)
  }

  func testGenerate_withoutKeyPair_returnsCredential() throws {
    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    assertCredential(credential, selectedKeyBinding: nil, rawPayload: anyCredentialSpy.raw)
  }

  func testGenerate_multipleCredentials_returnsCredentialWithMultipleBundleItems() throws {
    let credential = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: makeAnyCredential(rawPayload: rawPayloadMock1), keyBinding: mockCredentialKeyBinding),
        CredentialWithKeyBinding(credential: makeAnyCredential(rawPayload: rawPayloadMock2), keyBinding: mockCredentialKeyBinding),
      ],
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    XCTAssertEqual(credential.bundleItems.count, 2)
    XCTAssertEqual(String(data: credential.bundleItems[0].payload, encoding: .utf8), rawPayloadMock1)
    XCTAssertEqual(credential.bundleItems[0].keyBinding, mockCredentialKeyBinding)
    XCTAssertEqual(String(data: credential.bundleItems[1].payload, encoding: .utf8), rawPayloadMock2)
    XCTAssertEqual(credential.bundleItems[1].keyBinding, mockCredentialKeyBinding)
  }

  func testGenerate_withoutClaimDisplay_returnsCredentialClaimWithoutDisplay() throws {
    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first?.value)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredential,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(allClaims(in: credential.clusters).allSatisfy(\.displays.isEmpty))
  }

  func testGenerate_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first?.value)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredential,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(credential.displays.isEmpty)
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

  func testGenerateDeferredCredential_returnsDeferredCredential() throws {
    let deferredCredential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      selectedCredential: selectedCredentialMock,
      context: mockCredentialGeneratorContext)

    assertDeferredCredential(
      deferredCredential,
      context: mockCredentialGeneratorContext,
      keyBindings: mockCredentialKeyBindings,
      deferredCredentialContext: mockDeferredCredentialContext)
  }

  func testGenerateDeferredCredential_withoutCredentialDisplay_returnsCredentialWithoutCredentialDisplays() throws {
    let selectedCredential = try XCTUnwrap(CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays.credentialConfigurationsSupported.first?.value)

    let deferredCredential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      selectedCredential: selectedCredential,
      context: mockCredentialGeneratorContext)

    XCTAssertTrue(deferredCredential.displays.isEmpty)
  }

  func testGenerateDeferredCredential_withAuthentication_setsAuthentication() throws {
    let context = makeContext(authentication: mockAuthentication)

    let credential = try generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: mockCredentialKeyBindings,
      selectedCredential: selectedCredentialMock,
      context: context)

    XCTAssertEqual(credential.authentication, mockAuthentication)
  }

  // MARK: Private

  private static let credentialNameMock = "credentialName"

  private static let evidenceArrayPath: ClaimsPathPointer = [.string("verified_claims"), .string("verification"), .string("evidence"), .null]
  private static let evidenceItemPath: ClaimsPathPointer = [.string("verified_claims"), .string("verification"), .string("evidence"), .index(0)]
  private static let issuerNamePath: ClaimsPathPointer = [.string("verified_claims"), .string("verification"), .string("evidence"), .index(0), .string("document"), .string("issuer"), .string("name")]
  private static let nationalitiesArrayPath: ClaimsPathPointer = [.string("verified_claims"), .string("claims"), .string("nationalities"), .null]
  private static let birthMiddleNamePath: ClaimsPathPointer = [.string("birth_middle_name")]
  private static let salutationPath: ClaimsPathPointer = [.string("salutation")]
  private static let msisdnPath: ClaimsPathPointer = [.string("msisdn")]

  private let formatMock = "vc+sd-jwt"
  private let issuerMock = "issuer"
  private let validFromMock = Date()
  private let validUntilMock = Date()
  private let rawPayloadMock1 = "rawPayloadMock1"
  private let rawPayloadMock2 = "rawPayloadMock2"
  private let credentialComplexPayload = JSON.Mock.credentialComplex
  private lazy var selectedCredentialMock: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported =
    CredentialIssuerMetadata.Mock.credentialComplex.credentialConfigurationsSupported[Self.credentialNameMock]!

  private let mockAuthentication = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")
  private let mockDeferredCredentialContext = DeferredCredentialContext.Mock.sample
  private let mockCredentialGeneratorContext = CredentialGeneratorContext.Mock.sample
  private let mockCredentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)
  private lazy var mockCredentialKeyBindings = [mockCredentialKeyBinding]

  private lazy var anyCredentialSpy = makeAnyCredential()
  private lazy var credentialWithoutKeyBinding = CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)

  private var imageValidatorSpy = ImageValidatorProtocolSpy()
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var generator = MetadataCredentialGenerator()

  private func allClaims(in cluster: CredentialClaimCluster) -> [CredentialClaim] {
    cluster.claims + cluster.childClusters.flatMap(allClaims)
  }

  private func allClaims(in clusters: [CredentialClaimCluster]) -> [CredentialClaim] {
    clusters.flatMap(allClaims)
  }

  private func registerMocks() {
    imageValidatorSpy = ImageValidatorProtocolSpy()
    Container.shared.imageValidator.register { self.imageValidatorSpy }
    Container.shared.valueTypeResolver.register { ValueTypeResolver() }

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
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
    assertCredentialDisplays(credential.displays, credentialId: credential.id)
  }

  private func assertClusters(in credential: VerifiableCredential) throws {
    XCTAssertEqual(credential.clusters.count, 1)

    let rootCluster = try XCTUnwrap(credential.clusters.first)
    XCTAssertEqual(rootCluster.path, [])
    XCTAssertEqual(rootCluster.claims.count, 3)
    XCTAssertEqual(rootCluster.childClusters.count, 1)

    let rootClaimPaths = Set(rootCluster.claims.map(\.path.stringValue))
    XCTAssertEqual(rootClaimPaths, Set([
      Self.birthMiddleNamePath.stringValue,
      Self.salutationPath.stringValue,
      Self.msisdnPath.stringValue,
    ]))

    let verifiedClaimsCluster = try XCTUnwrap([.string("verified_claims")].findCluster(in: credential.clusters))
    XCTAssertEqual(verifiedClaimsCluster.displays.count, 2)

    let evidenceArrayCluster = try XCTUnwrap(Self.evidenceArrayPath.findCluster(in: credential.clusters))
    XCTAssertEqual(evidenceArrayCluster.order, 5)
    XCTAssertEqual(evidenceArrayCluster.displays.count, 2)
    XCTAssertTrue(evidenceArrayCluster.claims.isEmpty)
    XCTAssertEqual(evidenceArrayCluster.childClusters.count, 1)

    let evidenceItemCluster = try XCTUnwrap(Self.evidenceItemPath.findCluster(in: credential.clusters))
    XCTAssertEqual(evidenceItemCluster.claims.count, 3)
    XCTAssertEqual(evidenceItemCluster.childClusters.count, 1)

    let issuerPath: ClaimsPathPointer = [.string("verified_claims"), .string("verification"), .string("evidence"), .index(0), .string("document"), .string("issuer")]
    let issuerCluster = try XCTUnwrap(issuerPath.findCluster(in: credential.clusters))
    XCTAssertEqual(issuerCluster.claims.count, 2)

    let issuerNameClaim = try XCTUnwrap(Self.issuerNamePath.findClaim(in: credential.clusters))
    XCTAssertEqual(issuerNameClaim.value, "Stadt Augsburg")
    XCTAssertEqual(issuerNameClaim.displays.count, 2)

    let nationalitiesCluster = try XCTUnwrap(Self.nationalitiesArrayPath.findCluster(in: credential.clusters))
    XCTAssertEqual(nationalitiesCluster.order, 20)
    XCTAssertEqual(nationalitiesCluster.displays.count, 2)
    XCTAssertEqual(nationalitiesCluster.claims.count, 2)
    XCTAssertEqual(Set(nationalitiesCluster.claims.compactMap(\.value)), Set(["DE", "FR"]))
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

    assertCredentialDisplays(deferredCredential.displays, credentialId: context.credentialId)
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
    _ payload: JSON = JSON.Mock.credentialComplex,
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
}
