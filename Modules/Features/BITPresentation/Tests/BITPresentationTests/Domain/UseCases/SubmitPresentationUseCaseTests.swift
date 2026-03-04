// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITNetworking
import Factory
import Moya
import XCTest
@testable import BITActivity
@testable import BITAnyCredentialFormat
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore
@testable import BITVault

@MainActor
final class SubmitPresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setupMocks()
    success()

    useCase = SubmitPresentationUseCase()
  }

  func testSubmitPresentation_Success_JustRuns() async throws {
    try await useCase.execute(context: context)

    XCTAssertEqual(repositorySpy.submitAuthorizationResponseToReceivedArguments?.url, context.requestObject.responseUri)
    guard let submittedBody = repositorySpy.submitAuthorizationResponseToReceivedArguments?.authorizationResponse as? AuthorizationResponseBody else {
      XCTFail("Expected AuthorizationResponseBody")
      return
    }
    if case .json(let payload, _) = submittedBody {
      XCTAssertEqual(payload as? AuthorizationResponse, authorizationResponseMock)
    } else {
      XCTFail("Expected json authorization response body")
    }

    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorReceivedArguments?.compatibleCredential, mockCompatibleCredential)
    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorReceivedArguments?.requestObject, context.requestObject)
    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorReceivedArguments?.inputDescriptor, mockInputDescriptor)

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationAccepted)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCompatibleCredential.id)
  }

  func testSubmitPresentation_DcqlPreferredOverDif_UsesDcqlGenerator() async throws {
    let requestObject = RequestObject.Mock.VcSdJwt.sampleWithDcqlQuery
    let contextWithDcql = PresentationRequestContext(
      requestObject: requestObject,
      compatibleCredentials: [mockCompatibleCredential])

    try await useCase.execute(context: contextWithDcql)

    XCTAssertTrue(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorCalled)
    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorReceivedArguments?.inputDescriptor, requestObject.firstInputDescriptor)
  }

  func testSubmitPresentation_NoInputDescriptors_ThrowsException() async throws {
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorThrowableError = RequestObjectError.invalidPayload

    do {
      try await useCase.execute(context: .Mock.vcSdJwtSampleWithoutInputDescriptors)
      XCTFail("Should have thrown an exception")
    } catch BITPresentation.SubmitPresentationError.inputDescriptorsNotFound {
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_NoSelectedCredential_ThrowsException() async throws {
    context.selectedCredential = nil

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch BITPresentation.SubmitPresentationError.inputDescriptorsNotFound {
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_AuthorizationResponseBodyGeneratorThrows_ThrowsException() async throws {
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorThrowableError = TestingError.error

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_activityServiceThrows_justRuns() async throws {
    activityServiceSpy.createCredentialIdThrowableError = TestingError.error

    try await useCase.execute(context: context)
  }

  func testSubmitPresentation_RepositoryThrows_ThrowsException() async throws {
    repositorySpy.submitAuthorizationResponseToThrowableError = TestingError.error

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  private var authorizationResponseMock = AuthorizationResponse(vpToken: "vpToken", presentationSubmission: AuthorizationResponse.PresentationSubmission(id: "id", definitionId: "definitionId", descriptorMap: []))

  private var mockCompatibleCredential: CompatibleCredential!
  private var mockInputDescriptor: InputDescriptor!
  private var useCase: SubmitPresentationUseCase!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var authorizationResponseBodyGeneratorSpy: AuthorizationResponseBodyGeneratorProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!

  private func setupMocks() {
    repositorySpy = PresentationRequestRepositoryProtocolSpy()
    authorizationResponseBodyGeneratorSpy = AuthorizationResponseBodyGeneratorProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()

    Container.shared.presentationRequestRepository.register { self.repositorySpy }
    Container.shared.authorizationResponseBodyGenerator.register { self.authorizationResponseBodyGeneratorSpy }
    Container.shared.activityService.register { self.activityServiceSpy }

    mockCompatibleCredential = .Mock.BIT
    guard let descriptor = context.requestObject.presentationDefinition?.inputDescriptors.first else {
      fatalError("Missing input descriptor fixture")
    }
    mockInputDescriptor = descriptor
  }

  private func success() {
    context.selectedCredential = mockCompatibleCredential
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectInputDescriptorReturnValue = .json(authorizationResponseMock, .dif)
  }

}
