// swiftlint: disable force_unwrapping implicitly_unwrapped_optional
import BITCore
import BITNetworking
import Factory
import XCTest
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - OpenIDRepository

final class TrustStatementRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    repository = TrustStatementRepository()
  }

  // MARK: - fetchIdentityTrustStatements

  func testFetchIdentityTrustStatements_multipleStatements_returnsAll() async throws {
    let expectedStatements = [rawTrustStatement1Mock, rawTrustStatement2Mock]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    let trustStatements = try await repository.fetchIdentityTrustStatements(from: urlMock, for: "did")

    XCTAssertEqual(trustStatements.count, 2)
    XCTAssertEqual(trustStatements[0], trustStatement1Mock)
    XCTAssertEqual(trustStatements[1], trustStatement2Mock)
  }

  func testFetchIdentityTrustStatements_decodingError_throwsError() async throws {
    let expectedStatements = [rawTrustStatement1Mock]
    vcSdJwsDecoderMock.decodeFromThrowableError = TestingError.error
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    do {
      _ = try await repository.fetchIdentityTrustStatements(from: urlMock, for: "did")
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchIdentityTrustStatements_serverError_throwsServerError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchIdentityTrustStatements(from: urlMock, for: "did")
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  private let urlMock = URL(string: "some://url")!
  private let rawTrustStatement1Mock = "trustStatement1"
  private let rawTrustStatement2Mock = "trustStatement2"
  private let trustStatement1Mock = IdentityTrustStatementJWT.Mock.validSample
  private let trustStatement2Mock = IdentityTrustStatementJWT.Mock.validSampleItalian
  private var vcSdJwsDecoderMock: VcSdJWSDecoderMock<IdentityTrustStatementJWT>!

  private var repository = TrustStatementRepository()

  private func registerMocks() {
    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
    vcSdJwsDecoderMock = VcSdJWSDecoderMock()
    Container.shared.vcSdJwsDecoder.register { self.vcSdJwsDecoderMock }
  }

  private func createSuccessState() {
    vcSdJwsDecoderMock.decodeFromClosure = { data in
      let string = String(decoding: data, as: UTF8.self)
      switch string {
      case self.rawTrustStatement1Mock:
        return self.trustStatement1Mock
      case self.rawTrustStatement2Mock:
        return self.trustStatement2Mock
      default:
        fatalError("Unexpected string in decoding: \(string)")
      }
    }
  }

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
