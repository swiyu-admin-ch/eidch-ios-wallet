// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Moya
import XCTest
@testable import BITOca

final class OCAEndpointTests: XCTestCase {

  // MARK: Internal

  func testBundle() {
    let endpoint = URL(target: OCAEndpoint.bundle(url: urlMock))

    XCTAssertEqual(Self.baseURLMock, endpoint.absoluteString)
  }

  func testBundleHeaders() {
    let endpoint = OCAEndpoint.bundle(url: urlMock)

    XCTAssertEqual(endpoint.headers?["accept"], "application/json")
    XCTAssertEqual(endpoint.headers?["Accept-Language"], "de-CH, fr-CH, it-CH, en, rm")
  }

  // MARK: Private

  private static let baseURLMock = "https://example.com"

  private let urlMock = URL(string: baseURLMock)!
}
