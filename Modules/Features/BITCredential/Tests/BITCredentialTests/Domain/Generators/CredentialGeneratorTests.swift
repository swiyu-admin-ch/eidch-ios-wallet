import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore

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

  func testGenerate_withOca_returnsCredentialFromOcaGenerator() throws {
    let credential = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, ocaCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysRawCredentialDataCallsCount, 1)
  }

  func testGenerate_withOca_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(ocaBundlerSpy.createOcaBundleReceivedData, rawOcaBundleMock)
    if let arguments = ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysRawCredentialDataReceivedArguments {
      XCTAssertEqual(arguments.anyCredential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.keyPair, keyPairMock)
      XCTAssertNotNil(arguments.ocaBundle)
      assertIssuerDisplays(arguments.issuerDisplays, credentialId: arguments.id)
      XCTAssertEqual(arguments.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertEqual(arguments.rawCredentialData.rawOcaBundle, rawOcaBundleMock)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withoutOca_returnsCredentialFromMetadataGenerator() throws {
    let credential = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, metadataCredential)
    XCTAssertEqual(metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysRawCredentialDataCallsCount, 1)
  }

  func testGenerate_withoutOca_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysRawCredentialDataReceivedArguments {
      XCTAssertEqual(arguments.anyCredential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.keyPair, keyPairMock)
      XCTAssertEqual(arguments.selectedCredential.claims, metadataWrapperMock.selectedCredential.claims)
      assertIssuerDisplays(arguments.issuerDisplays, credentialId: arguments.id)
      XCTAssertEqual(arguments.rawCredentialData.rawOIDMetadata, metadataWrapperMock.rawData)
      XCTAssertNil(arguments.rawCredentialData.rawOcaBundle)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_ocaBundlerFailure_returnsCredentialFromMetadataGenerator() async throws {
    ocaBundlerSpy.createOcaBundleThrowableError = TestingError.error

    let credential = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, metadataCredential)
  }

  func testGenerate_ocaCredentialGeneratorFailure_throwsError() async throws {
    ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysRawCredentialDataThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: rawOcaBundleMock, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_metadataCredentialGeneratorFailure_throwsError() async throws {
    metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysRawCredentialDataThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: nil, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialMetadata.Mock.simpleSampleWithoutDisplaysData)

    let _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: rawOcaBundleMock, metadataWrapper: emptyMetadata)

    let issuerDisplays = ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysRawCredentialDataReceivedArguments?.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays, rawData: CredentialMetadata.Mock.simpleSampleWithoutDisplaysData)

    let _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, rawOcaBundle: nil, metadataWrapper: emptyMetadata)

    let issuerDisplays = metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysRawCredentialDataReceivedArguments?.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  // MARK: Private

  private let anyCredentialMock = MockAnyCredential()
  private lazy var keyPairMock = KeyPair(identifier: UUID(), algorithm: "keyAlgorithm", privateKey: SecKeyTestsHelper.createPrivateKey())
  private let metadataWrapperMock = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSample, rawData: CredentialMetadata.Mock.simpleSampleData)
  private let ocaBundleMock: OcaBundle = .Mock.simpleSample
  private let rawOcaBundleMock: RawOcaBundle = OcaBundle.Mock.simpleSampleData

  private let ocaCredential: Credential = .Mock.sample
  private let metadataCredential: Credential = .Mock.sampleDisplaysFallback

  private var ocaBundlerSpy: OcaBundlerProtocolSpy!
  private var ocaCredentialGeneratorSpy: OcaCredentialGeneratorProtocolSpy!
  private var metadataCredentialGeneratorSpy: MetadataCredentialGeneratorProtocolSpy!

  private var generator = CredentialGenerator()

  private func registerMocks() {
    ocaBundlerSpy = OcaBundlerProtocolSpy()
    ocaCredentialGeneratorSpy = OcaCredentialGeneratorProtocolSpy()
    metadataCredentialGeneratorSpy = MetadataCredentialGeneratorProtocolSpy()

    Container.shared.ocaBundler.register { self.ocaBundlerSpy }
    Container.shared.ocaCredentialGenerator.register { self.ocaCredentialGeneratorSpy }
    Container.shared.metadataCredentialGenerator.register { self.metadataCredentialGeneratorSpy }
  }

  private func success() {
    ocaBundlerSpy.createOcaBundleReturnValue = ocaBundleMock
    ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysRawCredentialDataReturnValue = ocaCredential
    metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysRawCredentialDataReturnValue = metadataCredential
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
