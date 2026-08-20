// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import BITCore
import BITNetworking
import Factory
import Moya
import Spyable
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

final class PresentationRequestRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
    registerMocks()
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReturnValue = jweMock
    repository = PresentationRequestRepository()
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
    let presentationResponse = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)

    XCTAssertNil(presentationResponse)
    let response = try JSONDecoder().decode([String: String].self, from: XCTUnwrap(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.data))
    XCTAssertEqual(response["vp_token"], "{\"vct\":[\"token\"]}")
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.publicKey, encryptionMock.jwk)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.encryptionAlgorithm, encryptionMock.algorithm)
    XCTAssertNil(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.compressionAlgorithm)
  }

  func testSubmitPresentation_responseWithRedirect_ReturnsRedirect() async throws {
    let url = "https://verifier.ch"
    mockResponse(code: 200, data: Data("{\"redirect_uri\":\"\(url)\"}".utf8))

    let response = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)

    XCTAssertEqual(response?.redirectUri?.absoluteString, url)
  }

  func testSubmitPresentation_invalidResponse_returnsNil() async throws {
    let url = "https://verifier.ch"
    mockResponse(code: 201, data: Data("{\"redirect_uri\":\"\(url)\"}".utf8))

    let response = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)

    XCTAssertNil(response)
  }

  func testSubmitPresentation_InvalidRedirectUri_ThrowsInvalidRedirectUri() async throws {
    mockResponse(code: 200, data: Data("{\"redirect_uri\":\"swiyu-verify://1234\"}".utf8))

    await XCTAssertThrowsErrorAsync(try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)) { error in
      XCTAssertEqual(error as? PresentationResponseValidationError, .invalidRedirectUri)
    }
  }

  func testSubmit_InternalServerError_ReturnsPresentationFailed() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  func testSubmit_NotFoundError_ReturnsNetworkError() async throws {
    mockResponse(code: 404)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .notFound)
    }
  }

  func testSubmit_UnprocessableEntity_ReturnsNetworkErrorUnprocessableEntity() async throws {
    mockResponse(code: 422)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .unprocessableEntity)
    }
  }

  func testSubmit_BadRequest_ReturnsNetworkErrorBadRequest() async throws {
    mockResponse(code: 400)

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .badRequest)
    }
  }

  func testSubmit_jweEncrypterFails_ReturnsError() async throws {
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmThrowableError = TestingError.error

    do {
      _ = try await repository.submit(authorizationResponse: authorizationResponseMock, to: urlMock, encryption: encryptionMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: - Decline

  func testDecline_success() async throws {
    let response = try await repository.decline(url: urlMock, with: .accessDenied)

    XCTAssertNil(response)
  }

  func testDecline_redirect_returnsRedirect() async throws {
    let url = "https://verifier.ch"
    mockResponse(code: 200, data: Data("{\"redirect_uri\":\"\(url)\"}".utf8))

    let response = try await repository.decline(url: urlMock, with: .accessDenied)

    XCTAssertEqual(response?.redirectUri?.absoluteString, url)
  }

  func testDecline_Failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.decline(url: urlMock, with: .accessDenied)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  private static let vpToken = ["vct": ["token"]]

  private let urlMock = URL(string: "some://url")!
  private let authorizationResponseMock = AuthorizationResponse(vpToken: vpToken)
  private let jweMock = "jwe"
  private let encryptionMock = AuthorizationResponseEncryption(jwk: .Mock.validSample, algorithm: .A256GCM)
  private var repository = PresentationRequestRepository()
  private var jwsDecoderSpy: JWSDecoderMock<RequestObjectJWT>!
  private var jweEncrypterSpy: JWEEncrypterProtocolSpy!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

  private func registerMocks() {
    jwsDecoderSpy = JWSDecoderMock(jwt: RequestObjectJWS.Mock.sampleJWT, rawPayload: "rawPayload")
    jweEncrypterSpy = JWEEncrypterProtocolSpy()
    Container.shared.jwsDecoder.register { @MainActor in self.jwsDecoderSpy }
    Container.shared.jweEncrypter.register { @MainActor in self.jweEncrypterSpy }
  }
}
