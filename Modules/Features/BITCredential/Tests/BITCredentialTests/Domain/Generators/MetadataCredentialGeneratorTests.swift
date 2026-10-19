import Factory
import Foundation
import Testing
@testable import BITAnyCredentialFormat
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping force_try

// MARK: - MetadataCredentialGeneratorTests

@Suite(.serialized)
struct MetadataCredentialGeneratorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let imageValidatorSpy = ImageValidatorProtocolSpy()
    Container.shared.imageValidator.register { imageValidatorSpy }
    Container.shared.valueTypeResolver.register { ValueTypeResolver() }

    self.imageValidatorSpy = imageValidatorSpy
    anyCredentialSpy = Self.makeAnyCredential()
    credentialWithoutKeyBinding = CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: nil)
    generator = MetadataCredentialGenerator()

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }

  // MARK: Internal

  // MARK: - Generate Verifiable credential

  @Test(arguments: [true, false])
  func generate_returnsCredentialWithTheKeyBindingItWasGivenIfAny(hasKeyBinding: Bool) throws {
    let credentials = hasKeyBinding
      ? [CredentialWithKeyBinding(credential: anyCredentialSpy, keyBinding: Self.credentialKeyBinding)]
      : [credentialWithoutKeyBinding]

    let credential = try generator.generate(
      for: credentials,
      selectedCredential: selectedCredentialMock,
      context: Self.credentialGeneratorContextMock)

    assertCredential(credential, selectedKeyBinding: hasKeyBinding ? Self.credentialKeyBinding : nil, rawPayload: anyCredentialSpy.raw)
    try assertClusters(in: credential)
  }

  @Test
  func generate_multipleCredentials_returnsCredentialWithMultipleBundleItems() throws {
    let credential = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: Self.makeAnyCredential(rawPayload: Self.rawPayloadMock1), keyBinding: Self.credentialKeyBinding),
        CredentialWithKeyBinding(credential: Self.makeAnyCredential(rawPayload: Self.rawPayloadMock2), keyBinding: Self.credentialKeyBinding),
      ],
      selectedCredential: selectedCredentialMock,
      context: Self.credentialGeneratorContextMock)

    #expect(credential.bundleItems.count == 2)
    #expect(String(data: credential.bundleItems[0].payload, encoding: .utf8) == Self.rawPayloadMock1)
    #expect(credential.bundleItems[0].keyBinding == Self.credentialKeyBinding)
    #expect(String(data: credential.bundleItems[1].payload, encoding: .utf8) == Self.rawPayloadMock2)
    #expect(credential.bundleItems[1].keyBinding == Self.credentialKeyBinding)
  }

  @Test(arguments: [false, true])
  func generate_withoutDisplays_returnsCredentialWithoutDisplays(isDeferred: Bool) throws {
    let metadata = CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplays
    let selectedCredential = try #require(metadata.credentialConfigurationsSupported.first?.value)

    if isDeferred {
      let deferredCredential = try generator.generateDeferred(
        Self.deferredCredentialContextMock,
        keyBindings: Self.credentialKeyBindings,
        selectedCredential: selectedCredential,
        context: Self.credentialGeneratorContextMock)

      #expect(deferredCredential.displays.isEmpty)
    } else {
      let credential = try generator.generate(
        for: [credentialWithoutKeyBinding],
        selectedCredential: selectedCredential,
        context: Self.credentialGeneratorContextMock)

      let everyClaimHasNoDisplay = allClaims(in: credential.clusters).allSatisfy(\.displays.isEmpty)
      #expect(credential.displays.isEmpty)
      #expect(everyClaimHasNoDisplay)
    }
  }

  @Test
  func generate_withBatchSize_setsBatchData() throws {
    let context = makeContext(batchSize: 3)

    let credential = try generator.generate(
      for: [credentialWithoutKeyBinding],
      selectedCredential: selectedCredentialMock,
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
        selectedCredential: selectedCredentialMock,
        context: context).authentication
    } else {
      try generator.generate(
        for: [credentialWithoutKeyBinding],
        selectedCredential: selectedCredentialMock,
        context: context).authentication
    }

    #expect(authentication == Self.authenticationMock)
  }

  @Test
  func generateDeferredCredential_returnsDeferredCredential() throws {
    let deferredCredential = try generator.generateDeferred(
      Self.deferredCredentialContextMock,
      keyBindings: Self.credentialKeyBindings,
      selectedCredential: selectedCredentialMock,
      context: Self.credentialGeneratorContextMock)

    assertDeferredCredential(
      deferredCredential,
      context: Self.credentialGeneratorContextMock,
      keyBindings: Self.credentialKeyBindings,
      deferredCredentialContext: Self.deferredCredentialContextMock)
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

  private static let formatMock = CredentialFormat.vcSdJwt
  private static let issuerMock = "issuer"
  private static let validFromMock = Date()
  private static let validUntilMock = Date()
  private static let rawPayloadMock1 = "rawPayloadMock1"
  private static let rawPayloadMock2 = "rawPayloadMock2"

  private static let authenticationMock = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")
  private static let deferredCredentialContextMock = DeferredCredentialContext.Mock.sample
  private static let credentialGeneratorContextMock = CredentialGeneratorContext.Mock.sample
  private static let credentialKeyBinding = KeyBinding(id: UUID(), algorithm: "ES512", bindingType: .hardware)
  private static let credentialKeyBindings = [credentialKeyBinding]

  private let anyCredentialSpy: AnyCredentialSpy
  private let credentialWithoutKeyBinding: CredentialWithKeyBinding
  private let imageValidatorSpy: ImageValidatorProtocolSpy
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()
  private let generator: MetadataCredentialGenerator

  private var selectedCredentialMock: any CredentialIssuerMetadata.AnyCredentialConfigurationSupported {
    CredentialIssuerMetadata.Mock.credentialComplex.credentialConfigurationsSupported[Self.credentialNameMock]!
  }

  private static func makeAnyCredential(
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

  private func allClaims(in cluster: CredentialClaimCluster) -> [CredentialClaim] {
    cluster.claims + cluster.childClusters.flatMap(allClaims)
  }

  private func allClaims(in clusters: [CredentialClaimCluster]) -> [CredentialClaim] {
    clusters.flatMap(allClaims)
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
    #expect(credential.issuer == Self.issuerMock)
    #expect(credential.validFrom == Self.validFromMock)
    #expect(credential.validUntil == Self.validUntilMock)
    #expect(credential.issuerDisplays == Self.credentialGeneratorContextMock.issuerDisplays)
    assertCredentialDisplays(credential.displays)
  }

  private func assertClusters(in credential: VerifiableCredential) throws {
    #expect(credential.clusters.count == 1)

    let rootCluster = try #require(credential.clusters.first)
    #expect(rootCluster.path == [])
    #expect(rootCluster.claims.count == 3)
    #expect(rootCluster.childClusters.count == 1)

    let rootClaimPaths = Set(rootCluster.claims.map(\.path.stringValue))
    #expect(rootClaimPaths == Set([
      Self.birthMiddleNamePath.stringValue,
      Self.salutationPath.stringValue,
      Self.msisdnPath.stringValue,
    ]))

    let verifiedClaimsCluster = try #require([.string("verified_claims")].findCluster(in: credential.clusters))
    #expect(verifiedClaimsCluster.displays.count == 2)

    let evidenceArrayCluster = try #require(Self.evidenceArrayPath.findCluster(in: credential.clusters))
    #expect(evidenceArrayCluster.order == 5)
    #expect(evidenceArrayCluster.displays.count == 2)
    #expect(evidenceArrayCluster.claims.isEmpty)
    #expect(evidenceArrayCluster.childClusters.count == 1)

    let evidenceItemCluster = try #require(Self.evidenceItemPath.findCluster(in: credential.clusters))
    #expect(evidenceItemCluster.claims.count == 3)
    #expect(evidenceItemCluster.childClusters.count == 1)

    let issuerPath: ClaimsPathPointer = [.string("verified_claims"), .string("verification"), .string("evidence"), .index(0), .string("document"), .string("issuer")]
    let issuerCluster = try #require(issuerPath.findCluster(in: credential.clusters))
    #expect(issuerCluster.claims.count == 2)

    let issuerNameClaim = try #require(Self.issuerNamePath.findClaim(in: credential.clusters))
    #expect(issuerNameClaim.value == "Stadt Augsburg")
    #expect(issuerNameClaim.displays.count == 2)

    let nationalitiesCluster = try #require(Self.nationalitiesArrayPath.findCluster(in: credential.clusters))
    #expect(nationalitiesCluster.order == 20)
    #expect(nationalitiesCluster.displays.count == 2)
    #expect(nationalitiesCluster.claims.count == 2)
    #expect(Set(nationalitiesCluster.claims.compactMap(\.value)) == Set(["DE", "FR"]))
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

    assertCredentialDisplays(deferredCredential.displays)
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
