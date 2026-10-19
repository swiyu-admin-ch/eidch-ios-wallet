import Factory
import Foundation
import Spyable
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable force_try

// MARK: - CredentialGeneratorTests

@Suite(.serialized)
struct CredentialGeneratorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let keyManagerSpy = KeyManagerProtocolSpy()
    let ocaBundlerSpy = OcaBundlerProtocolSpy()
    let ocaCredentialGeneratorSpy = OcaCredentialGeneratorProtocolSpy()
    let metadataCredentialGeneratorSpy = MetadataCredentialGeneratorProtocolSpy()
    let trustInformationServiceSpy = TrustInformationServiceProtocolSpy()

    Container.shared.keyManager.register { keyManagerSpy }
    Container.shared.ocaBundler.register { ocaBundlerSpy }
    Container.shared.ocaCredentialGenerator.register { ocaCredentialGeneratorSpy }
    Container.shared.metadataCredentialGenerator.register { metadataCredentialGeneratorSpy }
    Container.shared.trustInformationService.register { trustInformationServiceSpy }

    keyManagerSpy.getExternalRepresentationOfReturnValue = Self.keyPairRawRepresentationMock
    ocaBundlerSpy.createOcaBundleReturnValue = Self.ocaBundleMock
    ocaCredentialGeneratorSpy.generateForOcaBundleContextReturnValue = Self.ocaCredential
    ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReturnValue = Self.deferredCredentialMock
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReturnValue = Self.metadataCredential
    metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReturnValue = Self.deferredCredentialMock
    trustInformationServiceSpy.getEntityNamesForReturnValue = nil

    self.ocaBundlerSpy = ocaBundlerSpy
    self.ocaCredentialGeneratorSpy = ocaCredentialGeneratorSpy
    self.metadataCredentialGeneratorSpy = metadataCredentialGeneratorSpy
    self.trustInformationServiceSpy = trustInformationServiceSpy
    generator = CredentialGenerator()
  }

  // MARK: Internal

  // MARK: - Generate verifiable credential

  @Test(arguments: [true, false])
  func generate_returnsTheCredentialOfTheMatchingGenerator(withOca: Bool) async throws {
    let credential = try await generate(withOca: withOca)

    #expect(credential == (withOca ? Self.ocaCredential : Self.metadataCredential))
    #expect(generateCallsCount(withOca: withOca) == 1)
  }

  @Test(arguments: [true, false])
  func generate_passesArguments(withOca: Bool) async throws {
    _ = try await generate(withOca: withOca)

    let arguments = try #require(capturedGenerateArguments(withOca: withOca))
    #expect(arguments.credentialsWithKeyBinding.count == 1)
    #expect(arguments.credentialsWithKeyBinding.first?.credential.raw == anyCredentialMock.raw)
    #expect(arguments.context.issuerUrl == Self.metadataWrapperMock.credentialIssuerMetadata.credentialIssuer)
    #expect(arguments.context.credentialConfigurationId == Self.metadataWrapperMock.credentialConfigurationId)
    #expect(arguments.hasOcaBundle == withOca)
    #expect(arguments.context.batchData == BatchData(batchSize: 10))
    #expect(arguments.context.rawCredentialData.rawOIDMetadata == Self.metadataWrapperMock.rawData)
    assertIssuerDisplays(arguments.context.issuerDisplays)

    let expectedRawOcaBundle: RawOcaBundle? = withOca ? Self.rawOcaBundleMock : nil
    #expect(arguments.context.rawCredentialData.rawOcaBundle == expectedRawOcaBundle)

    if withOca {
      #expect(ocaBundlerSpy.createOcaBundleReceivedData == Self.rawOcaBundleMock)
    } else {
      #expect(arguments.selectedCredential?.credentialMetadata?.claims == Self.metadataWrapperMock.selectedCredential.credentialMetadata?.claims)
    }
  }

  @Test(arguments: [true, false])
  func generate_multipleCredentials_passesAllCredentialsToTheGenerator(withOca: Bool) async throws {
    let secondCredential = MockAnyCredential(payload: Data("second-credential".utf8))

    _ = try await generate(
      withOca: withOca,
      credentials: [
        CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: Self.hardwareKeyBinding),
      ])

    let arguments = try #require(capturedGenerateArguments(withOca: withOca))
    #expect(arguments.credentialsWithKeyBinding.count == 2)
    #expect(arguments.credentialsWithKeyBinding[0].credential.raw == anyCredentialMock.raw)
    #expect(arguments.credentialsWithKeyBinding[0].keyBinding == Self.softwareKeyBinding)
    #expect(arguments.credentialsWithKeyBinding[1].credential.raw == secondCredential.raw)
    #expect(arguments.credentialsWithKeyBinding[1].keyBinding == Self.hardwareKeyBinding)
  }

  @Test(arguments: [true, false])
  func generate_noIssuerMetadata_returnsEmptyIssuerDisplays(withOca: Bool) async throws {
    let emptyMetadata = try createMetadataWrapper(metadataLocales: [], idTSLocales: nil)

    _ = try await generate(withOca: withOca, metadataWrapper: emptyMetadata)

    #expect(capturedGenerateArguments(withOca: withOca)?.context.issuerDisplays == [])
  }

  @Test(arguments: [true, false])
  func generate_generatorFailure_throwsError(withOca: Bool) async throws {
    if withOca {
      ocaCredentialGeneratorSpy.generateForOcaBundleContextThrowableError = TestingError.error
    } else {
      metadataCredentialGeneratorSpy.generateForSelectedCredentialContextThrowableError = TestingError.error
    }

    await #expect(throws: TestingError.error) {
      _ = try await generate(withOca: withOca)
    }
  }

  @Test(arguments: [true, false])
  func generate_passesAuthenticationContext(withOca: Bool) async throws {
    _ = try await generate(withOca: withOca, authentication: Self.authenticationWithRefreshTokenMock)

    #expect(capturedGenerateArguments(withOca: withOca)?.context.authentication == Self.authenticationWithRefreshTokenMock)
  }

  @Test(arguments: [true, false])
  func generate_passesTheKeyBindingItWasGiven(isHardwareBinding: Bool) async throws {
    let keyBinding = isHardwareBinding ? Self.hardwareKeyBinding : Self.softwareKeyBinding

    _ = try await generate(withOca: false, credentials: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: keyBinding)])

    #expect(capturedGenerateArguments(withOca: false)?.credentialsWithKeyBinding.first?.keyBinding == keyBinding)
  }

  @Test
  func generate_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try await generate(withOca: true)

    #expect(credential == Self.metadataCredential)
  }

  @Test
  func generate_withTP1_0EntityNames_generatesEntityNamesForIssuerDisplays() async throws {
    let metadataWrapper = try createMetadataWrapper(idTSLocales: nil)
    trustInformationServiceSpy.getEntityNamesForReturnValue = ["de-CH": "de-CH entityName", "en-US": "en-US entityName"]

    _ = try await generate(withOca: false, metadataWrapper: metadataWrapper)

    let issuerDisplays = try #require(capturedGenerateArguments(withOca: false)?.context.issuerDisplays)

    #expect(issuerDisplays.count == 2)
    #expect(issuerDisplays[0].locale == "de-CH")
    #expect(issuerDisplays[0].name == "de-CH entityName")
    #expect(issuerDisplays[0].image != nil)

    #expect(issuerDisplays[1].locale == "en-US")
    #expect(issuerDisplays[1].name == "en-US entityName")
    #expect(issuerDisplays[1].image != nil)
  }

  @Test
  func generate_withTP2_0EntityNames_displayImageMatchesLocaleVariations() async throws {
    let metadataWrapper = try createMetadataWrapper(metadataLocales: ["de-CH", "en-US", "fr", "es"], idTSLocales: ["de-CH", "en", "fr-CH", "rm"])

    _ = try await generate(withOca: false, metadataWrapper: metadataWrapper)

    let issuerDisplays = try #require(capturedGenerateArguments(withOca: false)?.context.issuerDisplays)

    // generated one display for each entity name
    #expect(issuerDisplays.count == 4)
    // de-CH matches de-CH
    #expect(issuerDisplays[0].image == metadataWrapper.credentialIssuerMetadata.display?[0].logo?.url?.dataURLData)
    // en matches en-US
    #expect(issuerDisplays[1].image == metadataWrapper.credentialIssuerMetadata.display?[1].logo?.url?.dataURLData)
    // fr-CH matches fr
    #expect(issuerDisplays[2].image == metadataWrapper.credentialIssuerMetadata.display?[2].logo?.url?.dataURLData)
    // rm -> no rm locale in metadata displays
    #expect(issuerDisplays[3].image == nil)
  }

  // MARK: - Generate deferred credential

  @Test(arguments: [true, false])
  func generateDeferred_returnsTheCredentialOfTheMatchingGenerator(withOca: Bool) async throws {
    let credential = try await generateDeferred(withOca: withOca)

    #expect(credential == Self.deferredCredentialMock)
    #expect(generateDeferredCallsCount(withOca: withOca) == 1)
  }

  @Test(arguments: [true, false])
  func generateDeferred_passesArguments(withOca: Bool) async throws {
    _ = try await generateDeferred(withOca: withOca)

    let arguments = try #require(capturedGenerateDeferredArguments(withOca: withOca))
    #expect(arguments.deferredCredentialContext == Self.deferredCredentialContextMock)
    #expect(arguments.keyBindings.first == Self.softwareKeyBinding)
    #expect(arguments.context.issuerUrl == Self.metadataWrapperMock.credentialIssuerMetadata.credentialIssuer)
    #expect(arguments.context.credentialConfigurationId == Self.metadataWrapperMock.credentialConfigurationId)
    #expect(arguments.hasOcaBundle == withOca)
    #expect(arguments.context.rawCredentialData.rawOIDMetadata == Self.metadataWrapperMock.rawData)
    assertIssuerDisplays(arguments.context.issuerDisplays)

    let expectedRawOcaBundle: RawOcaBundle? = withOca ? Self.rawOcaBundleMock : nil
    #expect(arguments.context.rawCredentialData.rawOcaBundle == expectedRawOcaBundle)

    if withOca {
      #expect(ocaBundlerSpy.createOcaBundleReceivedData == Self.rawOcaBundleMock)
    } else {
      #expect(arguments.selectedCredential?.credentialMetadata?.claims == Self.metadataWrapperMock.selectedCredential.credentialMetadata?.claims)
    }
  }

  @Test(arguments: [true, false])
  func generateDeferred_multipleKeyBindings_passesAllKeyBindingsToTheGenerator(withOca: Bool) async throws {
    let keyBindings = [Self.softwareKeyBinding, Self.hardwareKeyBinding]

    _ = try await generateDeferred(withOca: withOca, keyBindings: keyBindings)

    #expect(capturedGenerateDeferredArguments(withOca: withOca)?.keyBindings == keyBindings)
  }

  @Test(arguments: [true, false])
  func generateDeferred_noIssuerMetadata_returnsEmptyIssuerDisplays(withOca: Bool) async throws {
    let emptyMetadata = try createMetadataWrapper(metadataLocales: [], idTSLocales: nil)

    _ = try await generateDeferred(withOca: withOca, metadataWrapper: emptyMetadata)

    #expect(capturedGenerateDeferredArguments(withOca: withOca)?.context.issuerDisplays == [])
  }

  @Test(arguments: [true, false])
  func generateDeferred_generatorFailure_throwsError(withOca: Bool) async throws {
    if withOca {
      ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextThrowableError = TestingError.error
    } else {
      metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextThrowableError = TestingError.error
    }

    await #expect(throws: TestingError.error) {
      _ = try await generateDeferred(withOca: withOca)
    }
  }

  @Test(arguments: [true, false])
  func generateDeferred_passesTheKeyBindingItWasGiven(isHardwareBinding: Bool) async throws {
    let keyBinding = isHardwareBinding ? Self.hardwareKeyBinding : Self.softwareKeyBinding

    _ = try await generateDeferred(withOca: false, keyBindings: [keyBinding])

    #expect(capturedGenerateDeferredArguments(withOca: false)?.keyBindings.first == keyBinding)
  }

  @Test
  func generateDeferred_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try await generateDeferred(withOca: true)

    #expect(credential == Self.deferredCredentialMock)
    #expect(generateDeferredCallsCount(withOca: false) == 1)
  }

  // MARK: Private

  private struct CapturedGenerateArguments {
    let credentialsWithKeyBinding: [CredentialWithKeyBinding]
    let context: CredentialGeneratorContext
    let hasOcaBundle: Bool
    let selectedCredential: (any CredentialIssuerMetadata.AnyCredentialConfigurationSupported)?
  }

  private struct CapturedGenerateDeferredArguments {
    let deferredCredentialContext: DeferredCredentialContext
    let keyBindings: [KeyBinding]
    let context: CredentialGeneratorContext
    let hasOcaBundle: Bool
    let selectedCredential: (any CredentialIssuerMetadata.AnyCredentialConfigurationSupported)?
  }

  private static let keyID = UUID()
  private static let keyAlgorithm = "ES256"
  private static let keyPairRawRepresentationMock = (Data("publicKeyData".utf8), Data("privateKeyData".utf8))
  private static let hardwareKeyBinding = KeyBinding(id: keyID, algorithm: keyAlgorithm, bindingType: .hardware)
  private static let softwareKeyBinding = KeyBinding(id: keyID, algorithm: keyAlgorithm, bindingType: .software, publicKey: keyPairRawRepresentationMock.0, privateKey: keyPairRawRepresentationMock.1)

  private static let metadataWrapperMock = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", metadataJws: CredentialIssuerMetadataJWT.Mock.simpleSample)
  private static let authenticationMock = CredentialAuthentication(accessToken: "accessToken")
  private static let authenticationWithRefreshTokenMock = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")
  private static let ocaBundleMock: OcaBundle = .Mock.simpleSample
  private static let rawOcaBundleMock: RawOcaBundle = OcaBundle.Mock.simpleSampleData
  private static let deferredCredentialContextMock: DeferredCredentialContext = .Mock.sample
  private static let deferredCredentialMock: DeferredCredential = .Mock.sample
  private static let ocaCredential: VerifiableCredential = .Mock.sample
  private static let metadataCredential: VerifiableCredential = .Mock.sampleDisplaysFallback

  private let anyCredentialMock = MockAnyCredential()
  private let ocaBundlerSpy: OcaBundlerProtocolSpy
  private let ocaCredentialGeneratorSpy: OcaCredentialGeneratorProtocolSpy
  private let metadataCredentialGeneratorSpy: MetadataCredentialGeneratorProtocolSpy
  private let trustInformationServiceSpy: TrustInformationServiceProtocolSpy
  private let generator: CredentialGenerator

  private func generate(
    withOca: Bool,
    credentials: [CredentialWithKeyBinding]? = nil,
    metadataWrapper: CredentialIssuerMetadataWrapper? = nil,
    authentication: CredentialAuthentication? = nil) async throws
    -> VerifiableCredential
  {
    try await generator.generate(
      for: credentials ?? [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: withOca ? Self.rawOcaBundleMock : nil,
      metadataWrapper: metadataWrapper ?? Self.metadataWrapperMock,
      authentication: authentication ?? Self.authenticationMock)
  }

  private func generateDeferred(
    withOca: Bool,
    keyBindings: [KeyBinding]? = nil,
    metadataWrapper: CredentialIssuerMetadataWrapper? = nil,
    authentication: CredentialAuthentication? = nil) async throws
    -> DeferredCredential
  {
    try await generator.generateDeferred(
      Self.deferredCredentialContextMock,
      keyBindings: keyBindings ?? [Self.softwareKeyBinding],
      rawOcaBundle: withOca ? Self.rawOcaBundleMock : nil,
      metadataWrapper: metadataWrapper ?? Self.metadataWrapperMock,
      authentication: authentication ?? Self.authenticationMock)
  }

  private func generateCallsCount(withOca: Bool) -> Int {
    withOca
      ? ocaCredentialGeneratorSpy.generateForOcaBundleContextCallsCount
      : metadataCredentialGeneratorSpy.generateForSelectedCredentialContextCallsCount
  }

  private func generateDeferredCallsCount(withOca: Bool) -> Int {
    withOca
      ? ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextCallsCount
      : metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextCallsCount
  }

  private func capturedGenerateArguments(withOca: Bool) -> CapturedGenerateArguments? {
    if withOca {
      guard let arguments = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments else { return nil }
      return CapturedGenerateArguments(
        credentialsWithKeyBinding: arguments.credentialsWithKeyBinding,
        context: arguments.context,
        hasOcaBundle: true,
        selectedCredential: nil)
    }
    guard let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments else { return nil }
    return CapturedGenerateArguments(
      credentialsWithKeyBinding: arguments.credentialsWithKeyBinding,
      context: arguments.context,
      hasOcaBundle: false,
      selectedCredential: arguments.selectedCredential)
  }

  private func capturedGenerateDeferredArguments(withOca: Bool) -> CapturedGenerateDeferredArguments? {
    if withOca {
      guard let arguments = ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReceivedArguments else { return nil }
      return CapturedGenerateDeferredArguments(
        deferredCredentialContext: arguments.deferredCredentialContext,
        keyBindings: arguments.keyBindings,
        context: arguments.context,
        hasOcaBundle: true,
        selectedCredential: nil)
    }
    guard let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments else { return nil }
    return CapturedGenerateDeferredArguments(
      deferredCredentialContext: arguments.deferredCredentialContext,
      keyBindings: arguments.keyBindings,
      context: arguments.context,
      hasOcaBundle: false,
      selectedCredential: arguments.selectedCredential)
  }

  private func createMetadataWrapper(metadataLocales: [String] = ["de-CH", "en-US"], idTSLocales: [String]?) throws -> CredentialIssuerMetadataWrapper {
    let displays = metadataLocales.map {
      let base64 = Data($0.utf8).base64EncodedString()
      return CredentialIssuerMetadata.Display(name: "issuer \($0)", locale: $0, logo: CredentialIssuerMetadata.Logo(url: URL(string: "data:image/png;base64,\(base64)")))
    }
    var metadata = CredentialIssuerMetadata.Mock.simpleSample.changing(\.display, to: displays)
    var idTS: IdentityTrustStatement? = nil
    if let idTSLocales {
      let entityNames = idTSLocales.compactGroupWith {
        "\($0) entityName"
      }
      let idTSJwt = IdentityTrustStatementJWT.Mock.validSamplePayload.changing(\.entityNames, to: LocalizedDisplay(values: entityNames))
      idTS = IdentityTrustStatementJWT.Mock.createJWS(payload: idTSJwt)
    }
    metadata = metadata.changing(\.identityTrustStatement, to: idTS)
    return try CredentialIssuerMetadataWrapper(
      credentialConfigurationId: "credentialName",
      metadataJws: CredentialIssuerMetadataJWT.Mock.createJWS(from: metadata))
  }

  private func assertIssuerDisplays(_ displays: [CredentialIssuerDisplay], sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(displays.count == 2, sourceLocation: sourceLocation)
    guard displays.count == 2 else { return }

    #expect(displays[0].locale == "de-CH", sourceLocation: sourceLocation)
    #expect(displays[0].name == "de-CH entityName", sourceLocation: sourceLocation)
    #expect(displays[0].image != nil, sourceLocation: sourceLocation)

    #expect(displays[1].locale == "en", sourceLocation: sourceLocation)
    #expect(displays[1].name == "EN entityName", sourceLocation: sourceLocation)
    #expect(displays[1].image != nil, sourceLocation: sourceLocation)
  }
}

// swiftlint:enable force_try
