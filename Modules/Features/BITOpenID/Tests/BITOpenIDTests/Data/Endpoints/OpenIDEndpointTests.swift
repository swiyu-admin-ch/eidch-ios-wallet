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

    XCTAssertEqual(endpoint.headers?["accept"], "application/jwt")
    XCTAssertEqual(endpoint.headers?["Accept-Language"], "de-CH, fr-CH, it-CH, en, rm")
  }

  func testOpenIdConfigurationHeaders() {
    let endpoint = OpenIDEndpoint.openIdConfiguration(fromIssuerUrl: urlMock)

    XCTAssertEqual(endpoint.headers?["accept"], "application/jwt")
  }

  func testAccessToken() {
    let code = "12345678-9ABC-ABCD-ABCD-ABCDEFGHIJKLMN"

    let endpoint = URL(target: OpenIDEndpoint.accessToken(fromTokenUrl: urlMock, preAuthorizedCode: code, dpopProof: nil))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testRefreshAccessToken() {
    let endpoint = URL(target: OpenIDEndpoint.refreshAccessToken(fromTokenUrl: urlMock, refreshToken: "refreshToken", dpopProof: nil))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testNonce() {
    let endpoint = URL(target: OpenIDEndpoint.nonce(url: urlMock))

    XCTAssertEqual(urlMock, endpoint)
  }

  func testCredential() {
    let token = AccessToken.Mock.sample

    let endpoint = URL(target: OpenIDEndpoint.credential(url: urlMock, jwe: "token", accessToken: token, dpopProof: nil))

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

  func testCredentialHeaders() {
    let token = AccessToken.Mock.sample

    let endpoint = OpenIDEndpoint.credential(url: urlMock, jwe: "token", accessToken: token, dpopProof: nil)

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["authorization"], "bearer \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["Content-Type"], "application/jwt")
    XCTAssertEqual(endpoint.headers?["accept"], "application/json, application/jwt")
  }

  func testCredentialHeaders_withDPoPTokenAndProof() {
    let token = AccessToken(accessToken: "accessToken", tokenType: .dpop)

    let endpoint = OpenIDEndpoint.credential(url: urlMock, jwe: "token", accessToken: token, dpopProof: "proof")

    XCTAssertEqual(endpoint.headers?["authorization"], "dpop \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["DPoP"], "proof")
  }

  func testDeferredCredentialHeaders() {
    let token = AccessToken.Mock.sample

    let endpoint = OpenIDEndpoint.deferredCredential(
      url: urlMock,
      jwe: "token",
      accessToken: token,
      dpopProof: nil)

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["authorization"], "bearer \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["Content-Type"], "application/jwt")
    XCTAssertEqual(endpoint.headers?["accept"], "application/json, application/jwt")
  }

  func testDeferredCredentialHeaders_withDPoPTokenAndProof() {
    let token = AccessToken(accessToken: "accessToken", tokenType: .dpop)

    let endpoint = OpenIDEndpoint.deferredCredential(
      url: urlMock,
      jwe: "token",
      accessToken: token,
      dpopProof: "proof")

    XCTAssertEqual(endpoint.headers?["authorization"], "dpop \(token.accessToken)")
    XCTAssertEqual(endpoint.headers?["DPoP"], "proof")
  }

  func testAccessTokenHeaders() {
    let endpoint = OpenIDEndpoint.accessToken(fromTokenUrl: urlMock, preAuthorizedCode: "code", dpopProof: "proof")

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["DPoP"], "proof")
  }

  func testRefreshAccessTokenHeaders() {
    let endpoint = OpenIDEndpoint.refreshAccessToken(fromTokenUrl: urlMock, refreshToken: "refreshToken", dpopProof: "proof")

    XCTAssertEqual(endpoint.headers?["SWIYU-API-Version"], "2")
    XCTAssertEqual(endpoint.headers?["DPoP"], "proof")
  }

  // MARK: Private

  private static let baseURLMock = "https://example.com"

  private let urlMock = URL(string: baseURLMock)!
}
