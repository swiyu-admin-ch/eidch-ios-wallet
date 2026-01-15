// swiftlint: disable force_unwrapping
import BITCore
import BITNetworking
import Factory
import XCTest
@testable import BITOpenID
@testable import BITSdJWT

// MARK: - OpenIDRepository

final class TrustStatementRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    repository = TrustStatementRepository()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  // MARK: - fetchIdentityTrustStatements

  func testFetchIdentityTrustStatements_multipleStatements_returnsAll() async throws {
    let expectedStatements = [IdentityTrustStatementJWT.Mock.allFieldsRawSdJwt, IdentityTrustStatementJWT.Mock.allFieldsRawSdJwt]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    let trustStatements = try await repository.fetchIdentityTrustStatements(from: mockUrl, for: "did")

    XCTAssertEqual(trustStatements.count, 2)
    XCTAssertEqual(trustStatements[0].payload, IdentityTrustStatementJWT.Mock.allFields.payload)
    XCTAssertEqual(trustStatements[1].payload, IdentityTrustStatementJWT.Mock.allFields.payload)
  }

  func testFetchIdentityTrustStatements_decodingError_throwsError() async throws {
    let expectedStatements = ["invalidTrustStatement"]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    do {
      _ = try await repository.fetchIdentityTrustStatements(from: mockUrl, for: "did")
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testFetchIdentityTrustStatements_serverError_throwsServerError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchIdentityTrustStatements(from: mockUrl, for: "did")
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  private let mockUrl = URL(string: "some://url")!
  private var repository = TrustStatementRepository()

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
