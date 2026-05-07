// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import Moya
import XCTest
@testable import BITOpenID

final class OpenIDEndpointTests: XCTestCase {

  // MARK: Internal

  func testOidConnectMetadata() {
    let expectedEndpoint = ".well-known/openid-credential-issuer"

    let endpoint = URL(target: OpenIDEndpoint.oidConnectMetadata(fromIssuerUrl: urlMock))

    XCTAssertEqual("\(Self.baseURLMock)/\(expectedEndpoint)", endpoint.absoluteString)
  }

  func testMetadata() throws {
    let wellKnownPath = ".well-known/openid-credential-issuer"
    let urls = [
      (Self.baseURLMock, "\(Self.baseURLMock)/\(wellKnownPath)"),
      ("\(Self.baseURLMock)/", "\(Self.baseURLMock)/\(wellKnownPath)/"),
      ("\(Self.baseURLMock)/path", "\(Self.baseURLMock)/\(wellKnownPath)/path"),
      ("\(Self.baseURLMock):1000/path", "\(Self.baseURLMock):1000/\(wellKnownPath)/path"),
    ]

    for (stringUrl, expectedEndpoint) in urls {
      let url = try XCTUnwrap(URL(string: stringUrl))

      let endpoint = URL(target: OpenIDEndpoint.metadata(fromIssuerUrl: url))

      XCTAssertEqual(expectedEndpoint, endpoint.absoluteString, "URL: \(stringUrl)")
    }
  }

  func testOidConnectOpenIdConfiguration() {
    let expectedEndpoint = ".well-known/oauth-authorization-server"

    let endpoint = URL(target: OpenIDEndpoint.oidConnectOpenIdConfiguration(fromIssuerUrl: urlMock))
    XCTAssertEqual("\(Self.baseURLMock)/\(expectedEndpoint)", endpoint.absoluteString)
  }

  func testOpenIdConfiguration() throws {
    let wellKnownPath = ".well-known/oauth-authorization-server"
    let urls = [
      (Self.baseURLMock, "\(Self.baseURLMock)/\(wellKnownPath)"),
      ("\(Self.baseURLMock)/", "\(Self.baseURLMock)/\(wellKnownPath)/"),
      ("\(Self.baseURLMock)/path", "\(Self.baseURLMock)/\(wellKnownPath)/path"),
      ("\(Self.baseURLMock):1000/path", "\(Self.baseURLMock):1000/\(wellKnownPath)/path"),
    ]

    for (stringUrl, expectedEndpoint) in urls {
      let url = try XCTUnwrap(URL(string: stringUrl))

      let endpoint = URL(target: OpenIDEndpoint.openIdConfiguration(fromIssuerUrl: url))

      XCTAssertEqual(expectedEndpoint, endpoint.absoluteString, "URL: \(stringUrl)")
    }
  }

  func testMetadataHeaders() {
    let endpoint = OpenIDEndpoint.metadata(fromIssuerUrl: urlMock)

    XCTAssertEqual(endpoint.headers?["accept"], "application/jwt, application/json")
    XCTAssertEqual(endpoint.headers?["Accept-Language"], "de-CH, fr-CH, it-CH, en, rm")
  }

  func testOpenIdConfigurationHeaders() {
    let endpoint = OpenIDEndpoint.openIdConfiguration(fromIssuerUrl: urlMock)

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
