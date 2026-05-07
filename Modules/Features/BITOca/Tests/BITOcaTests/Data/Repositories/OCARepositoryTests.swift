// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITNetworking
import XCTest
@testable import BITOca

final class OCARepositoryTestsTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = OCARepository()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  func testFetchOCABundle_success() async throws {
    let expectedRawOcaBundle = RawOcaBundle()
    mockResponse(code: 200, data: expectedRawOcaBundle)

    let rawOcaBundle = try await repository.fetchOCABundle(from: mockUrl)

    XCTAssertEqual(rawOcaBundle, expectedRawOcaBundle)
  }

  func testFetchOCABundle_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchOCABundle(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  private let mockUrl = URL(string: "some://url")!
  private var repository: OCARepository!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
