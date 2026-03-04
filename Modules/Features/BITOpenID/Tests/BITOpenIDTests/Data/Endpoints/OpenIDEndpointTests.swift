// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import Moya
import XCTest
@testable import BITOpenID

final class OpenIDEndpointTests: XCTestCase {

  // MARK: Internal

  func testMetadata() {
    let expectedEndpoint = ".well-known/openid-credential-issuer"

    let endpoint = URL(target: OpenIDEndpoint.metadata(fromIssuerUrl: urlMock))

    XCTAssertEqual("\(Self.baseURLMock)/\(expectedEndpoint)", endpoint.absoluteString)
  }

  func testMetadata_multipleUrlFormats() {
    let expectedEndpoint = ".well-known/openid-credential-issuer"
    let baseUrl1 = Self.baseURLMock
    let baseUrl2 = "\(Self.baseURLMock)/"
    let baseUrl3 = "\(Self.baseURLMock)/?param=1"

    guard let url1 = URL(string: baseUrl1) else {
      XCTFail("Error while trying to build URL")
      return
    }
    guard let url2 = URL(string: baseUrl2) else {
      XCTFail("Error while trying to build URL")
      return
    }
    guard let url3 = URL(string: baseUrl3) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint1 = URL(target: OpenIDEndpoint.metadata(fromIssuerUrl: url1))
    let endpoint2 = URL(target: OpenIDEndpoint.metadata(fromIssuerUrl: url2))
    let endpoint3 = URL(target: OpenIDEndpoint.metadata(fromIssuerUrl: url3))

    let expectedAbsoluteUrlString = "\(Self.baseURLMock)/\(expectedEndpoint)"
    XCTAssertEqual(expectedAbsoluteUrlString, endpoint1.absoluteString)
    XCTAssertEqual(expectedAbsoluteUrlString, endpoint2.absoluteString)
    XCTAssertEqual("\(expectedAbsoluteUrlString)?param=1", endpoint3.absoluteString, "parameters are expected at the end anyway")
  }

  func testOpenIdConfiguration() {
    let expectedEndpoint = ".well-known/oauth-authorization-server"

    let endpoint = URL(target: OpenIDEndpoint.openIdConfiguration(issuerURL: urlMock))
    XCTAssertEqual("\(Self.baseURLMock)/\(expectedEndpoint)", endpoint.absoluteString)
  }

  func testMetadataHeaders() {
    let endpoint = OpenIDEndpoint.metadata(fromIssuerUrl: urlMock)

    XCTAssertEqual(endpoint.headers?["accept"], "application/jwt, application/json")
  }

  func testOpenIdConfigurationHeaders() {
    let endpoint = OpenIDEndpoint.openIdConfiguration(issuerURL: urlMock)

    XCTAssertEqual(endpoint.headers?["accept"], "application/jwt, application/json")
  }

  func testAccessToken() {
    let code = "12345678-9ABC-ABCD-ABCD-ABCDEFGHIJKLMN"

    let endpoint = URL(target: OpenIDEndpoint.accessToken(fromTokenUrl: urlMock, preAuthorizedCode: code))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testNonce() {
    let endpoint = URL(target: OpenIDEndpoint.nonce(url: urlMock))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testCredential() {
    let token = AccessToken.Mock.sample

    let endpoint = URL(target: OpenIDEndpoint.credential(url: urlMock, body: .json(.Mock.sample), accessToken: token))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testPublicKeyInfo() {
    let endpoint = URL(target: OpenIDEndpoint.publicKeyInfo(jwksUrl: urlMock))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testStatus() {
    let endpoint = URL(target: OpenIDEndpoint.status(url: urlMock))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testCredentialHeaders_withJSONBody() {
    let token = AccessToken.Mock.sample

    let endpoint = OpenIDEndpoint.credential(url: urlMock, body: .json(.Mock.sample), accessToken: token)

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["authorization"], "\(token.tokenType.rawValue) \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["Content-Type"], "application/json")
    XCTAssertEqual(endpoint.headers?["accept"], "application/json, application/jwt")
  }

  func testCredentialHeaders_withJweBody() {
    let token = AccessToken.Mock.sample

    let endpoint = OpenIDEndpoint.credential(url: urlMock, body: .jwe("token"), accessToken: token)

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["authorization"], "\(token.tokenType.rawValue) \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["Content-Type"], "application/jwt")
    XCTAssertEqual(endpoint.headers?["accept"], "application/json, application/jwt")
  }

  func testDeferredCredentialHeaders_withJSONBody() {
    let token = AccessToken.Mock.sample
    let body = DeferredCredentialRequestBody.json(
      DeferredCredentialRequest(
        transactionId: "transactionId",
        credentialResponseEncryption: nil))

    let endpoint = OpenIDEndpoint.deferredCredential(url: urlMock, body: body, accessToken: token.accessToken)

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["authorization"], "Bearer \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["Content-Type"], "application/json")
    XCTAssertEqual(endpoint.headers?["accept"], "application/json, application/jwt")
  }

  func testDeferredCredentialHeaders_withJweBody() {
    let token = AccessToken.Mock.sample
    let body = DeferredCredentialRequestBody.jwe("token")

    let endpoint = OpenIDEndpoint.deferredCredential(url: urlMock, body: body, accessToken: token.accessToken)

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["authorization"], "Bearer \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["Content-Type"], "application/jwt")
    XCTAssertEqual(endpoint.headers?["accept"], "application/json, application/jwt")
  }

  func testAccessTokenHeaders() {
    let endpoint = OpenIDEndpoint.accessToken(fromTokenUrl: urlMock, preAuthorizedCode: "code")

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
  }

  // MARK: Private

  private static let baseURLMock = "https://example.com"

  private let urlMock = URL(string: baseURLMock)!
}
