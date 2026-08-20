import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable force_unwrapping force_try implicitly_unwrapped_optional

final class CredentialGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    generator = CredentialGenerator()
    success()
  }

  // MARK: - Generate verifiable credential

  func testGenerate_withOca_returnsCredentialFromOcaGenerator() async throws {
    let credential = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(credential, ocaCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateForOcaBundleContextCallsCount, 1)
  }

  func testGenerate_withOca_argumentsPassed() async throws {
    _ = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(ocaBundlerSpy.createOcaBundleReceivedData, rawOcaBundleMock)
    if let arguments = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.count, 1)
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.credential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.context.issuerUrl, metadataWrapperMock.credentialIssuerMetadata.credentialIssuer)
      XCTAssertEqual(arguments.context.credentialConfigurationId, metadataWrapperMock.credentialConfigurationId)
      XCTAssertNotNil(arguments.ocaBundle)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.batchData, BatchData(batchSize: 10))
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOcaBundle, rawOcaBundleMock)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withOca_multipleCredentials_passesAllCredentialsToOcaGenerator() async throws {
    let secondCredential = try MockAnyCredential(payload: XCTUnwrap("second-credential".data(using: .utf8)))

    _ = try await generator.generate(
      for: [
        CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: Self.hardwareKeyBinding),
      ],
      rawOcaBundle: rawOcaBundleMock,
      metadataWrapper: metadataWrapperMock,
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    if let arguments = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.count, 2)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[0].credential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[0].keyBinding, Self.softwareKeyBinding)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[1].credential.raw, secondCredential.raw)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[1].keyBinding, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withoutOca_returnsCredentialFromMetadataGenerator() async throws {
    let credential = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(credential, metadataCredential)
    XCTAssertEqual(metadataCredentialGeneratorSpy.generateForSelectedCredentialContextCallsCount, 1)
  }

  func testGenerate_withoutOca_argumentsPassed() async throws {
    _ = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.count, 1)
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.credential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.context.issuerUrl, metadataWrapperMock.credentialIssuerMetadata.credentialIssuer)
      XCTAssertEqual(arguments.context.credentialConfigurationId, metadataWrapperMock.credentialConfigurationId)
      XCTAssertEqual(arguments.selectedCredential.credentialMetadata?.claims, metadataWrapperMock.selectedCredential.credentialMetadata?.claims)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.batchData, BatchData(batchSize: 10))
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertNil(arguments.context.rawCredentialData.rawOcaBundle)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withoutOca_multipleCredentials_passesAllCredentialsToMetadataGenerator() async throws {
    let secondCredential = try MockAnyCredential(payload: XCTUnwrap("second-credential".data(using: .utf8)))

    _ = try await generator.generate(
      for: [
        CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: Self.hardwareKeyBinding),
      ],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapperMock,
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.count, 2)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[0].credential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[0].keyBinding, Self.softwareKeyBinding)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[1].credential.raw, secondCredential.raw)
      XCTAssertEqual(arguments.credentialsWithKeyBinding[1].keyBinding, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withTP1_0EntityNames_generatesEntityNamesForIssuerDisplays() async throws {
    let metadataWrapper = try createMetadataWrapper(idTSLocales: nil)
    trustInformationServiceSpy.getEntityNamesForReturnValue = ["de-CH": "de-CH entityName", "en-US": "en-US entityName"]

    _ = try await generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapper,
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    guard let issuerDisplays = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.issuerDisplays else {
      XCTFail("Issuer displays not passed")
      return
    }

    XCTAssertEqual(issuerDisplays.count, 2)
    XCTAssertEqual(issuerDisplays[0].locale, "de-CH")
    XCTAssertEqual(issuerDisplays[0].name, "de-CH entityName")
    XCTAssertNotNil(issuerDisplays[0].image)

    XCTAssertEqual(issuerDisplays[1].locale, "en-US")
    XCTAssertEqual(issuerDisplays[1].name, "en-US entityName")
    XCTAssertNotNil(issuerDisplays[1].image)
  }

  func testGenerate_withTP2_0EntityNames_displayImageMatchesLocaleVariations() async throws {
    let metadataWrapper = try createMetadataWrapper(metadataLocales: ["de-CH", "en-US", "fr", "es"], idTSLocales: ["de-CH", "en", "fr-CH", "rm"])

    _ = try await generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapper,
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    guard let issuerDisplays = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.issuerDisplays else {
      XCTFail("No issuer displays")
      return
    }

    // generated one display for each entity name
    XCTAssertEqual(issuerDisplays.count, 4)
    // de-CH matches de-CH
    XCTAssertEqual(issuerDisplays[0].image, metadataWrapper.credentialIssuerMetadata.display?[0].logo?.url?.dataURLData)
    // en matches en-US
    XCTAssertEqual(issuerDisplays[1].image, metadataWrapper.credentialIssuerMetadata.display?[1].logo?.url?.dataURLData)
    // fr-CH matches fr
    XCTAssertEqual(issuerDisplays[2].image, metadataWrapper.credentialIssuerMetadata.display?[2].logo?.url?.dataURLData)
    // rm -> no rm locale in metadata displays
    XCTAssertNil(issuerDisplays[3].image)
  }

  func testGenerate_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(credential, metadataCredential)
  }

  func testGenerate_ocaCredentialGeneratorFailure_throwsError() async throws {
    ocaCredentialGeneratorSpy.generateForOcaBundleContextThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_metadataCredentialGeneratorFailure_throwsError() async throws {
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() async throws {
    let emptyMetadata = try createMetadataWrapper(metadataLocales: [], idTSLocales: nil)

    _ = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata, authentication: CredentialAuthentication(accessToken: "accessToken"))

    let issuerDisplays = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() async throws {
    let emptyMetadata = try createMetadataWrapper(metadataLocales: [], idTSLocales: nil)

    _ = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: emptyMetadata, authentication: CredentialAuthentication(accessToken: "accessToken"))

    let issuerDisplays = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_vaultOptionsSecureEnclave_hardwareBindingArgumentsPassed() async throws {
    _ = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.hardwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: CredentialAuthentication(accessToken: "accessToken"))

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.keyBinding, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_vaultOptionsSafePermanently_softwareBindingArgumentsPassed() async throws {
    _ = try await generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.keyBinding, Self.softwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  // MARK: - Generate deferred credential

  func testGenerateDeferredCredential_withOca_returnsCredentialFromOcaGenerator() async throws {
    let credential = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    XCTAssertEqual(credential, mockDeferredCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextCallsCount, 1)
  }

  func testGenerateDeferredCredential_withOca_argumentsPassed() async throws {
    _ = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    XCTAssertEqual(ocaBundlerSpy.createOcaBundleReceivedData, rawOcaBundleMock)
    if let arguments = ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.deferredCredentialContext, mockDeferredCredentialContext)
      XCTAssertEqual(arguments.keyBindings.first, Self.softwareKeyBinding)
      XCTAssertEqual(arguments.context.issuerUrl, metadataWrapperMock.credentialIssuerMetadata.credentialIssuer)
      XCTAssertEqual(arguments.context.credentialConfigurationId, metadataWrapperMock.credentialConfigurationId)
      XCTAssertNotNil(arguments.ocaBundle)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOcaBundle, rawOcaBundleMock)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_withOca_multipleKeyBindings_passesAllKeyBindingsToOcaGenerator() async throws {
    let keyBindings = [Self.softwareKeyBinding, Self.hardwareKeyBinding]

    _ = try await generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: keyBindings,
      rawOcaBundle: rawOcaBundleMock,
      metadataWrapper: metadataWrapperMock,
      authentication: authenticationMock)

    if let arguments = ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.keyBindings, keyBindings)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_withoutOca_argumentsPassed() async throws {
    _ = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.deferredCredentialContext, mockDeferredCredentialContext)
      XCTAssertEqual(arguments.keyBindings.first, Self.softwareKeyBinding)
      XCTAssertEqual(arguments.context.issuerUrl, metadataWrapperMock.credentialIssuerMetadata.credentialIssuer)
      XCTAssertEqual(arguments.context.credentialConfigurationId, metadataWrapperMock.credentialConfigurationId)
      XCTAssertEqual(arguments.selectedCredential.credentialMetadata?.claims, metadataWrapperMock.selectedCredential.credentialMetadata?.claims)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertNil(arguments.context.rawCredentialData.rawOcaBundle)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_withoutOca_multipleKeyBindings_passesAllKeyBindingsToMetadataGenerator() async throws {
    let keyBindings = [Self.softwareKeyBinding, Self.hardwareKeyBinding]

    _ = try await generator.generateDeferred(
      mockDeferredCredentialContext,
      keyBindings: keyBindings,
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapperMock,
      authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.keyBindings, keyBindings)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    XCTAssertEqual(credential, mockDeferredCredential)
  }

  func testGenerateDeferredCredential_ocaCredentialGeneratorFailure_throwsError() async throws {
    ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerateDeferredCredential_metadataCredentialGeneratorFailure_throwsError() async throws {
    metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerateDeferredCredential_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() async throws {
    let emptyMetadata = try createMetadataWrapper(metadataLocales: [], idTSLocales: nil)

    _ = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata, authentication: authenticationMock)

    let issuerDisplays = ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerateDeferredCredential_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() async throws {
    let emptyMetadata = try createMetadataWrapper(metadataLocales: [], idTSLocales: nil)

    _ = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: emptyMetadata, authentication: authenticationMock)

    let issuerDisplays = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerateDeferredCredential_vaultOptionsSecureEnclave_hardwareBindingArgumentsPassed() async throws {
    _ = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.hardwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.keyBindings.first, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_vaultOptionsSafePermanently_softwareBindingArgumentsPassed() async throws {
    _ = try await generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.keyBindings.first, Self.softwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withOca_passesAuthenticationContext() async throws {
    _ = try await generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: rawOcaBundleMock,
      metadataWrapper: metadataWrapperMock,
      authentication: mockAuthentication)

    XCTAssertEqual(
      ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments?.context.authentication,
      mockAuthentication)
  }

  func testGenerate_withoutOca_passesAuthenticationContext() async throws {
    _ = try await generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapperMock,
      authentication: mockAuthentication)

    XCTAssertEqual(
      metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.authentication,
      mockAuthentication)
  }

  // MARK: Private

  private static let keyID = UUID()
  private static let keyAlgorithm = "ES256"

  private static let hardwareKeyBinding = KeyBinding(id: keyID, algorithm: keyAlgorithm, bindingType: .hardware)
  private static let softwareKeyBinding = KeyBinding(id: keyID, algorithm: keyAlgorithm, bindingType: .software, publicKey: keyPairRawRepresentationMock.0, privateKey: keyPairRawRepresentationMock.1)
  private static let keyPairRawRepresentationMock = ("publicKeyData".data(using: .utf8)!, "privateKeyData".data(using: .utf8)!)

  private let anyCredentialMock = MockAnyCredential()
  private let metadataWrapperMock = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", metadataJws: CredentialIssuerMetadataJWT.Mock.simpleSample)
  private let authenticationMock = CredentialAuthentication(accessToken: "accessToken")
  private let ocaBundleMock: OcaBundle = .Mock.simpleSample
  private let rawOcaBundleMock: RawOcaBundle = OcaBundle.Mock.simpleSampleData
  private let mockDeferredCredentialContext: DeferredCredentialContext = .Mock.sample
  private let mockDeferredCredential: DeferredCredential = .Mock.sample
  private let mockAuthentication = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")

  private let ocaCredential: VerifiableCredential = .Mock.sample
  private let metadataCredential: VerifiableCredential = .Mock.sampleDisplaysFallback

  private var keyManagerSpy = KeyManagerProtocolSpy()
  private var ocaBundlerSpy: OcaBundlerProtocolSpy!
  private var ocaCredentialGeneratorSpy: OcaCredentialGeneratorProtocolSpy!
  private var metadataCredentialGeneratorSpy: MetadataCredentialGeneratorProtocolSpy!
  private var trustInformationServiceSpy: TrustInformationServiceProtocolSpy!

  private var generator = CredentialGenerator()

  private func registerMocks() {
    keyManagerSpy = KeyManagerProtocolSpy()
    ocaBundlerSpy = OcaBundlerProtocolSpy()
    ocaCredentialGeneratorSpy = OcaCredentialGeneratorProtocolSpy()
    metadataCredentialGeneratorSpy = MetadataCredentialGeneratorProtocolSpy()
    trustInformationServiceSpy = TrustInformationServiceProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.ocaBundler.register { self.ocaBundlerSpy }
    Container.shared.ocaCredentialGenerator.register { self.ocaCredentialGeneratorSpy }
    Container.shared.metadataCredentialGenerator.register { self.metadataCredentialGeneratorSpy }
    Container.shared.trustInformationService.register { self.trustInformationServiceSpy }
  }

  private func success() {
    keyManagerSpy.getExternalRepresentationOfReturnValue = Self.keyPairRawRepresentationMock
    ocaBundlerSpy.createOcaBundleReturnValue = ocaBundleMock
    ocaCredentialGeneratorSpy.generateForOcaBundleContextReturnValue = ocaCredential
    ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReturnValue = mockDeferredCredential
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReturnValue = metadataCredential
    metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReturnValue = mockDeferredCredential
    trustInformationServiceSpy.getEntityNamesForReturnValue = nil
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

  private func assertIssuerDisplays(_ displays: [CredentialIssuerDisplay], credentialId: UUID) {
    XCTAssertEqual(displays.count, 2)
    XCTAssertEqual(displays[0].locale, "de-CH")
    XCTAssertEqual(displays[0].name, "de-CH entityName")
    XCTAssertEqual(displays[0].credentialId, credentialId)
    XCTAssertNotNil(displays[0].image)

    XCTAssertEqual(displays[1].locale, "en")
    XCTAssertEqual(displays[1].name, "EN entityName")
    XCTAssertEqual(displays[1].credentialId, credentialId)
    XCTAssertNotNil(displays[1].image)
  }
}
