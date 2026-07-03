import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
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

  func testGenerate_withOca_returnsCredentialFromOcaGenerator() throws {
    let credential = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(credential, ocaCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateForOcaBundleContextCallsCount, 1)
  }

  func testGenerate_withOca_argumentsPassed() throws {
    _ = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(ocaBundlerSpy.createOcaBundleReceivedData, rawOcaBundleMock)
    if let arguments = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.count, 1)
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.credential.raw, anyCredentialMock.raw)
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

  func testGenerate_withOca_multipleCredentials_passesAllCredentialsToOcaGenerator() throws {
    let secondCredential = try MockAnyCredential(payload: XCTUnwrap("second-credential".data(using: .utf8)))

    _ = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: Self.hardwareKeyBinding),
      ],
      rawOcaBundle: rawOcaBundleMock,
      metadataWrapper: metadataWrapperMock,
      trustStatement: nil,
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

  func testGenerate_withoutOca_returnsCredentialFromMetadataGenerator() throws {
    let credential = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(credential, metadataCredential)
    XCTAssertEqual(metadataCredentialGeneratorSpy.generateForSelectedCredentialContextCallsCount, 1)
  }

  func testGenerate_withoutOca_argumentsPassed() throws {
    _ = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.count, 1)
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.credential.raw, anyCredentialMock.raw)
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

  func testGenerate_withoutOca_multipleCredentials_passesAllCredentialsToMetadataGenerator() throws {
    let secondCredential = try MockAnyCredential(payload: XCTUnwrap("second-credential".data(using: .utf8)))

    _ = try generator.generate(
      for: [
        CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding),
        CredentialWithKeyBinding(credential: secondCredential, keyBinding: Self.hardwareKeyBinding),
      ],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapperMock,
      trustStatement: nil,
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

  func testGenerate_withTrustStatement_generatesEntityNamesForIssuerDisplays() throws {
    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapperMock,
      trustStatement: trustStatementMock,
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    guard let issuerDisplays = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.issuerDisplays else {
      XCTFail("Issuer displays not passed")
      return
    }

    XCTAssertEqual(issuerDisplays.count, 2)
    XCTAssertEqual(issuerDisplays[0].locale, "de-CH")
    XCTAssertEqual(issuerDisplays[0].name, "de-CH entityName")
    XCTAssertNotNil(issuerDisplays[0].image)

    XCTAssertEqual(issuerDisplays[1].locale, "en")
    XCTAssertEqual(issuerDisplays[1].name, "EN entityName")
    XCTAssertNotNil(issuerDisplays[1].image)
  }

  func testGenerate_withTrustStatement_displayImageMatchesLocaleVariations() throws {
    let metadataWrapper = try CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", credentialIssuerMetadata: CredentialIssuerMetadata.Mock.displayLocaleVariants, rawData: CredentialIssuerMetadata.Mock.displayLocaleVariantsData)
    let trustStatement = IdentityTrustStatementJWT.Mock.localeVariants.payload

    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapper,
      trustStatement: trustStatement,
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

  func testGenerate_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    XCTAssertEqual(credential, metadataCredential)
  }

  func testGenerate_ocaCredentialGeneratorFailure_throwsError() throws {
    ocaCredentialGeneratorSpy.generateForOcaBundleContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_metadataCredentialGeneratorFailure_throwsError() throws {
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", credentialIssuerMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    let issuerDisplays = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", credentialIssuerMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: emptyMetadata, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    let issuerDisplays = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_vaultOptionsSecureEnclave_hardwareBindingArgumentsPassed() throws {
    _ = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.hardwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: CredentialAuthentication(accessToken: "accessToken"))

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.keyBinding, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_vaultOptionsSafePermanently_softwareBindingArgumentsPassed() throws {
    _ = try generator.generate(for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, trustStatement: nil, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.credentialsWithKeyBinding.first?.keyBinding, Self.softwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  // MARK: - Generate deferred credential

  func testGenerateDeferredCredential_withOca_returnsCredentialFromOcaGenerator() throws {
    let credential = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    XCTAssertEqual(credential, mockDeferredCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextCallsCount, 1)
  }

  func testGenerateDeferredCredential_withOca_argumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

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

  func testGenerateDeferredCredential_withOca_multipleKeyBindings_passesAllKeyBindingsToOcaGenerator() throws {
    let keyBindings = [Self.softwareKeyBinding, Self.hardwareKeyBinding]

    _ = try generator.generateDeferred(
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

  func testGenerateDeferredCredential_withoutOca_argumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

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

  func testGenerateDeferredCredential_withoutOca_multipleKeyBindings_passesAllKeyBindingsToMetadataGenerator() throws {
    let keyBindings = [Self.softwareKeyBinding, Self.hardwareKeyBinding]

    _ = try generator.generateDeferred(
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

  func testGenerateDeferredCredential_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    XCTAssertEqual(credential, mockDeferredCredential)
  }

  func testGenerateDeferredCredential_ocaCredentialGeneratorFailure_throwsError() throws {
    ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerateDeferredCredential_metadataCredentialGeneratorFailure_throwsError() throws {
    metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerateDeferredCredential_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", credentialIssuerMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata, authentication: authenticationMock)

    let issuerDisplays = ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerateDeferredCredential_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", credentialIssuerMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialIssuerMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: emptyMetadata, authentication: authenticationMock)

    let issuerDisplays = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerateDeferredCredential_vaultOptionsSecureEnclave_hardwareBindingArgumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.hardwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.keyBindings.first, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_vaultOptionsSafePermanently_softwareBindingArgumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialContext, keyBindings: [Self.softwareKeyBinding], rawOcaBundle: nil, metadataWrapper: metadataWrapperMock, authentication: authenticationMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.keyBindings.first, Self.softwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withOca_passesBatchDataContext() throws {
    let authentication = mockAuthentication

    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: rawOcaBundleMock,
      metadataWrapper: CredentialIssuerMetadataWrapper.Mock.sampleBatch,
      trustStatement: nil,
      authentication: authentication)

    XCTAssertEqual(
      ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments?.context.batchData,
      BatchData(batchSize: 10))
  }

  func testGenerate_withoutOca_passesBatchDataContext() throws {
    let authentication = mockAuthentication

    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: CredentialIssuerMetadataWrapper.Mock.sampleBatch,
      trustStatement: nil,
      authentication: authentication)

    XCTAssertEqual(
      metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.batchData,
      BatchData(batchSize: 10))
  }

  func testGenerate_withOca_passesAuthenticationContext() throws {
    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: rawOcaBundleMock,
      metadataWrapper: metadataWrapperMock,
      trustStatement: nil,
      authentication: mockAuthentication)

    XCTAssertEqual(
      ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments?.context.authentication,
      mockAuthentication)
  }

  func testGenerate_withoutOca_passesAuthenticationContext() throws {
    _ = try generator.generate(
      for: [CredentialWithKeyBinding(credential: anyCredentialMock, keyBinding: Self.softwareKeyBinding)],
      rawOcaBundle: nil,
      metadataWrapper: metadataWrapperMock,
      trustStatement: nil,
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
  private let metadataWrapperMock = try! CredentialIssuerMetadataWrapper(credentialConfigurationId: "credentialName", credentialIssuerMetadata: .Mock.simpleSample, rawData: CredentialIssuerMetadata.Mock.simpleSampleData)
  private let authenticationMock = CredentialAuthentication(accessToken: "accessToken")
  private let ocaBundleMock: OcaBundle = .Mock.simpleSample
  private let rawOcaBundleMock: RawOcaBundle = OcaBundle.Mock.simpleSampleData
  private let mockDeferredCredentialContext: DeferredCredentialContext = .Mock.sample
  private let mockDeferredCredential: DeferredCredential = .Mock.sample
  private let mockAuthentication = CredentialAuthentication(accessToken: "access-token", refreshToken: "refresh-token")
  private let trustStatementMock = IdentityTrustStatementJWT.Mock.validSample.resolvedPayload

  private let ocaCredential: VerifiableCredential = .Mock.sample
  private let metadataCredential: VerifiableCredential = .Mock.sampleDisplaysFallback

  private var keyManagerSpy = KeyManagerProtocolSpy()
  private var ocaBundlerSpy: OcaBundlerProtocolSpy!
  private var ocaCredentialGeneratorSpy: OcaCredentialGeneratorProtocolSpy!
  private var metadataCredentialGeneratorSpy: MetadataCredentialGeneratorProtocolSpy!

  private var generator = CredentialGenerator()

  private func registerMocks() {
    keyManagerSpy = KeyManagerProtocolSpy()
    ocaBundlerSpy = OcaBundlerProtocolSpy()
    ocaCredentialGeneratorSpy = OcaCredentialGeneratorProtocolSpy()
    metadataCredentialGeneratorSpy = MetadataCredentialGeneratorProtocolSpy()

    Container.shared.keyManager.register { self.keyManagerSpy }
    Container.shared.ocaBundler.register { self.ocaBundlerSpy }
    Container.shared.ocaCredentialGenerator.register { self.ocaCredentialGeneratorSpy }
    Container.shared.metadataCredentialGenerator.register { self.metadataCredentialGeneratorSpy }
  }

  private func success() {
    keyManagerSpy.getExternalRepresentationOfReturnValue = Self.keyPairRawRepresentationMock
    ocaBundlerSpy.createOcaBundleReturnValue = ocaBundleMock
    ocaCredentialGeneratorSpy.generateForOcaBundleContextReturnValue = ocaCredential
    ocaCredentialGeneratorSpy.generateDeferredKeyBindingsOcaBundleContextReturnValue = mockDeferredCredential
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReturnValue = metadataCredential
    metadataCredentialGeneratorSpy.generateDeferredKeyBindingsSelectedCredentialContextReturnValue = mockDeferredCredential
  }

  private func assertIssuerDisplays(_ displays: [CredentialIssuerDisplay], credentialId: UUID) {
    XCTAssertEqual(displays.count, 2)
    XCTAssertEqual(displays[0].locale, "de-CH")
    XCTAssertEqual(displays[0].name, "issuer de-CH")
    XCTAssertEqual(displays[0].credentialId, credentialId)
    XCTAssertNotNil(displays[0].image)

    XCTAssertEqual(displays[1].locale, "en-US")
    XCTAssertEqual(displays[1].name, "issuer en-US")
    XCTAssertEqual(displays[1].credentialId, credentialId)
    XCTAssertNotNil(displays[1].image)
  }
}
