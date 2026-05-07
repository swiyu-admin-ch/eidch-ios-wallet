// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITCrypto
import Factory
import XCTest
@testable import BITOpenID

final class CredentialEncryptionValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    validator = CredentialEncryptionValidator()
  }

  func testValidate_requestAndResponseValid_doesNotThrow() throws {
    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: responseEncryptionMock)

    XCTAssertNoThrow(try validator.validate(metadata))
  }

  func testValidate_requestEncryptionValid_doesNotThrow() throws {
    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: nil)

    XCTAssertNoThrow(try validator.validate(metadata))
  }

  func testValidate_noRequestOrResponseEncryption_doesNotThrow() throws {
    let metadata = makeMetadata(requestEncryption: nil, responseEncryption: nil)

    XCTAssertNoThrow(try validator.validate(metadata))
  }

  func testValidate_responseEncryptionWithoutRequestEncryption_throwsMissingRequestEncryption() throws {
    let metadata = makeMetadata(requestEncryption: nil, responseEncryption: responseEncryptionMock)

    XCTAssertThrowsError(try validator.validate(metadata)) { error in
      XCTAssertEqual(error as? CredentialEncryptionError, .missingRequestEncryption)
    }
  }

  func testValidate_requestEncryptionMissingIssuerKeys_throwsMissingIssuerEncryptionKeys() throws {
    let requestEncryption = CredentialIssuerMetadata.CredentialRequestEncryption(
      jwks: CredentialIssuerMetadata.CredentialRequestEncryption.JWKs(keys: []),
      supportedEncryptionAlgorithms: [.A128GCM],
      supportedZipValues: [.deflate],
      encryptionRequired: false)
    let metadata = makeMetadata(requestEncryption: requestEncryption, responseEncryption: nil)

    XCTAssertThrowsError(try validator.validate(metadata)) { error in
      XCTAssertEqual(error as? CredentialEncryptionError, .missingIssuerEncryptionKeys)
    }
  }

  func testValidate_requestEncryptionUnsupportedCurve_throwsUnsupportedJwkCurve() throws {
    Container.shared.encryptionSupportedCurves.register { ["P-384"] }
    validator = CredentialEncryptionValidator()

    let metadata = makeMetadata(requestEncryption: requestEncryptionMock, responseEncryption: nil)

    XCTAssertThrowsError(try validator.validate(metadata)) { error in
      XCTAssertEqual(error as? CredentialEncryptionError, .unsupportedJwkCurve)
    }
  }

  func testValidate_onlyUnsupportedAlgorithmJWK_throwsUnsupportedKeyManagementAlgorithm() throws {
    let invalidJwk = JWK.Mock.build(alg: "unsupported")
    let requestEncryption = makeCredentialRequestEncryption(keys: [invalidJwk])
    let metadata = makeMetadata(requestEncryption: requestEncryption, responseEncryption: nil)

    XCTAssertThrowsError(try validator.validate(metadata)) { error in
      XCTAssertEqual(error as? CredentialEncryptionError, .unsupportedKeyManagementAlgorithm)
    }
  }

  func testValidate_oneValidAndOneUnsupportedAlgorithmJWK_validades() throws {
    let invalidJwk = JWK.Mock.build(alg: "unsupported")
    let validJwk = JWK.Mock.build()
    let requestEncryption = makeCredentialRequestEncryption(keys: [invalidJwk, validJwk])
    let metadata = makeMetadata(requestEncryption: requestEncryption, responseEncryption: nil)

    XCTAssertNoThrow(try validator.validate(metadata))
  }

  func testValidate_onlyUnsupportedCurve_throwsUnsupportedJwkCurve() throws {
    let invalidJwk = JWK.Mock.build(crv: "unsupported")
    let requestEncryption = makeCredentialRequestEncryption(keys: [invalidJwk])
    let metadata = makeMetadata(requestEncryption: requestEncryption, responseEncryption: nil)

    XCTAssertThrowsError(try validator.validate(metadata)) { error in
      XCTAssertEqual(error as? CredentialEncryptionError, .unsupportedJwkCurve)
    }
  }

  func testValidate_oneValidAndOneUnsupportedCurve_validades() throws {
    let invalidJwk = JWK.Mock.build(crv: "unsupported")
    let validJwk = JWK.Mock.build()
    let requestEncryption = makeCredentialRequestEncryption(keys: [invalidJwk, validJwk])
    let metadata = makeMetadata(requestEncryption: requestEncryption, responseEncryption: nil)

    XCTAssertNoThrow(try validator.validate(metadata))
  }

  // MARK: Private

  private let metadataMock = CredentialIssuerMetadata.Mock.chasseralIssuer01
  private let requestEncryptionMock = CredentialIssuerMetadata.Mock.chasseralIssuer01.credentialRequestEncryption!
  private let responseEncryptionMock = CredentialIssuerMetadata.Mock.chasseralIssuer01.credentialResponseEncryption!

  private var validator = CredentialEncryptionValidator()

  private func registerMocks() {
    Container.shared.encryptionSupportedCurves.register { ["P-256"] }
  }

  private func makeCredentialRequestEncryption(keys: [JWK]) -> CredentialIssuerMetadata.CredentialRequestEncryption {
    CredentialIssuerMetadata.CredentialRequestEncryption(
      jwks: CredentialIssuerMetadata.CredentialRequestEncryption.JWKs(keys: keys),
      supportedEncryptionAlgorithms: [.A128GCM],
      supportedZipValues: nil,
      encryptionRequired: false)
  }

  private func makeMetadata(
    requestEncryption: CredentialIssuerMetadata.CredentialRequestEncryption?,
    responseEncryption: CredentialIssuerMetadata.CredentialResponseEncryption?)
    -> CredentialIssuerMetadata
  {
    CredentialIssuerMetadata(
      credentialIssuer: metadataMock.credentialIssuer,
      credentialEndpoint: metadataMock.credentialEndpoint,
      credentialConfigurationsSupported: metadataMock.credentialConfigurationsSupported,
      display: metadataMock.display,
      credentialRequestEncryption: requestEncryption,
      credentialResponseEncryption: responseEncryption,
      nonceEndpoint: metadataMock.nonceEndpoint,
      deferredCredentialEndpoint: metadataMock.deferredCredentialEndpoint)
  }
}
