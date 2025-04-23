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

    useCase = ProcessPresentationRequestUseCase()
  }

  func test_executeSuccess() async throws {
    let requestObject = RequestObject.Mock.VcSdJwt.sample
    let compatibleCredentials = [requestObject.presentationDefinition.inputDescriptors.first!.id: [CompatibleCredential.Mock.BIT]]

    fetchRequestObjectUseCase.executeReturnValue = requestObject
    validateRequestObjectUseCase.executeReturnValue = true
    getCompatibleCredentialsUseCase.executeUsingReturnValue = compatibleCredentials

    let result = try await useCase.execute(url: url)

    XCTAssertEqual(result.requestObject, requestObject)
    XCTAssertEqual(result.compatibleCredentialsRequestMap, compatibleCredentials)
    XCTAssertNil(result.inputDescriptorId)
    XCTAssertEqual(result.selectedCredentials, [requestObject.presentationDefinition.inputDescriptors.first!.id: CompatibleCredential.Mock.BIT])

    XCTAssertTrue(fetchRequestObjectUseCase.executeCalled)
    XCTAssertEqual(fetchRequestObjectUseCase.executeCallsCount, 1)
    XCTAssertEqual(fetchRequestObjectUseCase.executeReceivedUrl, url)

    XCTAssertTrue(validateRequestObjectUseCase.executeCalled)
    XCTAssertEqual(validateRequestObjectUseCase.executeCallsCount, 1)
    XCTAssertEqual(validateRequestObjectUseCase.executeReceivedRequestObject, requestObject)

    XCTAssertTrue(getCompatibleCredentialsUseCase.executeUsingCalled)
    XCTAssertEqual(getCompatibleCredentialsUseCase.executeUsingCallsCount, 1)
    XCTAssertEqual(getCompatibleCredentialsUseCase.executeUsingReceivedRequestObject, requestObject)

    XCTAssertFalse(fetchTrustStatementUseCase.executeIssuerCalled)
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  func test_executeSuccess_withJWTRequestObject() async throws {
    let requestObject = jwtRequestObjectMock
    let compatibleCredentials = [requestObject.presentationDefinition.inputDescriptors.first!.id: [CompatibleCredential.Mock.BIT]]
    let trustStatement = TrustStatementPayload.Mock.validSample

    fetchRequestObjectUseCase.executeReturnValue = requestObject
    validateRequestObjectUseCase.executeReturnValue = true
    getCompatibleCredentialsUseCase.executeUsingReturnValue = compatibleCredentials
    fetchTrustStatementUseCase.executeIssuerReturnValue = trustStatement

    let result = try await useCase.execute(url: url)

    XCTAssertEqual(result.requestObject, requestObject)
    XCTAssertEqual(result.compatibleCredentialsRequestMap, compatibleCredentials)
    XCTAssertEqual(result.trustStatement, trustStatement)
    XCTAssertNil(result.inputDescriptorId)
    XCTAssertEqual(result.selectedCredentials, [requestObject.presentationDefinition.inputDescriptors.first!.id: CompatibleCredential.Mock.BIT])

    XCTAssertTrue(fetchRequestObjectUseCase.executeCalled)
    XCTAssertTrue(validateRequestObjectUseCase.executeCalled)
    XCTAssertTrue(getCompatibleCredentialsUseCase.executeUsingCalled)
    XCTAssertEqual(fetchTrustStatementUseCase.executeIssuerReceivedIssuer, requestObject.issuer)
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  func test_executeFailure_invalidRequestObject() async throws {
    let requestObject = RequestObject.Mock.VcSdJwt.sample

    fetchRequestObjectUseCase.executeReturnValue = requestObject
    validateRequestObjectUseCase.executeReturnValue = false

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch FetchRequestObjectError.invalidPresentationInvitation {
      XCTAssertTrue(fetchRequestObjectUseCase.executeCalled)
      XCTAssertTrue(validateRequestObjectUseCase.executeCalled)
      XCTAssertTrue(denyPresentationUseCase.executeRequestObjectErrorCalled)
      XCTAssertEqual(denyPresentationUseCase.executeRequestObjectErrorReceivedArguments?.error, .invalidRequest)
      XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
      XCTAssertFalse(fetchTrustStatementUseCase.executeIssuerCalled)
    } catch {
      XCTFail("Not the expected error")
    }
  }

  func test_executeFailure_invalidPresentationRequest() async throws {
    let requestObject = RequestObject.Mock.VcSdJwt.sample
    let compatibleCredentials: [InputDescriptorID: [CompatibleCredential]] = [:]

    fetchRequestObjectUseCase.executeReturnValue = requestObject
    validateRequestObjectUseCase.executeReturnValue = true
    getCompatibleCredentialsUseCase.executeUsingReturnValue = compatibleCredentials

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch PresentationError.invalidPresentationRequest {
      XCTAssertTrue(fetchRequestObjectUseCase.executeCalled)
      XCTAssertTrue(validateRequestObjectUseCase.executeCalled)
      XCTAssertTrue(getCompatibleCredentialsUseCase.executeUsingCalled)
      XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
      XCTAssertFalse(fetchTrustStatementUseCase.executeIssuerCalled)
    } catch {
      XCTFail("Not the expected error")
    }
  }

  func test_executeFailure_fetchRequestObjectError() async throws {
    fetchRequestObjectUseCase.executeThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(url: url)
      XCTFail("Should have thrown an error")
    } catch TestingError.error {
      XCTAssertTrue(fetchRequestObjectUseCase.executeCalled)
      XCTAssertFalse(validateRequestObjectUseCase.executeCalled)
      XCTAssertFalse(getCompatibleCredentialsUseCase.executeUsingCalled)
      XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
      XCTAssertFalse(fetchTrustStatementUseCase.executeIssuerCalled)
    } catch {
      XCTFail("Not the expected error")
    }
  }

  func test_executeFailure_fetchTrustStatementError() async throws {
    let requestObject = jwtRequestObjectMock
    let compatibleCredentials = [requestObject.presentationDefinition.inputDescriptors.first!.id: [CompatibleCredential.Mock.BIT]]

    fetchRequestObjectUseCase.executeReturnValue = requestObject
    validateRequestObjectUseCase.executeReturnValue = true
    getCompatibleCredentialsUseCase.executeUsingReturnValue = compatibleCredentials
    fetchTrustStatementUseCase.executeIssuerThrowableError = TestingError.error

    let result = try await useCase.execute(url: url)

    XCTAssertEqual(result.requestObject, requestObject)
    XCTAssertEqual(result.compatibleCredentialsRequestMap, compatibleCredentials)
    XCTAssertNil(result.trustStatement)
    XCTAssertNil(result.inputDescriptorId)
    XCTAssertEqual(result.selectedCredentials, [requestObject.presentationDefinition.inputDescriptors.first!.id: CompatibleCredential.Mock.BIT])

    XCTAssertTrue(fetchRequestObjectUseCase.executeCalled)
    XCTAssertTrue(validateRequestObjectUseCase.executeCalled)
    XCTAssertTrue(getCompatibleCredentialsUseCase.executeUsingCalled)
    XCTAssertTrue(fetchTrustStatementUseCase.executeIssuerCalled)
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  // MARK: Private

  private var useCase: ProcessPresentationRequestUseCase!
  private var fetchRequestObjectUseCase: FetchRequestObjectUseCaseProtocolSpy!
  private var validateRequestObjectUseCase: ValidateRequestObjectUseCaseProtocolSpy!
  private var denyPresentationUseCase: DenyPresentationUseCaseProtocolSpy!
  private var fetchTrustStatementUseCase: FetchTrustStatementUseCaseProtocolSpy!
  private var getCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocolSpy!
  private let url = URL(string: "https://example.com")!

  private var jwtRequestObjectMock: JWTRequestObject = .Mock.sample

}

// swiftlint:enable force_unwrapping implicitly_unwrapped_optional
