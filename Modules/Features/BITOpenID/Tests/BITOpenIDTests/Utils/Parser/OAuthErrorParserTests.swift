import BITNetworking
import Foundation
import Moya
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

// MARK: - OAuthErrorParserTests

final class OAuthErrorParserTests: XCTestCase {

  // MARK: Internal

  func testParse_badRequest_parsesError() throws {
    for (errorCode, expectedError) in oAuthErrorCodesToError {
      let error = try makeNetworkError(statusCode: 400, data: JSONEncoder().encode(["error": errorCode]))

      let parsed = parser.parse(error)

      XCTAssertEqual(parsed as? OpenIdRepositoryError, expectedError)
    }
  }

  func testParse_invalidClientOnUnauthorized_returnsInvalidClientRepositoryError() throws {
    let error = try makeNetworkError(statusCode: 401, data: JSONEncoder().encode(["error": "invalid_client"]))

    let parsed = parser.parse(error)

    XCTAssertEqual(parsed as? OpenIdRepositoryError, .invalidClient("invalid_client"))
  }

  func testParse_useDPoPNonce_returnsUseDPoPNonceRepositoryErrorWithHeaderNonce() throws {
    let error = try makeNetworkError(
      statusCode: 400,
      data: JSONEncoder().encode(["error": "use_dpop_nonce"]),
      headers: ["DPoP-Nonce": "auth-server-nonce"])

    let parsed = parser.parse(error)

    XCTAssertEqual(parsed as? OpenIdRepositoryError, .useDPoPNonce("use_dpop_nonce", "auth-server-nonce"))
  }

  func testParse_unknownOAuthError_returnsOriginalNetworkError() throws {
    let error = try makeNetworkError(statusCode: 400, data: JSONEncoder().encode(["error": "something_unknown"]))

    let parsed = parser.parse(error)

    guard let networkError = parsed as? NetworkError else { return XCTFail("Expected NetworkError") }
    XCTAssertEqual(networkError.status, .badRequest)
  }

  func testParse_nonNetworkError_returnsOriginalError() {
    let parsed = parser.parse(TestingError.error)

    XCTAssertTrue(parsed is TestingError)
  }

  // MARK: Private

  private let parser = OAuthErrorParser()

  private let oAuthErrorCodesToError: [String: OpenIdRepositoryError] = [
    "invalid_request": .invalidRequest("invalid_request"),
    "invalid_client": .invalidClient("invalid_client"),
    "invalid_grant": .invalidGrant("invalid_grant"),
    "unauthorized_client": .unauthorizedClient("unauthorized_client"),
    "unsupported_grant_type": .unsupportedGrantType("unsupported_grant_type"),
    "invalid_scope": .invalidScope("invalid_scope"),
    "invalid_dpop_proof": .invalidDPoPProof("invalid_dpop_proof"),
  ]

  private func makeNetworkError(statusCode: Int, data: Data, headers: [String: String]? = nil) throws -> NetworkError {
    let url = try XCTUnwrap(URL(string: "https://example.com"))
    let response = try XCTUnwrap(HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: headers))
    return NetworkError(response: Response(statusCode: statusCode, data: data, response: response))
  }
}
