import Factory
import XCTest
@testable import BITInvitation
@testable import BITJWT
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class FetchPresentationRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    useCase = FetchPresentationRequestUseCase()
    createSuccessState()
  }

  func textExecute_plainRequestObjectOneCredential_argumentsPassed() async throws {
    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineForWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock)

    XCTAssertEqual(trustStatementServiceSpy.fetchForCallsCount, 0)
  }

  func testExecute_plainRequestObjectOneCredential_returnsContext() async throws {
    let context = try await useCase.execute(url: urlMock)

    let requestObject = Self.requestObjectMock
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentialsRequestMap, [requestObject.firstInputDescriptor!.id: compatibleCredentialsMock])
    XCTAssertNil(context.inputDescriptorId)
    XCTAssertEqual(context.selectedCredentials, [requestObject.firstInputDescriptor!.id: compatibleCredentialsMock.first!])
    XCTAssertNil(context.trustStatement)
  }

  func textExecute_plainRequestObjectMultipleCredentials_argumentsPassed() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = [Self.requestObjectMock.firstInputDescriptor!.id: CompatibleCredential.Mock.array]

    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineForWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock)

    XCTAssertEqual(trustStatementServiceSpy.fetchForCallsCount, 0)
  }

  func testExecute_plainRequestObjectMultipleCredentials_returnsContext() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = [Self.requestObjectMock.firstInputDescriptor!.id: CompatibleCredential.Mock.array]

    let context = try await useCase.execute(url: urlMock)

    let requestObject = Self.requestObjectMock
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentialsRequestMap, [requestObject.firstInputDescriptor!.id: CompatibleCredential.Mock.array])
    XCTAssertEqual(context.inputDescriptorId, requestObject.firstInputDescriptor!.id)
    XCTAssertNil(context.selectedCredentials[requestObject.firstInputDescriptor!.id])
    XCTAssertNil(context.trustStatement)
  }

  func textExecute_jwtRequestObject_argumentsPassed() async throws {
    createSuccessState(request: .jwt(jwtRequestObjectMock))

    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineForWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock)

    XCTAssertEqual(trustStatementServiceSpy.fetchForCallsCount, 1)
    XCTAssertEqual(trustStatementServiceSpy.fetchForReceivedSubjectDid, jwtRequestObjectMock.payload.issuer)
  }

  func testExecute_jwtRequestObject_returnsContextWithTrustStatement() async throws {
    createSuccessState(request: .jwt(jwtRequestObjectMock), trustStatement: trustStatementMock)

    let context = try await useCase.execute(url: urlMock)

    let requestObject = jwtRequestObjectMock.payload
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentialsRequestMap, [requestObject.firstInputDescriptor!.id: compatibleCredentialsMock])
    XCTAssertNil(context.inputDescriptorId)
    XCTAssertEqual(context.selectedCredentials, [requestObject.firstInputDescriptor!.id: compatibleCredentialsMock.first!])
    XCTAssertEqual(context.trustStatement, trustStatementMock)
  }

  func testExecute_serviceInvalidUrlError_throwsInvalidUrlError() async throws {
    serviceSpy.fetchFromThrowableError = FetchPresentationRequestError.invalidRequestUrl

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidUrl)
    }
  }

  func testExecute_serviceExpiredError_throwsExpiredRequestError() async throws {
    serviceSpy.fetchFromThrowableError = FetchPresentationRequestError.expired

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .expiredRequest)
    }
  }

  func testExecute_serviceInvalidError_declinesAndThrowsInvalidRequestError() async throws {
    let request = PresentationRequest.plain(Self.requestObjectMock)
    createSuccessState(request: request, trustStatement: trustStatementMock)
    serviceSpy.fetchFromThrowableError = FetchPresentationRequestError.invalid(request: request)

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(serviceSpy.declineForWithCallsCount, 1)
      XCTAssertEqual(serviceSpy.declineForWithReceivedArguments?.requestObject, request.requestObject)
      XCTAssertEqual(serviceSpy.declineForWithReceivedArguments?.error, .invalidRequest)

      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest)
    }
  }

  func testExecute_serviceNotFoundError_throwsInvalidRequestError() async throws {
    serviceSpy.fetchFromThrowableError = FetchPresentationRequestError.notFound

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest)
    }
  }

  func testExecute_serviceRequestObjectError_throwsInvalidRequestError() async throws {
    serviceSpy.fetchFromThrowableError = RequestObjectError.invalidInputDescriptorFormat

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest)
    }
  }

  func testExecute_serviceDecodingError_throwsInvalidRequestError() async throws {
    serviceSpy.fetchFromThrowableError = DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: [], debugDescription: ""))

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest)
    }
  }

  func testExecute_serviceJWSDecoderError_throwsInvalidRequestError() async throws {
    serviceSpy.fetchFromThrowableError = JWSDecoderError.invalidPayload

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest)
    }
  }

  func testExecute_serviceTestingError_throwsTestingError() async throws {
    serviceSpy.fetchFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_getCompatibleCredentialsError_throwsError() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_invalidPresentationRequest_throwsInvalidPresentRequestError() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = [:]

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest)
    }
  }

  func testExecute_fetchTrustStatementError_returnsContextWithoutTrustStatement() async throws {
    createSuccessState(request: .jwt(jwtRequestObjectMock), trustStatement: trustStatementMock)
    trustStatementServiceSpy.fetchForThrowableError = TestingError.error

    let context = try await useCase.execute(url: urlMock)

    let requestObject = jwtRequestObjectMock.payload
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentialsRequestMap, [requestObject.firstInputDescriptor!.id: compatibleCredentialsMock])
    XCTAssertNil(context.inputDescriptorId)
    XCTAssertEqual(context.selectedCredentials, [requestObject.firstInputDescriptor!.id: compatibleCredentialsMock.first!])
    XCTAssertNil(context.trustStatement)
    XCTAssertEqual(serviceSpy.declineForWithCallsCount, 0)
  }

  // MARK: Private

  private static let requestObjectMock: RequestObject = .Mock.VcSdJwt.sample

  private let urlMock = URL(string: "https://example.com")!

  private let jwtRequestObjectMock: JWTRequestObject = JWTRequestObjectPayload.Mock.sample
  private let compatibleCredentialsMock: [CompatibleCredential] = [CompatibleCredential.Mock.BIT]
  private let trustStatementMock = TrustStatementPayload.Mock.validSample

  private var serviceSpy: PresentationRequestServiceProtocolSpy!
  private var getCompatibleCredentialsUseCaseSpy: GetCompatibleCredentialsUseCaseProtocolSpy!
  private var trustStatementServiceSpy: TrustStatementServiceProtocolSpy!

  private var useCase: FetchPresentationRequestUseCase!

  private func registerMocks() {
    serviceSpy = PresentationRequestServiceProtocolSpy()
    getCompatibleCredentialsUseCaseSpy = GetCompatibleCredentialsUseCaseProtocolSpy()
    trustStatementServiceSpy = TrustStatementServiceProtocolSpy()

    Container.shared.presentationRequestService.register { self.serviceSpy }
    Container.shared.getCompatibleCredentialsUseCase.register { self.getCompatibleCredentialsUseCaseSpy }
    Container.shared.trustStatementService.register { self.trustStatementServiceSpy }
  }

  private func createSuccessState(request: PresentationRequest = .plain(requestObjectMock), trustStatement: TrustStatement? = nil) {
    serviceSpy.fetchFromReturnValue = request
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = [request.requestObject.firstInputDescriptor!.id: compatibleCredentialsMock]
    trustStatementServiceSpy.fetchForReturnValue = trustStatement
  }
}

// swiftlint:enable force_unwrapping implicitly_unwrapped_optional
