// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import BITNetworking
import Factory
import Moya
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class PresentationRequestRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = PresentationRequestRepository()
    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
    registerMocks()
  }

  // MARK: - Fetch

  func testFetch_jwtRequestObject_returnsRequestObjectJWSResponse() async throws {
    let expectedRequestObject = RequestObjectJWS.Mock.sampleData
    mockResponse(code: 200, data: expectedRequestObject)

    let response = try await repository.fetch(from: urlMock)

    XCTAssertEqual(response.payload, RequestObjectJWS.Mock.sampleJWT)
  }

  func testFetch_goneError_throwsExpiredError() async throws {
    mockResponse(code: 410)

    do {
      _ = try await repository.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? PresentationRequestRepositoryError else { return XCTFail("Unexpected error: \(error)") }
      XCTAssertEqual(error, .presentationRequestExpired)
    }
  }

  func testFetch_notFoundError_throwsInvalidError() async throws {
    mockResponse(code: 404)

    do {
      _ = try await repository.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? PresentationRequestRepositoryError else { return XCTFail("Unexpected error: \(error)") }
      XCTAssertEqual(error, .presentationRequestNotFound)
    }
  }

  func testFetch_serverError_throwsServerError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Unexpected error: \(error)") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - Submit

  func testSubmitPresentation_Success() async throws {
    try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
  }

  func testSubmit_InternalServerError_ReturnsPresentationFailed() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  func testSubmit_NotFoundError_ReturnsNetworkError() async throws {
    mockResponse(code: 404)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .notFound)
    }
  }

  func testSubmit_UnprocessableEntity_ReturnsNetworkErrorUnprocessableEntity() async throws {
    mockResponse(code: 422)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .unprocessableEntity)
    }
  }

  func testSubmit_BadRequest_ReturnsNetworkErrorBadRequest() async throws {
    mockResponse(code: 400)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .badRequest)
    }
  }

  // MARK: - Decline

  func testDecline_success() async throws {
    try await repository.decline(url: urlMock, with: .accessDenied)
  }

  func testDecline_Failure() async throws {
    mockResponse(code: 500)

    do {
      try await repository.decline(url: urlMock, with: .accessDenied)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  private let urlMock = URL(string: "some://url")!
  private let authorizationResponseMock = AuthorizationResponseBody.json(AuthorizationResponse(vpToken: ["vct": ["token"]]))
  private var repository = PresentationRequestRepository()
  private var jwsDecoderSpy: JWSDecoderMock<RequestObjectJWT>!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

  private func registerMocks() {
    jwsDecoderSpy = JWSDecoderMock(jwt: RequestObjectJWS.Mock.sampleJWT, rawPayload: "rawPayload")
    Container.shared.jwsDecoder.register { @MainActor in self.jwsDecoderSpy }
  }
}
