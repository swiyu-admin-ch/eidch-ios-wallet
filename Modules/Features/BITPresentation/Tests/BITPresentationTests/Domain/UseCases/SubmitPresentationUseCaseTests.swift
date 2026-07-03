// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITNetworking
import Factory
import Moya
import XCTest
@testable import BITActivity
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

// MARK: - SubmitPresentationUseCaseTests

@MainActor
final class SubmitPresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setupMocks()
    useCase = SubmitPresentationUseCase()
  }

  func testSubmitPresentation_Success_JustRuns() async throws {
    prepareSuccess()

    try await useCase.execute(context: context).collectAndAssertEquals([.success])

    XCTAssertEqual(repositorySpy.submitAuthorizationResponseToReceivedArguments?.url, context.requestObject.responseUri)
    guard let submittedBody = repositorySpy.submitAuthorizationResponseToReceivedArguments?.authorizationResponse as? AuthorizationResponseBody else {
      XCTFail("Expected AuthorizationResponseBody")
      return
    }
    if case .json(let payload) = submittedBody {
      XCTAssertEqual(payload as? AuthorizationResponse, authorizationResponseMock)
    } else {
      XCTFail("Expected json authorization response body")
    }

    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectReceivedArguments?.compatibleCredential, mockCompatibleCredential)
    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectReceivedArguments?.requestObject, context.requestObject)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationAccepted)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCompatibleCredential.id)
    XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
  }

  func testSubmitPresentation_generatorThrowsInvalidPayload_ThrowsAuthorizationRequestError() async throws {
    prepareSuccess()
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectThrowableError = RequestObjectError.invalidPayload()

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? SubmitPresentationUseCaseError, .invalidAuthorizationRequest)
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToCalled)
    }
  }

  func testSubmitPresentation_NoSelectedCredential_ThrowsMissingSelectedCredential() async throws {
    prepareSuccess()
    context.selectedCredential = nil

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? SubmitPresentationUseCaseError, .missingSelectedCredential)
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToCalled)
    }
  }

  func testSubmitPresentation_AuthorizationResponseBodyGeneratorThrows_ThrowsException() async throws {
    prepareSuccess()
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectCalled)
    }
  }

  func testSubmitPresentation_activityServiceThrows_justRuns() async throws {
    prepareSuccess()
    activityServiceSpy.createCredentialIdThrowableError = TestingError.error

    try await useCase.execute(context: context).collectAndAssertEquals([.success])
  }

  func testSubmitPresentation_RepositoryThrows_ThrowsException() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToCalled)
      XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testSubmitPresentation_RepositoryThrowsTimeout_DoesNotCreateActivity() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToThrowableError = NetworkError(status: .timeout)

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual((error as? NetworkError)?.status, .timeout)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToCalled)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testSubmitPresentation_RepositoryThrowsHttpNetworkError_DoesNotCreateActivity() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToThrowableError = NetworkError(status: .badRequest)

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual((error as? NetworkError)?.status, .badRequest)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToCalled)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testSubmitPresentation_Proximity_UsesProximityRepository() async throws {
    prepareSuccess(mockProximityRepository: true)

    let proximityContext = PresentationRequestContext(
      requestObjectJWS: context.requestObjectJWS,
      compatibleCredentials: context.compatibleCredentials,
      transport: .proximity)
    proximityContext.selectedCredential = context.selectedCredential

    try await useCase.execute(context: proximityContext).collectAndAssertEquals([.success])

    XCTAssertEqual(proximityRepository.submitPresentationRequestBodyCallsCount, 1)
    XCTAssertFalse(repositorySpy.submitAuthorizationResponseToCalled)
    XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
  }

  func testSubmitPresentation_Proximity_RepositoryThrows_ThrowsException() async throws {
    prepareSuccess()

    proximityRepository.submitPresentationRequestBodyReturnValue = .fail(TestingError.error)

    let proximityContext = PresentationRequestContext(
      requestObjectJWS: context.requestObjectJWS,
      compatibleCredentials: context.compatibleCredentials,
      transport: .proximity)
    proximityContext.selectedCredential = context.selectedCredential

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: proximityContext).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(proximityRepository.submitPresentationRequestBodyCallsCount, 1)
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToCalled)
      XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
    }
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  private var authorizationResponseMock = AuthorizationResponse(vpToken: ["id": ["token"]])

  private var mockCompatibleCredential: CompatibleCredential!
  private var useCase: SubmitPresentationUseCase!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var authorizationResponseBodyGeneratorSpy: AuthorizationResponseBodyGeneratorProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
  private var proximityRepository: ProximityPresentationRepositoryProtocolSpy!
  private var rotateNextPresentableBundleItemUseCaseProtocolSpy: RotateNextPresentableBundleItemUseCaseProtocolSpy!

  private func setupMocks() {
    repositorySpy = PresentationRequestRepositoryProtocolSpy()
    authorizationResponseBodyGeneratorSpy = AuthorizationResponseBodyGeneratorProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    proximityRepository = ProximityPresentationRepositoryProtocolSpy()
    rotateNextPresentableBundleItemUseCaseProtocolSpy = RotateNextPresentableBundleItemUseCaseProtocolSpy()

    Container.shared.presentationRequestRepository.register { @MainActor in self.repositorySpy }
    Container.shared.authorizationResponseBodyGenerator.register { @MainActor in self.authorizationResponseBodyGeneratorSpy }
    Container.shared.activityService.register { @MainActor in self.activityServiceSpy }
    Container.shared.proximityPresentationRepository.register { @MainActor in self.proximityRepository }
    Container.shared.rotateNextPresentableBundleItemUseCase.register { @MainActor in self.rotateNextPresentableBundleItemUseCaseProtocolSpy }

    mockCompatibleCredential = .Mock.BIT
  }

  private func prepareSuccess(mockProximityRepository: Bool = false) {
    context.selectedCredential = mockCompatibleCredential
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectReturnValue = .json(authorizationResponseMock)
    if mockProximityRepository {
      proximityRepository.submitPresentationRequestBodyReturnValue = .just(.success)
    }
  }
}
