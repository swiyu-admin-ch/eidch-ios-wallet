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
    let credential = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: ocaBundleMock, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, ocaCredential)
    XCTAssertEqual(ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysCallsCount, 1)
  }

  func testGenerate_withOca_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: ocaBundleMock, metadataWrapper: metadataWrapperMock)

    if let arguments = ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysReceivedArguments {
      XCTAssertEqual(arguments.anyCredential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.keyPair, keyPairMock)
      XCTAssertNotNil(arguments.ocaBundle)
      assertIssuerDisplays(arguments.issuerDisplays, credentialId: arguments.id)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_withoutOca_returnsCredentialFromMetadataGenerator() throws {
    let credential = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: nil, metadataWrapper: metadataWrapperMock)

    XCTAssertEqual(credential, metadataCredential)
    XCTAssertEqual(metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysCallsCount, 1)
  }

  func testGenerate_withoutOca_argumentsPassed() throws {
    _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: nil, metadataWrapper: metadataWrapperMock)

    if let arguments = metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysReceivedArguments {
      XCTAssertEqual(arguments.anyCredential.raw, anyCredentialMock.raw)
      XCTAssertEqual(arguments.keyPair, keyPairMock)
      XCTAssertEqual(arguments.selectedCredential.claims, metadataWrapperMock.selectedCredential.claims)
      assertIssuerDisplays(arguments.issuerDisplays, credentialId: arguments.id)
    } else {
      XCTFail("Arguments not passed")
    }
  }

  func testGenerate_ocaCredentialGeneratorFailure_throwsError() async throws {
    ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: ocaBundleMock, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_metadataCredentialGeneratorFailure_throwsError() async throws {
    metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: nil, metadataWrapper: metadataWrapperMock)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_withOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays)

    let _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: ocaBundleMock, metadataWrapper: emptyMetadata)

    let issuerDisplays = ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysReceivedArguments?.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  func testGenerate_withoutOcaAndNoIssuerMetadata_returnsEmptyIssuerDisplays() throws {
    let emptyMetadata = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSampleWithoutDisplays)

    let _ = try generator.generate(for: anyCredentialMock, keyPair: keyPairMock, ocaBundle: nil, metadataWrapper: emptyMetadata)

    let issuerDisplays = metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysReceivedArguments?.issuerDisplays

    XCTAssertEqual(issuerDisplays, [])
  }

  // MARK: Private

  private let anyCredentialMock = MockAnyCredential()
  private lazy var keyPairMock = KeyPair(identifier: UUID(), algorithm: "keyAlgorithm", privateKey: SecKeyTestsHelper.createPrivateKey())
  private let metadataWrapperMock = try! CredentialMetadataWrapper(selectedCredentialSupportedId: "credentialName", credentialMetadata: .Mock.simpleSample)
  private let ocaBundleMock: OcaBundle = .Mock.simpleSample

  private let ocaCredential: Credential = .Mock.sample
  private let metadataCredential: Credential = .Mock.sampleDisplaysFallback

  private var ocaCredentialGeneratorSpy: OcaCredentialGeneratorProtocolSpy!
  private var metadataCredentialGeneratorSpy: MetadataCredentialGeneratorProtocolSpy!

  private var generator = CredentialGenerator()

  private func registerMocks() {
    ocaCredentialGeneratorSpy = OcaCredentialGeneratorProtocolSpy()
    metadataCredentialGeneratorSpy = MetadataCredentialGeneratorProtocolSpy()

    Container.shared.ocaCredentialGenerator.register { self.ocaCredentialGeneratorSpy }
    Container.shared.metadataCredentialGenerator.register { self.metadataCredentialGeneratorSpy }
  }

  private func success() {
    ocaCredentialGeneratorSpy.generateForIdKeyPairOcaBundleIssuerDisplaysReturnValue = ocaCredential
    metadataCredentialGeneratorSpy.generateForIdKeyPairSelectedCredentialIssuerDisplaysReturnValue = metadataCredential
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
