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

  func textExecute_plainRequestObjectOneCredential_argumentsPassed() async throws {
    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 0)
  }

  func testExecute_plainRequestObjectOneCredential_returnsContext() async throws {
    let context = try await useCase.execute(url: urlMock)

    let requestObject = Self.requestObjectMock
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentials, compatibleCredentialsMock)
    XCTAssertEqual(context.selectedCredential, compatibleCredentialsMock.first)
    XCTAssertEqual(context.trustInformation.identity, .untrusted)
    XCTAssertEqual(context.trustInformation.vcSchema, .notProtected)
  }

  func textExecute_plainRequestObjectMultipleCredentials_argumentsPassed() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = CompatibleCredential.Mock.array

    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 0)
  }

  func testExecute_plainRequestObjectMultipleCredentials_returnsContext() async throws {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = CompatibleCredential.Mock.array

    let context = try await useCase.execute(url: urlMock)

    let requestObject = Self.requestObjectMock
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentials, CompatibleCredential.Mock.array)
    XCTAssertNil(context.selectedCredential)
    XCTAssertEqual(context.trustInformation.identity, .untrusted)
    XCTAssertEqual(context.trustInformation.vcSchema, .notProtected)
  }

  func textExecute_jwtRequestObject_argumentsPassed() async throws {
    createSuccessState(request: .jwt(requestObjectJWSMock))

    _ = try await useCase.execute(url: urlMock)

    XCTAssertEqual(serviceSpy.fetchFromCallsCount, 1)
    XCTAssertEqual(serviceSpy.fetchFromReceivedUrl, urlMock)
    XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 0)

    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingReceivedRequestObject, Self.requestObjectMock)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, requestObjectJWSMock.payload.issuer)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.type, .verification)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, vcSchemaIdMock)
  }

  func testExecute_jwtRequestObject_returnsContextWithTrustStatement() async throws {
    createSuccessState(request: .jwt(requestObjectJWSMock))

    let context = try await useCase.execute(url: urlMock)

    let requestObject = requestObjectJWSMock.payload
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentials, compatibleCredentialsMock)
    XCTAssertEqual(context.selectedCredential, compatibleCredentialsMock.first)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
  }

  func testExecute_jwtRequestObjectWithoutVct_doesNotPassVct() async throws {
    createSuccessState(request: .jwt(RequestObjectJWS.Mock.noVct))

    let context = try await useCase.execute(url: urlMock)

    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, requestObjectJWSMock.payload.issuer)
    XCTAssertEqual(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.type, .verification)
    XCTAssertNil(trustInformationServiceSpy.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId)
    XCTAssertEqual(context.trustInformation, trustInformationMock)
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

  func testExecute_serviceInvalidRequestError_declinesAndThrowsInvalidRequestError() async throws {
    let request = PresentationRequest.plain(Self.requestObjectMock)
    createSuccessState(request: request)
    serviceSpy.fetchFromThrowableError = FetchPresentationRequestError.invalid(request: request, error: .invalidRequest)

    do {
      _ = try await useCase.execute(url: urlMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(serviceSpy.declineUrlWithCallsCount, 1)
      XCTAssertEqual(serviceSpy.declineUrlWithReceivedArguments?.url, request.requestObject.responseUri)
      XCTAssertEqual(serviceSpy.declineUrlWithReceivedArguments?.error, .invalidRequest)

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

  // MARK: Private

  private static let requestObjectMock: RequestObject = .Mock.VcSdJwt.sample

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

  private func createSuccessState(request: PresentationRequest = .plain(requestObjectMock)) {
    serviceSpy.fetchFromReturnValue = request
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = compatibleCredentialsMock
    trustInformationServiceSpy.fetchForTypeVcSchemaIdReturnValue = trustInformationMock
  }
}

// swiftlint:enable force_unwrapping implicitly_unwrapped_optional
