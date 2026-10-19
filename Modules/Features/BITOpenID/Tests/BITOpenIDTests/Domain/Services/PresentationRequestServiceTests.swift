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

  func testFetch_success() async throws {
    repositorySpy.fetchFromReturnValue = requestObjectJWSMock

    let result = try await service.fetch(from: urlMock)

    XCTAssertEqual(urlParserSpy.parseCallsCount, 1)
    XCTAssertEqual(urlParserSpy.parseReceivedUrl, urlMock)
    XCTAssertEqual(repositorySpy.fetchFromCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(requestObjectValidatorSpy.validateTransportCallsCount, 1)
    XCTAssertEqual(requestObjectValidatorSpy.validateTransportReceivedArguments?.jws, requestObjectJWSMock)
    XCTAssertEqual(requestObjectValidatorSpy.validateTransportReceivedArguments?.transport, .network)
    XCTAssertEqual(result, requestObjectJWSMock)
  }

  func testFetch_objectWithOpenID4VPUrlAndValidClientId_returnsRequestObject() async throws {
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: clientIdMock)

    let result = try await service.fetch(from: urlMock)

    XCTAssertEqual(result, requestObjectJWSMock)
  }

  func testFetch_openID4VPWithMismatchedClientId_throwsInvalidError() async throws {
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: "invalid")
    repositorySpy.fetchFromReturnValue = requestObjectJWSMock
    let service = try XCTUnwrap(service)
    let urlMock = urlMock
    let responseUri = requestObjectJWSMock.payload.responseUri

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .invalid(responseURL: responseUri, state: stateMock, responseError: .invalidRequest))
    }
  }

  func testFetch_openID4VPWithVerifierAttestationClientId_returnsRequestObject() async throws {
    let verifierAttestationMock = RequestObjectJWS.Mock.verifierAttestationPrefix
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: verifierAttestationMock.payload.clientIdentifier.raw)
    repositorySpy.fetchFromReturnValue = verifierAttestationMock

    let result = try await service.fetch(from: urlMock)

    XCTAssertEqual(result, verifierAttestationMock)
  }

  func testFetch_openID4VPWithMixedPrefixes_throwsInvalidError() async throws {
    let verifierAttestationMock = RequestObjectJWS.Mock.verifierAttestationPrefix
    urlParserSpy.parseReturnValue = .openID4VP(url: urlMock, clientId: "decentralized_identifier:did:example:12345")
    repositorySpy.fetchFromReturnValue = verifierAttestationMock
    let service = try XCTUnwrap(service)
    let urlMock = urlMock
    let responseUri = verifierAttestationMock.payload.responseUri

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .invalid(responseURL: responseUri, state: stateMock, responseError: .invalidRequest))
    }
  }

  func testFetch_validatorThrows_throwsInvalidError() async throws {
    requestObjectValidatorSpy.validateTransportThrowableError = TestingError.error
    let service = try XCTUnwrap(service)
    let urlMock = urlMock
    let responseUri = requestObjectJWSMock.payload.responseUri

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .invalid(responseURL: responseUri, state: stateMock, responseError: .invalidRequest))
    }
  }

  func testFetch_validatorThrowsVerifierAttestationNotSupported_throwsInvalidError() async throws {
    requestObjectValidatorSpy.validateTransportThrowableError = RequestObjectValidationError.verifierAttestationNotSupported
    let service = try XCTUnwrap(service)
    let urlMock = urlMock
    let responseUri = requestObjectJWSMock.payload.responseUri

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .invalid(responseURL: responseUri, state: stateMock, responseError: .invalidRequest))
    }
  }

  func testFetch_validatorThrowsTransactionDataNotSupported_throwsTransactionDataNotSupportedError() async throws {
    requestObjectValidatorSpy.validateTransportThrowableError = RequestObjectValidationError.transactionDataNotSupported
    let service = try XCTUnwrap(service)
    let urlMock = urlMock
    let responseUri = requestObjectJWSMock.payload.responseUri

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .transactionDataNotSupported(responseURL: responseUri, state: stateMock, responseError: .invalidRequest))
    }
  }

  func testFetch_urlParserThrowsInvalidRequestUrl_throwsInvalidRequestUrl() async throws {
    urlParserSpy.parseThrowableError = PresentationRequestUrlParserError.invalidRequestUrl
    let service = try XCTUnwrap(service)
    let urlMock = urlMock

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .invalidRequestUrl)
    }
  }

  func testFetch_repositoryThrowsPresentationRequestExpired_throwsExpired() async throws {
    repositorySpy.fetchFromThrowableError = PresentationRequestRepositoryError.presentationRequestExpired
    let service = try XCTUnwrap(service)
    let urlMock = urlMock

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .expired)
    }
  }

  func testFetch_repositoryThrowsPresentationRequestNotFound_throwsPresentationRequestNotFound() async throws {
    repositorySpy.fetchFromThrowableError = PresentationRequestRepositoryError.presentationRequestNotFound
    let service = try XCTUnwrap(service)
    let urlMock = urlMock

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .presentationRequestNotFound)
    }
  }

  func testFetch_repositoryThrowsNoConnection_throwsNoInternetConnection() async throws {
    repositorySpy.fetchFromThrowableError = PresentationRequestRepositoryError.noConnection

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestError, .noInternetConnection)
    }
  }

  func testFetch_repositoryThrowsDecodingError_throwsInvalidError() async throws {
    repositorySpy.fetchFromThrowableError = DecodingError.dataCorrupted(
      DecodingError.Context(codingPath: [], debugDescription: "test error"))
    let service = try XCTUnwrap(service)
    let urlMock = urlMock

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(
        error as? PresentationRequestError,
        .invalid(responseURL: nil, state: nil, responseError: .invalidRequest))
    }
  }

  func testDecline_passesArgumentsAndReturnsResponse() async throws {
    let error = PresentationErrorRequestBody.Code.accessDenied
    let responseUri = try XCTUnwrap(requestObjectJWSMock.payload.responseUri)
    let expectedResponse = PresentationResponse(redirectUri: urlMock)
    repositorySpy.declineUrlStateWithReturnValue = expectedResponse

    let response = try await service.decline(url: responseUri, state: stateMock, with: error)

    XCTAssertEqual(repositorySpy.declineUrlStateWithCallsCount, 1)
    XCTAssertEqual(repositorySpy.declineUrlStateWithReceivedArguments?.url, urlMock)
    XCTAssertEqual(repositorySpy.declineUrlStateWithReceivedArguments?.error, error)
    XCTAssertEqual(repositorySpy.declineUrlStateWithReceivedArguments?.state, stateMock)
    XCTAssertEqual(response, expectedResponse)
  }

  func testDecline_repositoryThrowsError_rethrowsError() async throws {
    repositorySpy.declineUrlStateWithThrowableError = TestingError.error
    let responseUri = try XCTUnwrap(requestObjectJWSMock.payload.responseUri)
    let service = try XCTUnwrap(service)

    await XCTAssertThrowsErrorAsync(try await service.decline(url: responseUri, state: stateMock, with: .accessDenied)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let urlMock = URL(string: "https://eid.admin.ch/response")!
  private let clientIdMock = "did:example:12345"
  private let stateMock = "1234"
  private let requestObjectJWSMock = RequestObjectJWS.Mock.sample

  private var urlParserSpy: PresentationRequestUrlParserProtocolSpy!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var requestObjectValidatorSpy: RequestObjectValidatorProtocolSpy!
  private var service: PresentationRequestService!

  private func registerMocks() {
    let urlParserSpy = PresentationRequestUrlParserProtocolSpy()
    self.urlParserSpy = urlParserSpy
    let repositorySpy = PresentationRequestRepositoryProtocolSpy()
    self.repositorySpy = repositorySpy
    let requestObjectValidatorSpy = RequestObjectValidatorProtocolSpy()
    self.requestObjectValidatorSpy = requestObjectValidatorSpy

    Container.shared.presentationRequestUrlParser.register { urlParserSpy }
    Container.shared.presentationRequestRepository.register { repositorySpy }
    Container.shared.requestObjectValidator.register { requestObjectValidatorSpy }
  }

  private func createSuccessState() {
    urlParserSpy.parseReturnValue = .https(urlMock)
    repositorySpy.fetchFromReturnValue = requestObjectJWSMock
  }
}
