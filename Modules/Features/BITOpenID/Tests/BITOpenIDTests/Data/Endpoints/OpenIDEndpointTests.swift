import BITCore
import Moya
import XCTest
@testable import BITOpenID

final class OpenIDEndpointTests: XCTestCase {

  func testMetadata() throws {
    let baseUrl = "https://example.com"
    let expectedEndpoint = ".well-known/openid-credential-issuer"

    guard let url = URL(string: baseUrl) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint = URL(target: OpenIDEndpoint.metadata(fromIssuerUrl: url))
    XCTAssertEqual("\(baseUrl)/\(expectedEndpoint)", endpoint.absoluteString)
  }

  func testMetadata_multipleUrlFormats() throws {
    let expectedBaseUrl = "https://example.com"
    let expectedEndpoint = ".well-known/openid-credential-issuer"
    let baseUrl1 = expectedBaseUrl
    let baseUrl2 = "\(expectedBaseUrl)/"
    let baseUrl3 = "\(expectedBaseUrl)/?param=1"

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

    let expectedAbsoluteUrlString = "\(expectedBaseUrl)/\(expectedEndpoint)"
    XCTAssertEqual(expectedAbsoluteUrlString, endpoint1.absoluteString)
    XCTAssertEqual(expectedAbsoluteUrlString, endpoint2.absoluteString)
    XCTAssertEqual("\(expectedAbsoluteUrlString)?param=1", endpoint3.absoluteString, "parameters are expected at the end anyway")
  }

  func testOpenIdConfiguration() throws {
    let baseUrl = "https://example.com"
    let expectedEndpoint = ".well-known/oauth-authorization-server"

    guard let url = URL(string: baseUrl) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint = URL(target: OpenIDEndpoint.openIdConfiguration(issuerURL: url))
    XCTAssertEqual("\(baseUrl)/\(expectedEndpoint)", endpoint.absoluteString)
  }

  func testAccessToken() throws {
    let baseUrl = "https://example.com"
    let code = "12345678-9ABC-ABCD-ABCD-ABCDEFGHIJKLMN"

    guard let url = URL(string: baseUrl) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint = URL(target: OpenIDEndpoint.accessToken(fromTokenUrl: url, preAuthorizedCode: code))
    XCTAssertEqual("\(baseUrl)", endpoint.absoluteString)
  }

  func testCredential() throws {
    let baseUrl = "https://example.com"
    let token = "12345678-9ABC-ABCD-ABCD-ABCDEFGHIJKLMN"

    guard let url = URL(string: baseUrl) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint = URL(target: OpenIDEndpoint.credential(url: url, body: .Mock.sample, acccessToken: token))
    XCTAssertEqual("\(baseUrl)", endpoint.absoluteString)
  }

  func testPublicKeyInfo() throws {
    let baseUrl = "https://example.com"

    guard let url = URL(string: baseUrl) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint = URL(target: OpenIDEndpoint.publicKeyInfo(jwksUrl: url))
    XCTAssertEqual("\(baseUrl)", endpoint.absoluteString)
  }

  func testStatus() throws {
    let baseUrl = "https://example.com"

    guard let url = URL(string: baseUrl) else {
      XCTFail("Error while trying to build URL")
      return
    }

    let endpoint = URL(target: OpenIDEndpoint.status(url: url))
    XCTAssertEqual("\(baseUrl)", endpoint.absoluteString)
  }

}
