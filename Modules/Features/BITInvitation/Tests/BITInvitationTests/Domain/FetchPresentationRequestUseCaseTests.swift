import Factory
import XCTest
@testable import BITCredential
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

  func textExecute_requestObjectOneCredential_argumentsPassed() async throws {
    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock.payload)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 0)
  }

  func testExecute_requestObjectOneCredential_returnsContext() async throws {
    let context = try await useCase.execute(url: urlMock)

    XCTAssertEqual(context.requestObject, Self.requestObjectMock.payload)
    XCTAssertEqual(context.compatibleCredentials, compatibleCredentialsMock)
    XCTAssertEqual(context.selectedCredential, compatibleCredentialsMock.first)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
  }

  func textExecute_requestObjectMultipleCredentials_argumentsPassed() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = CompatibleCredential.Mock.array

    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock.payload)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 0)
  }

  func testExecute_requestObjectMultipleCredentials_returnsContext() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = CompatibleCredential.Mock.array

    let context = try await useCase.execute(url: urlMock)

    XCTAssertEqual(context.requestObject, Self.requestObjectMock.payload)
    XCTAssertEqual(context.compatibleCredentials, CompatibleCredential.Mock.array)
    XCTAssertNil(context.selectedCredential)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
  }

  func textExecute_jwtRequestObject_argumentsPassed() async throws {
    createSuccessState(request: requestObjectJWSMock)

    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock.payload)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, requestObjectJWSMock.payload.clientId)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.type, .verification)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)
  }

  func testExecute_jwtRequestObject_returnsContextWithTrustStatement() async throws {
    createSuccessState(request: requestObjectJWSMock)

    let context = try await useCase.execute(url: urlMock)

    let requestObject = requestObjectJWSMock.payload
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentials, compatibleCredentialsMock)
    XCTAssertEqual(context.selectedCredential, compatibleCredentialsMock.first)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
  }

  func testExecute_jwtRequestObjectWithClientIdPrefix_returnsContextWithTrustStatement() async throws {
    let requestObject = RequestObjectJWS.Mock.clientIdDIDPrefix
    createSuccessState(request: requestObject)

    let context = try await useCase.execute(url: urlMock)

    XCTAssertEqual(context.requestObject, requestObject.payload)
    XCTAssertEqual(context.compatibleCredentials, compatibleCredentialsMock)
    XCTAssertEqual(context.selectedCredential, compatibleCredentialsMock.first)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
  }

  func testExecute_jwtRequestObjectWithoutVct_doesNotPassVct() async throws {
    let requestObject = RequestObjectJWS.Mock.noVct
    createSuccessState(request: requestObject)

    let context = try await useCase.execute(url: urlMock)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, requestObject.payload.clientId)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.type, .verification)
    XCTAssertNil(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
  }

  func testExecute_serviceInvalidUrlError_throwsInvalidUrlError() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestServiceError.invalidRequestUrl

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidUrl)
    }
  }

  func testExecute_serviceExpiredError_throwsExpiredError() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestServiceError.expired

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .expired)
    }
  }

  func testExecute_serviceInvalidRequestError_declinesAndThrowsInvalidRequest() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestServiceError.invalid(
      responseURL: Self.requestObjectMock.payload.responseUri,
      responseError: .invalidRequest)

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(serviceSpy.declineUrlWithReceivedArguments?.url, Self.requestObjectMock.payload.responseUri)
      XCTAssertEqual(serviceSpy.declineUrlWithReceivedArguments?.error, .invalidRequest)

      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .invalidRequest("invalid_request"))
    }
  }

  func testExecute_servicetransactionDataNotSupportedError_declinesAndThrowsTransactionDataNotSupported() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestServiceError.transactionDataNotSupported(
      responseURL: Self.requestObjectMock.payload.responseUri,
      responseError: .invalidRequest)

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(serviceSpy.declineUrlWithReceivedArguments?.url, Self.requestObjectMock.payload.responseUri)
      XCTAssertEqual(serviceSpy.declineUrlWithReceivedArguments?.error, .invalidRequest)

      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .transactionDataNotSupported("invalid_request"))
    }
  }

  func testExecute_serviceNotFoundError_throwsExpired() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestServiceError.expired

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .expired)
    }
  }

  func testExecute_serviceNotFoundError_throwsNotFound() async throws {
    serviceSpy.fetchFromThrowableError = PresentationRequestServiceError.presentationRequestNotFound

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchPresentationRequestUseCaseError, .notFound)
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

  // MARK: Private

  private static let requestObjectMock = RequestObjectJWS.Mock.sample

  private let urlMock = URL(string: "https://example.com")!
  private let vcSchemaIdMock = "vcSchemaId"

  private let requestObjectJWSMock = RequestObjectJWS.Mock.sample
  private let compatibleCredentialsMock: [CompatibleCredential] = [CompatibleCredential.Mock.BIT]
  private let trustInformationMock = TrustInformation.Mock.trustedIdentity

  private var serviceSpy: PresentationRequestServiceProtocolSpy!
  private var getCompatibleCredentialsUseCaseSpy: GetCompatibleCredentialsUseCaseProtocolSpy!
  private var trustInformationServiceSpy: TrustInformationServiceProtocolSpy!

  private var useCase: FetchPresentationRequestUseCase!

  private func registerMocks() {
    serviceSpy = PresentationRequestServiceProtocolSpy()
    getCompatibleCredentialsUseCaseSpy = GetCompatibleCredentialsUseCaseProtocolSpy()
    trustInformationServiceSpy = TrustInformationServiceProtocolSpy()

    Container.shared.presentationRequestService.register { self.serviceSpy }
    Container.shared.getCompatibleCredentialsUseCase.register { self.getCompatibleCredentialsUseCaseSpy }
    Container.shared.trustInformationService.register { self.trustInformationServiceSpy }
  }

  private func createSuccessState(request: RequestObjectJWS? = nil) {
    serviceSpy.fetchFromReturnValue = request ?? requestObjectJWSMock
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = compatibleCredentialsMock
    trustInformationServiceSpy.fetchForTypeVcSchemaIdReturnValue = trustInformationMock
  }
}
