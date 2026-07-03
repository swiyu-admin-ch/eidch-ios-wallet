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
    XCTAssertEqual(requestObjectValidatorSpy.validateCallsCount, 1)
    XCTAssertEqual(requestObjectValidatorSpy.validateReceivedJws, requestObjectJWSMock)
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

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(
        error as? PresentationRequestServiceError,
        .invalid(responseURL: self.requestObjectJWSMock.payload.responseUri, responseError: .invalidRequest))
    }
  }

  func testFetch_validatorThrows_throwsInvalidError() async throws {
    requestObjectValidatorSpy.validateThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(
        error as? PresentationRequestServiceError,
        .invalid(responseURL: self.requestObjectJWSMock.payload.responseUri, responseError: .invalidRequest))
    }
  }

  func testFetch_validatorThrowsTransactionDataNotSupported_throwsTransactionDataNotSupportedError() async throws {
    requestObjectValidatorSpy.validateThrowableError = RequestObjectValidationError.transactionDataNotSupported

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(
        error as? PresentationRequestServiceError,
        .transactionDataNotSupported(responseURL: self.requestObjectJWSMock.payload.responseUri, responseError: .invalidRequest))
    }
  }

  func testFetch_urlParserThrowsInvalidRequestUrl_throwsInvalidRequestUrl() async throws {
    urlParserSpy.parseThrowableError = PresentationRequestUrlParserError.invalidRequestUrl

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestServiceError, .invalidRequestUrl)
    }
  }

  func testFetch_repositoryThrowsPresentationRequestExpired_throwsExpired() async throws {
    repositorySpy.fetchFromThrowableError = PresentationRequestRepositoryError.presentationRequestExpired

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestServiceError, .expired)
    }
  }

  func testFetch_repositoryThrowsPresentationRequestNotFound_throwsPresentationRequestNotFound() async throws {
    repositorySpy.fetchFromThrowableError = PresentationRequestRepositoryError.presentationRequestNotFound

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(error as? PresentationRequestServiceError, .presentationRequestNotFound)
    }
  }

  func testFetch_repositoryThrowsDecodingError_throwsInvalidError() async throws {
    repositorySpy.fetchFromThrowableError = DecodingError.dataCorrupted(
      DecodingError.Context(codingPath: [], debugDescription: "test error"))

    await XCTAssertThrowsErrorAsync(try await service.fetch(from: urlMock)) { error in
      XCTAssertEqual(
        error as? PresentationRequestServiceError,
        .invalid(responseURL: nil, responseError: .invalidRequest))
    }
  }

  func testDecline_passesArguments() async throws {
    let error = PresentationErrorRequestBody.Code.accessDenied

    let responseUri = try XCTUnwrap(requestObjectJWSMock.payload.responseUri)

    try await service.decline(url: responseUri, with: error)

    XCTAssertEqual(repositorySpy.declineUrlWithCallsCount, 1)
    XCTAssertEqual(repositorySpy.declineUrlWithReceivedArguments?.url, urlMock)
    XCTAssertEqual(repositorySpy.declineUrlWithReceivedArguments?.error, error)
  }

  func testDecline_repositoryThrowsError_rethrowsError() async throws {
    repositorySpy.declineUrlWithThrowableError = TestingError.error
    let responseUri = try XCTUnwrap(requestObjectJWSMock.payload.responseUri)

    await XCTAssertThrowsErrorAsync(try await service.decline(url: responseUri, with: .accessDenied)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let urlMock = URL(string: "https://eid.admin.ch/response")!
  private let clientIdMock = "did:example:12345"
  private let requestObjectJWSMock = RequestObjectJWS.Mock.sample

  private var urlParserSpy: PresentationRequestUrlParserProtocolSpy!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var requestObjectValidatorSpy: RequestObjectValidatorProtocolSpy!
  private var service: PresentationRequestService!

  private func registerMocks() {
    urlParserSpy = PresentationRequestUrlParserProtocolSpy()
    repositorySpy = PresentationRequestRepositoryProtocolSpy()
    requestObjectValidatorSpy = RequestObjectValidatorProtocolSpy()

    Container.shared.presentationRequestUrlParser.register { self.urlParserSpy }
    Container.shared.presentationRequestRepository.register { self.repositorySpy }
    Container.shared.requestObjectValidator.register { self.requestObjectValidatorSpy }
  }

  private func createSuccessState() {
    urlParserSpy.parseReturnValue = .https(urlMock)
    repositorySpy.fetchFromReturnValue = requestObjectJWSMock
  }
}
