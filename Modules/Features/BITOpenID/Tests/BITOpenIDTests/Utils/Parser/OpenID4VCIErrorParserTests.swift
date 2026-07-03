import BITNetworking
import Foundation
import Moya
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - OpenID4VCIErrorParserTests

final class OpenID4VCIErrorParserTests: XCTestCase {

  // MARK: Internal

  func testParse_unauthorized_returnsInvalidToken() throws {
    let error = try makeNetworkError(statusCode: 401, data: JSONEncoder().encode([
      "error": "INVALID_TOKEN",
      "error_description": "Access token expired",
    ]))

    let parsed = parser.parse(error)

    XCTAssertEqual(parsed as? OpenIdRepositoryError, .expiredAccessToken)
  }

  func testParse_unauthorizedUseDPoPNonce_returnsUseDPoPNonceWithHeaderNonce() throws {
    let error = try makeNetworkError(
      statusCode: 401,
      data: JSONEncoder().encode([
        "error": "INVALID_TOKEN",
        "error_description": "Use fresh DPoP nonce",
      ]),
      headers: [
        "WWW-Authenticate": "DPoP error=\"use_dpop_nonce\"",
        "DPoP-Nonce": "resource-server-nonce",
      ])

    let parsed = parser.parse(error)

    XCTAssertEqual(parsed as? OpenIdRepositoryError, .useDPoPNonce("use_dpop_nonce", "resource-server-nonce"))
  }

  func testParse_requestDenied_returnsInvalidCredential() throws {
    for (errorCode, expectedError) in oID4VCIErrorCodesToError {
      let error = try makeNetworkError(statusCode: 400, data: JSONEncoder().encode(["error": errorCode]))

      let parsed = parser.parse(error)

      XCTAssertEqual(parsed as? OpenIdRepositoryError, expectedError)
    }
  }

  func testParse_nonNetworkError_returnsOriginalError() {
    let parsed = parser.parse(TestingError.error)

    XCTAssertTrue(parsed is TestingError)
  }

  // MARK: Private

  private let parser = OpenID4VCIErrorParser()

  private let oID4VCIErrorCodesToError: [String: OpenIdRepositoryError] = [
    "credential_request_denied": .invalidCredential,
    "invalid_credential_request": .invalidCredentialRequest("invalid_credential_request"),
    "invalid_encryption_parameters": .invalidEncryptionParameters("invalid_encryption_parameters"),
    "invalid_nonce": .invalidNonce("invalid_nonce"),
    "invalid_proof": .invalidProof("invalid_proof"),
    "unknown_credential_configuration": .unknownCredentialConfiguration("unknown_credential_configuration"),
    "unknown_credential_identifier": .unknownCredentialIdentifier("unknown_credential_identifier"),
    "invalid_transaction_id": .invalidTransactionId("invalid_transaction_id"),
    "insufficient_scope": .insufficientScope("insufficient_scope"),
  ]

  private func makeNetworkError(statusCode: Int, data: Data, headers: [String: String]? = nil) throws -> NetworkError {
    let url = try XCTUnwrap(URL(string: "https://example.com"))
    let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers))
    return NetworkError(response: Response(statusCode: statusCode, data: data, response: response))
  }
}
