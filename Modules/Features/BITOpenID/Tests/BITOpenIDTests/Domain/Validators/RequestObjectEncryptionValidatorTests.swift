// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import BITCrypto
import Factory
import Foundation
import XCTest
@testable import BITOpenID

final class RequestObjectEncryptionValidatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    validator = RequestObjectEncryptionValidator()
  }

  func testValidate_directPostJwt_success() throws {
    let jwk = JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue)
    let metadata = makeClientMetadata(
      jwks: ClientMetadata.JWKs(keys: [jwk]),
      encValuesSupported: [EncryptionAlgorithm.A128GCM.rawValue])
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertNoThrow(try validator.validate(requestObject))
  }

  func testValidate_directPost_success() throws {
    let requestObject = makeRequestObject(responseMode: .directPost, clientMetadata: nil)

    XCTAssertNoThrow(try validator.validate(requestObject))
  }

  func testValidate_missingClientMetadata_throwsMissingClientMetadata() throws {
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: nil)

    XCTAssertThrowsError(try validator.validate(requestObject)) { error in
      XCTAssertEqual(error as? RequestObjectEncryptionError, .missingClientMetadata)
    }
  }

  func testValidate_missingEncryptionKeys_throwsMissingEncryptionKeys() throws {
    let metadata = makeClientMetadata(jwks: ClientMetadata.JWKs(keys: []))
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertThrowsError(try validator.validate(requestObject)) { error in
      XCTAssertEqual(error as? RequestObjectEncryptionError, .missingEncryptionKeys)
    }
  }

  func testValidate_unsupportedEncryptionValue_throwsUnsupportedEncryptionValue() throws {
    let jwk = JWK.Mock.build(alg: KeyManagementAlgorithm.ECDH_ES.rawValue)
    let metadata = makeClientMetadata(
      jwks: ClientMetadata.JWKs(keys: [jwk]),
      encValuesSupported: ["unsupported"])
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertThrowsError(try validator.validate(requestObject)) { error in
      XCTAssertEqual(error as? RequestObjectEncryptionError, .unsupportedEncryptionValue)
    }
  }

  func testValidate_onlyUnsupportedAlgorithmJWK_throwsUnsupportedKeyManagementAlgorithm() throws {
    let invalidJwk = JWK.Mock.build(alg: "unsupported")
    let metadata = makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [invalidJwk]))
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertThrowsError(try validator.validate(requestObject)) { error in
      XCTAssertEqual(error as? RequestObjectEncryptionError, .unsupportedKeyManagementAlgorithm)
    }
  }

  func testValidate_oneValidAndOneUnsupportedAlgorithmJWK_validates() throws {
    let invalidJwk = JWK.Mock.build(alg: "unsupported")
    let validJwk = JWK.Mock.build()
    let metadata = makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [invalidJwk, validJwk]))
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertNoThrow(try validator.validate(requestObject))
  }

  func testValidate_onlyUnsupportedAlgorithmJwkCurve_throwsUnsupportedJwkCurve() throws {
    let invalidJwk = JWK.Mock.build(crv: "unsupported")
    let metadata = makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [invalidJwk]))
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertThrowsError(try validator.validate(requestObject)) { error in
      XCTAssertEqual(error as? RequestObjectEncryptionError, .unsupportedJwkCurve)
    }
  }

  func testValidate_oneValidAndOneUnsupportedCurve_validates() throws {
    let invalidJwk = JWK.Mock.build(crv: "unsupported")
    let validJwk = JWK.Mock.build()
    let metadata = makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [invalidJwk, validJwk]))
    let requestObject = makeRequestObject(responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertNoThrow(try validator.validate(requestObject))
  }

  // MARK: Private

  private let mockResponseUri = URL(string: "https://example.com")!
  private let presentationDefinition = RequestObject.Mock.VcSdJwt.sample.presentationDefinition!

  private var validator = RequestObjectEncryptionValidator()

  private func registerMocks() {
    Container.shared.encryptionSupportedCurves.register { ["P-256"] }
  }

  private func makeClientMetadata(
    jwks: ClientMetadata.JWKs?,
    encValuesSupported: [String]? = nil)
    -> ClientMetadata
  {
    try! ClientMetadata(
      clientName: nil,
      logoUri: nil,
      jwks: jwks,
      encryptedResponseEncValuesSupported: encValuesSupported)
  }

  private func makeRequestObject(
    responseMode: RequestObject.ResponseMode,
    clientMetadata: ClientMetadata?)
    -> RequestObject
  {
    RequestObject(
      queryType: .presentationDefinition(presentationDefinition),
      nonce: "nonce",
      responseUri: mockResponseUri,
      clientMetadata: clientMetadata,
      responseType: "vp_token",
      clientId: "did:example:12345",
      clientIdScheme: "did",
      responseMode: responseMode,
      transactionData: nil)
  }
}
