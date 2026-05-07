import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class PresentationRequestServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    service = PresentationRequestService()
    createSuccessState()
  }

  func testFetch_plainRequestObject_returnsPlainRequestObject() async throws {
    let result = try await service.fetch(from: urlMock)

    if case .plain(let requestObject) = result {
      XCTAssertEqual(requestObject, requestObjectMock)
    } else {
      XCTFail("Wrong request object response type")
    }
  }

  func testFetch_plainRequestObject_passesArguments() async throws {
    _ = try await service.fetch(from: urlMock)

    XCTAssertEqual(urlParserSpy.parseCallsCount, 1)
    XCTAssertEqual(urlParserSpy.parseReceivedUrl, urlMock)
    XCTAssertEqual(repositorySpy.fetchFromCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferCallsCount, 0)
    XCTAssertEqual(requestObjectValidatorSpy.validateCallsCount, 1)
    XCTAssertEqual(requestObjectValidatorSpy.validateReceivedRequestObject, requestObjectMock)
  }

  func testFetch_jwtRequestObject_returnsJwtRequestObject() async throws {
    repositorySpy.fetchFromReturnValue = .jwt(requestObjectJWSMock)

    let result = try await service.fetch(from: urlMock)

    if case .jwt(let jws) = result {
      XCTAssertEqual(jws, requestObjectJWSMock)
    } else {
      XCTFail("Wrong request object response type")
    }
  }

  func testFetch_jwtRequestObject_passesArguments() async throws {
    repositorySpy.fetchFromReturnValue = .jwt(requestObjectJWSMock)

    _ = try await service.fetch(from: urlMock)

    XCTAssertEqual(urlParserSpy.parseCallsCount, 1)
    XCTAssertEqual(urlParserSpy.parseReceivedUrl, urlMock)
    XCTAssertEqual(repositorySpy.fetchFromCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferReceivedJws, requestObjectJWSMock)
    XCTAssertEqual(requestObjectValidatorSpy.validateCallsCount, 1)
    XCTAssertEqual(requestObjectValidatorSpy.validateReceivedRequestObject, requestObjectJWSMock.payload)
  }

  func testFetch_plainRequestObjectWithOpenID4VPUrlAndValidClientId_returnsPlainRequestObject() async throws {
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: clientIdMock)

    let result = try await service.fetch(from: urlMock)

    if case .plain(let requestObject) = result {
      XCTAssertEqual(requestObject, requestObjectMock)
    } else {
      XCTFail("Wrong request object response type")
    }
  }

  func testFetch_plainRequestObjectWithOpenID4VPUrlAndInvalidClientId_throwsInvalidRequestError() async throws {
    let request = PresentationRequest.plain(requestObjectMock)
    repositorySpy.fetchFromReturnValue = request
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: "invalid")

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(let presentationRequest, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationRequest, request)
        XCTAssertEqual(presentationError, .invalidRequest)
      }
    }
  }

  func testFetch_jwtRequestObjectWithOpenID4VPUrlAndValidClientId_returnsJwtRequestObject() async throws {
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: clientIdMock)
    repositorySpy.fetchFromReturnValue = .jwt(requestObjectJWSMock)

    let result = try await service.fetch(from: urlMock)

    if case .jwt(let jws) = result {
      XCTAssertEqual(jws, requestObjectJWSMock)
    } else {
      XCTFail("Wrong request object response type")
    }
  }

  func testFetch_jwtRequestObjectWithOpenID4VPUrlAndInvalidClientId_throwsInvalidRequestError() async throws {
    let request = PresentationRequest.jwt(requestObjectJWSMock)
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: "invalid")
    repositorySpy.fetchFromReturnValue = request

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(let presentationRequest, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationRequest, request)
        XCTAssertEqual(presentationError, .invalidRequest)
      }
    }
  }

  func testFetch_jwtRequestObjectWithInvalidAlgorithm_throwsInvalidError() async throws {
    let request = PresentationRequest.jwt(RequestObjectJWS.Mock.unsupportedAlgorithm)
    repositorySpy.fetchFromReturnValue = request

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(let presentationRequest, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationRequest, request)
        XCTAssertEqual(presentationError, .invalidRequest)
      }
    }
  }

  func testFetch_jwtRequestObjectWithClientIdMismatch_throwsInvalidError() async throws {
    let request = PresentationRequest.jwt(RequestObjectJWS.Mock.clientIdMismatch)
    repositorySpy.fetchFromReturnValue = request

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(let presentationRequest, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationRequest, request)
        XCTAssertEqual(presentationError, .invalidRequest)
      } else {
        XCTFail("Wrong error: \(error)")
      }
    }
  }

  func testFetch_jwsValidatorThrowsError_throwsInvalidError() async throws {
    repositorySpy.fetchFromReturnValue = .jwt(requestObjectJWSMock)
    jwsValidatorMock.validateIssuerDidActivationBufferThrowableError = TestingError.error

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(_, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationError, .invalidRequest)
        XCTAssertTrue(true, "Wrong error")
      }
    }
  }

  func testFetch_plainRequestObjectRequestObjectValidatorReturnsFalse_throwsInvalidError() async throws {
    requestObjectValidatorSpy.validateReturnValue = false

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(_, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationError, .invalidRequest)
        XCTAssertTrue(true, "Wrong error")
      }
    }
  }

  func testFetch_jwtRequestObjectRequestObjectValidatorReturnsFalse_throwsInvalidError() async throws {
    repositorySpy.fetchFromReturnValue = .jwt(requestObjectJWSMock)
    requestObjectValidatorSpy.validateReturnValue = false

    do {
      _ = try await service.fetch(from: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      if case .invalid(_, let presentationError) = error as? FetchPresentationRequestError {
        XCTAssertEqual(presentationError, .invalidRequest)
        XCTAssertTrue(true, "Wrong error")
      }
    }
  }

  func testDecline_passesArguments() async throws {
    let error = PresentationErrorRequestBody.Code.accessDenied

    let responseUri = try XCTUnwrap(requestObjectMock.responseUri)

    try await service.decline(url: responseUri, with: error)

    XCTAssertEqual(repositorySpy.declineUrlWithCallsCount, 1)
    XCTAssertEqual(repositorySpy.declineUrlWithReceivedArguments?.url.absoluteString, "response_uri")
    XCTAssertEqual(repositorySpy.declineUrlWithReceivedArguments?.error, error)
  }

  func testDecline_repositoryThrowsError_throwsError() async throws {
    repositorySpy.declineUrlWithThrowableError = TestingError.error

    do {
      let responseUri = try XCTUnwrap(requestObjectMock.responseUri)

      _ = try await service.decline(url: responseUri, with: .accessDenied)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let urlMock = URL(string: "https://example.com")!
  private let clientIdMock = "did:example:12345"
  private let requestObjectMock: RequestObject = .Mock.VcSdJwt.sample
  private let requestObjectJWSMock = RequestObjectJWS.Mock.sample

  private var urlParserSpy: PresentationRequestUrlParserProtocolSpy!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var jwsValidatorMock: JWSValidatorMock<RequestObjectJWT>!
  private var requestObjectValidatorSpy: RequestObjectValidatorProtocolSpy!

  private var service: PresentationRequestService!

  private func registerMocks() {
    urlParserSpy = PresentationRequestUrlParserProtocolSpy()
    repositorySpy = PresentationRequestRepositoryProtocolSpy()
    jwsValidatorMock = JWSValidatorMock()
    requestObjectValidatorSpy = RequestObjectValidatorProtocolSpy()

    Container.shared.presentationRequestUrlParser.register { self.urlParserSpy }
    Container.shared.presentationRequestRepository.register { self.repositorySpy }
    Container.shared.jwsValidator.register { self.jwsValidatorMock }
    Container.shared.requestObjectValidator.register { self.requestObjectValidatorSpy }
  }

  private func createSuccessState() {
    urlParserSpy.parseReturnValue = .https(urlMock)
    repositorySpy.fetchFromReturnValue = .plain(requestObjectMock)
    requestObjectValidatorSpy.validateReturnValue = true
  }
}

// swiftlint:enable force_unwrapping implicitly_unwrapped_optional
