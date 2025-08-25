import Factory
import XCTest
@testable import BITInvitation
@testable import BITJWT
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class ProcessPresentationRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    useCase = ProcessPresentationRequestUseCase()
    createSuccessState()
  }

  func testExecute_plainRequestObject_returnsContext() async throws {
    for url in [httpsUrl, openID4VPUrl] {
      let result = try await useCase.execute(url: url)

      assertPresentationRequestContext(context: result)
    }
  }

  func testExecute_plainRequestObjectWithHttpUrl_passesArguments() async throws {
    _ = try await useCase.execute(url: httpsUrl)

    assertUseCasesAreCalled()
  }

  func testExecute_plainRequestObjectWithOpenID4VPUrl_passesArguments() async throws {
    _ = try await useCase.execute(url: openID4VPUrl)

    assertUseCasesAreCalled()
  }

  func testExecute_JWTRequestObject_returnsContext() async throws {
    createSuccessState(requestObject: jwtRequestObjectMock, trustStatement: trustStatementMock)

    for url in [httpsUrl, openID4VPUrl] {
      let result = try await useCase.execute(url: url)

      assertPresentationRequestContext(context: result, requestObject: jwtRequestObjectMock, trustStatement: trustStatementMock)
    }
  }

  func testExecute_JWTRequestObjectWithHttpUrl_passesArguments() async throws {
    createSuccessState(requestObject: jwtRequestObjectMock, trustStatement: trustStatementMock)

    _ = try await useCase.execute(url: httpsUrl)

    assertUseCasesAreCalled(fetchTrustStatementIsCalled: true)
  }

  func testExecute_JWTRequestObjectWithOpenID4VPUrl_passesArguments() async throws {
    createSuccessState(requestObject: jwtRequestObjectMock, trustStatement: trustStatementMock)

    _ = try await useCase.execute(url: openID4VPUrl)

    assertUseCasesAreCalled(fetchTrustStatementIsCalled: true)
  }

  func testExecute_fetchTrustStatementError_returnsContextWithoutTrustStatement() async throws {
    createSuccessState(requestObject: jwtRequestObjectMock, trustStatement: trustStatementMock)
    fetchTrustStatementUseCase.executeIssuerThrowableError = TestingError.error

    let result = try await useCase.execute(url: httpsUrl)

    assertPresentationRequestContext(context: result)
  }

  func testExecute_clientIdMismatch_throwsInvalidClientIdError() async throws {
    createSuccessState(requestObject: Self.requestObjectMock, trustStatement: trustStatementMock)
    let url = URL(string: "openid4vp://?client_id=other_id&request_uri=https%3A%2F%2Fexample.com")!

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? BITInvitation.PresentationError, .invalidClientId)
      XCTAssertEqual(denyPresentationUseCase.executeRequestObjectErrorCallsCount, 1)
    }
  }

  func testExecute_missingClientId_throwsInvalidClientIdError() async throws {
    createSuccessState(requestObject: Self.requestObjectMock, trustStatement: trustStatementMock)
    let url = URL(string: "openid4vp://?request_uri=https%3A%2F%2Fexample.com")!

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? BITInvitation.PresentationError, .invalidClientId)
    }
  }

  func testExecute_missingRequestUri_throwsInvalidRequestUriError() async throws {
    createSuccessState(requestObject: Self.requestObjectMock, trustStatement: trustStatementMock)
    let url = URL(string: "openid4vp://?client_id=client_id")!

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? BITInvitation.PresentationError, .invalidRequestUri)
    }
  }

  func testExecute_missingQueryParameters_throwsInvalidQueryParametersError() async throws {
    createSuccessState(requestObject: Self.requestObjectMock, trustStatement: trustStatementMock)
    let url = URL(string: "openid4vp://")!

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? BITInvitation.PresentationError, .invalidQueryParameters)
    }
  }

  func testExecute_validateRequestObjectReturnsFalse_throwsInvalidError() async throws {
    validateRequestObjectUseCase.executeReturnValue = false

    do {
      _ = try await useCase.execute(url: httpsUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? FetchRequestObjectError, .invalid)
      XCTAssertEqual(denyPresentationUseCase.executeRequestObjectErrorCallsCount, 1)
    }
  }

  func testExecute_invalidPresentationRequest_throwsInvalidPresentRequestError() async throws {
    getCompatibleCredentialsUseCase.executeUsingReturnValue = [:]

    do {
      _ = try await useCase.execute(url: httpsUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? BITInvitation.PresentationError, .invalidPresentationRequest)
    }
  }

  func testExecute_fetchRequestObjectError_throwsError() async throws {
    fetchRequestObjectUseCase.executeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(url: httpsUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_getCompatibleCredentialsError_throwsError() async throws {
    getCompatibleCredentialsUseCase.executeUsingThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(url: httpsUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_denyPresentationError_throwsError() async throws {
    validateRequestObjectUseCase.executeReturnValue = false
    denyPresentationUseCase.executeRequestObjectErrorThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(url: httpsUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private static let requestObjectMock: RequestObject = .Mock.VcSdJwt.sample

  private let httpsUrl = URL(string: "https://example.com")!
  private let clientIdMock = "did:example:12345"
  private let openID4VPUrl = URL(string: "openid4vp://?client_id=did%3Aexample%3A12345&request_uri=https%3A%2F%2Fexample.com")!

  private let jwtRequestObjectMock: JWTRequestObject = .Mock.sample
  private let trustStatementMock = TrustStatementPayload.Mock.validSample
  private let compatibleCredentialsMock: [CompatibleCredential] = [CompatibleCredential.Mock.BIT]

  private var fetchRequestObjectUseCase: FetchRequestObjectUseCaseProtocolSpy!
  private var validateRequestObjectUseCase: ValidateRequestObjectUseCaseProtocolSpy!
  private var denyPresentationUseCase: DenyPresentationUseCaseProtocolSpy!
  private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocolSpy!
  private var getCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocolSpy!

  private var useCase: ProcessPresentationRequestUseCase!

  private func registerMocks() {
    fetchRequestObjectUseCase = FetchRequestObjectUseCaseProtocolSpy()
    validateRequestObjectUseCase = ValidateRequestObjectUseCaseProtocolSpy()
    denyPresentationUseCase = DenyPresentationUseCaseProtocolSpy()
    fetchTrustStatementUseCase = FetchTrustStatementUseCaseProtocolSpy()
    getCompatibleCredentialsUseCase = GetCompatibleCredentialsUseCaseProtocolSpy()

    Container.shared.fetchRequestObjectUseCase.register { self.fetchRequestObjectUseCase }
    Container.shared.validateRequestObjectUseCase.register { self.validateRequestObjectUseCase }
    Container.shared.denyPresentationUseCase.register { self.denyPresentationUseCase }
    Container.shared.fetchTrustStatementUseCase.register { self.fetchTrustStatementUseCase }
    Container.shared.getCompatibleCredentialsUseCase.register { self.getCompatibleCredentialsUseCase }
  }

  private func createSuccessState(requestObject: RequestObject = requestObjectMock, trustStatement: TrustStatement? = nil) {
    fetchRequestObjectUseCase.executeReturnValue = requestObject
    validateRequestObjectUseCase.executeReturnValue = true
    getCompatibleCredentialsUseCase.executeUsingReturnValue = [requestObject.presentationDefinition.inputDescriptors.first!.id: compatibleCredentialsMock]
    fetchTrustStatementUseCase.executeIssuerReturnValue = trustStatement
  }

  private func assertPresentationRequestContext(context: PresentationRequestContext, requestObject: RequestObject = requestObjectMock, trustStatement: TrustStatement? = nil) {
    XCTAssertEqual(context.requestObject, requestObject)
    XCTAssertEqual(context.compatibleCredentialsRequestMap, [Self.requestObjectMock.presentationDefinition.inputDescriptors.first!.id: compatibleCredentialsMock])
    XCTAssertNil(context.inputDescriptorId)
    XCTAssertEqual(context.selectedCredentials, [Self.requestObjectMock.presentationDefinition.inputDescriptors.first!.id: compatibleCredentialsMock.first!])
    if trustStatement != nil {
      XCTAssertEqual(context.trustStatement, trustStatement)
    } else {
      XCTAssertNil(context.trustStatement)
    }
  }

  private func assertUseCasesAreCalled(fetchTrustStatementIsCalled: Bool = false) {
    XCTAssertEqual(fetchRequestObjectUseCase.executeCallsCount, 1)
    XCTAssertEqual(fetchRequestObjectUseCase.executeReceivedUrl, httpsUrl)
    XCTAssertEqual(validateRequestObjectUseCase.executeCallsCount, 1)
    XCTAssertEqual(validateRequestObjectUseCase.executeReceivedRequestObject, Self.requestObjectMock)
    XCTAssertEqual(getCompatibleCredentialsUseCase.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCase.executeUsingReceivedRequestObject, Self.requestObjectMock)

    if fetchTrustStatementIsCalled {
      XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerCallsCount, 1)
      XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerReceivedIssuer, jwtRequestObjectMock.issuer)
    } else {
      XCTAssertFalse(fetchTrustStatementUseCase.executeIssuerCalled)
    }
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }
}

// swiftlint:enable force_unwrapping implicitly_unwrapped_optional
