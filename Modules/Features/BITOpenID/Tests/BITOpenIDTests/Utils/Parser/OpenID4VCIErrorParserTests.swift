import BITNetworking
import Foundation
import Moya
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - OpenID4VCIErrorParserTests

final class OpenID4VCIErrorParserTests: XCTestCase {

  // MARK: Internal

  func testParse_unauthorized_returnsExpiredAccessToken() throws {
    let error = try makeNetworkError(statusCode: 401, data: JSONEncoder().encode([
      "error": "INVALID_TOKEN",
      "error_description": "Access token expired",
    ]))

    let parsed = parser.parse(error)

    XCTAssertEqual(parsed as? OpenIdRepositoryError, .expiredAccessToken)
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
  ]

  private func makeNetworkError(statusCode: Int, data: Data) -> NetworkError {
    NetworkError(response: Response(statusCode: statusCode, data: data))
  }
}
