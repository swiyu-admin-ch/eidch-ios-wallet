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
    let credential = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, ocaCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateForOcaBundleContextCallsCount, 1)
  }

  func testGenerate_withOca_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(ocaBundlerSpy.createOcaBundleReceivedData, rawOcaBundleMock)
    if let arguments = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.anyCredential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.context.keyBinding, Self.softwareKeyBinding)
      XCTAssertNotNil(arguments.ocaBundle)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOcaBundle, rawOcaBundleMock)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withoutOca_returnsCredentialFromMetadataGenerator() throws {
    let credential = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, metadataCredential)
    XCTAssertEqual(metadataCredentialGeneratorSpy.generateForSelectedCredentialContextCallsCount, 1)
  }

  func testGenerate_withoutOca_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.anyCredential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.context.keyBinding, Self.softwareKeyBinding)
      XCTAssertEqual(arguments.selectedCredential.claims, metadataWrapperMock.selectedCredential.claims)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertNil(arguments.context.rawCredentialData.rawOcaBundle)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, metadataCredential)
  }

  func testGenerate_ocaCredentialGeneratorFailure_throwsError() async throws {
    ocaCredentialGeneratorSpy.generateForOcaBundleContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_metadataCredentialGeneratorFailure_throwsError() async throws {
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata)

    let issuerDisplays = ocaCredentialGeneratorSpy.generateForOcaBundleContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: emptyMetadata)

    let issuerDisplays = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_vaultOptionsSecureEnclave_hardwareBindingArgumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyBinding: Self.hardwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.context.keyBinding, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_vaultOptionsSafePermanently_softwareBindingArgumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.context.keyBinding, Self.softwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  // MARK: - Generate deferred credential

  func testGenerateDeferredCredential_withOca_returnsCredentialFromOcaGenerator() throws {
    let credential = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, mockDeferredCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateDeferredOcaBundleContextCallsCount, 1)
  }

  func testGenerateDeferredCredential_withOca_argumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(ocaBundlerSpy.createOcaBundleReceivedData, rawOcaBundleMock)
    if let arguments = ocaCredentialGeneratorSpy.generateDeferredOcaBundleContextReceivedArguments {
      XCTAssertEqual(arguments.deferredCredentialRequest, mockDeferredCredentialRequest)
      XCTAssertEqual(arguments.context.keyBinding, Self.softwareKeyBinding)
      XCTAssertNotNil(arguments.ocaBundle)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOcaBundle, rawOcaBundleMock)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_withoutOca_argumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.deferredCredentialRequest, mockDeferredCredentialRequest)
      XCTAssertEqual(arguments.context.keyBinding, Self.softwareKeyBinding)
      XCTAssertEqual(arguments.selectedCredential.claims, metadataWrapperMock.selectedCredential.claims)
      assertIssuerDisplays(arguments.context.issuerDisplays, credentialId: arguments.context.credentialId)
      XCTAssertEqual(arguments.context.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertNil(arguments.context.rawCredentialData.rawOcaBundle)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, mockDeferredCredential)
  }

  func testGenerateDeferredCredential_ocaCredentialGeneratorFailure_throwsError() async throws {
    ocaCredentialGeneratorSpy.generateDeferredOcaBundleContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerateDeferredCredential_metadataCredentialGeneratorFailure_throwsError() async throws {
    metadataCredentialGeneratorSpy.generateDeferredSelectedCredentialContextThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerateDeferredCredential_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata)

    let issuerDisplays = ocaCredentialGeneratorSpy.generateDeferredOcaBundleContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerateDeferredCredential_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialMetadata.Mock.simpleSampleWithoutDisplaysData)

    _ = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: emptyMetadata)

    let issuerDisplays = metadataCredentialGeneratorSpy.generateDeferredSelectedCredentialContextReceivedArguments?.context.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerateDeferredCredential_vaultOptionsSecureEnclave_hardwareBindingArgumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.hardwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.context.keyBinding, Self.hardwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerateDeferredCredential_vaultOptionsSafePermanently_softwareBindingArgumentsPassed() throws {
    _ = try generator.generateDeferred(mockDeferredCredentialRequest, keyBinding: Self.softwareKeyBinding, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateDeferredSelectedCredentialContextReceivedArguments {
      XCTAssertEqual(arguments.context.keyBinding, Self.softwareKeyBinding)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  // MARK: Private

  private static let keyID = UUID()
  private static let keyAlgorithm = "ES256"

  private static let hardwareKeyBinding = CredentialKeyBinding(id: keyID, algorithm: keyAlgorithm, bindingType: .hardware)
  private static let softwareKeyBinding = CredentialKeyBinding(id: keyID, algorithm: keyAlgorithm, bindingType: .software, publicKey: keyPairRawRepresentationMock.0, privateKey: keyPairRawRepresentationMock.1)
  private static let keyPairRawRepresentationMock = ("publicKeyData".data(using: .utf8)!, "privateKeyData".data(using: .utf8)!)

  private let anyCredentialMock = MockAnyCredential()
  private let metadataWrapperMock = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSample, rawData: CredentialMetadata.Mock.simpleSampleData)
  private let ocaBundleMock: OcaBundle = .Mock.simpleSample
  private let rawOcaBundleMock: RawOcaBundle = OcaBundle.Mock.simpleSampleData
  private let mockDeferredCredentialRequest: DeferredCredentialRequest = .Mock.sample
  private let mockDeferredCredential: DeferredCredential = .Mock.sample

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
    ocaCredentialGeneratorSpy.generateDeferredOcaBundleContextReturnValue = mockDeferredCredential
    metadataCredentialGeneratorSpy.generateForSelectedCredentialContextReturnValue = metadataCredential
    metadataCredentialGeneratorSpy.generateDeferredSelectedCredentialContextReturnValue = mockDeferredCredential
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

// swiftlint:enable all
