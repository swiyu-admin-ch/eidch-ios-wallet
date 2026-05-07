// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import BITNetworking
import Moya
import XCTest
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
  }

  // MARK: - Fetch

  func testFetch_plainObject_returnsPlainObjectResponse() async throws {
    let expectedRequestObject = RequestObject.Mock.VcSdJwt.jsonSampleData
    mockResponse(code: 200, data: expectedRequestObject)

    let response = try await repository.fetch(from: urlMock)

    if case .plain(let requestObject) = response {
      XCTAssertEqual(requestObject, RequestObject.Mock.VcSdJwt.sample)
      XCTAssertEqual(requestObject.raw, expectedRequestObject)
    } else {
      XCTFail("Wrong request object response type")
    }
  }

  func testFetch_jwtRequestObject_returnsRequestObjectJWSResponse() async throws {
    let expectedRequestObject = RequestObjectJWS.Mock.sampleData
    mockResponse(code: 200, data: expectedRequestObject)

    let response = try await repository.fetch(from: urlMock)

    if case .jwt(let jws) = response {
      XCTAssertEqual(jws.payload, RequestObjectJWS.Mock.sampleJWT)
    } else {
      XCTFail("Wrong request object response type")
    }
  }

  func testFetch_goneError_throwsExpiredError() async throws {
    mockResponse(code: 410)

    do {
      _ = try await repository.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? FetchPresentationRequestError else { return XCTFail("Unexpected error: \(error)") }
      XCTAssertEqual(error, .expired)
    }
  }

  func testFetch_notFoundError_throwsInvalidError() async throws {
    mockResponse(code: 404)

    do {
      _ = try await repository.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? FetchPresentationRequestError else { return XCTFail("Unexpected error: \(error)") }
      XCTAssertEqual(error, .notFound)
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

  func testSubmit_BadRequestWithUnknownResponse_ReturnsCredentialInvalid() async throws {
    try mockResponse(code: 400, data: XCTUnwrap("{\"foo\":\"bar\"}".data(using: .utf8)))

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? PresentationRequestRepositoryError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error, .presentationResponseError(nil, nil))
    }
  }

  func testSubmit_ProcessClosed_returnsPresentationResponseError() async throws {
    try mockResponse(code: 400, data: XCTUnwrap("{\"error\":\"verification_process_closed\"}".data(using: .utf8)))

    await XCTAssertThrowsErrorAsync(try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)) { error in
      guard let error = error as? PresentationRequestRepositoryError else { return XCTFail("Expected a PresentationRequestRepositoryError") }
      guard case .presentationResponseError(let rawErrorCode, let errorDescription) = error else { return XCTFail("Wrong error: \(error)") }
      XCTAssertEqual(rawErrorCode, "verification_process_closed")
      XCTAssertNil(errorDescription)
    }
  }

  func testSubmit_InvalidGrant_returnsInvalidGrant() async throws {
    try mockResponse(code: 400, data: XCTUnwrap("{\"error\":\"invalid_grant\"}".data(using: .utf8)))

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? PresentationRequestRepositoryError else { return XCTFail("Expected a PresentationRequestRepositoryError") }
      guard case .invalidGrant = error else { return XCTFail("Wrong error: \(error)") }
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
  private let authorizationResponseMock = AuthorizationResponseBody.json(AuthorizationResponse(
    vpToken: "token",
    presentationSubmission: AuthorizationResponse.PresentationSubmission(
      id: "id",
      definitionId: "94a31944-e8b8-4d18-993b-427a1e2be867",
      descriptorMap: [
        AuthorizationResponse.DescriptorMap(id: "Multipass", format: "vc+sd-jwt", path: "$"),
      ])), .dif)
  private var repository = PresentationRequestRepository()

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
