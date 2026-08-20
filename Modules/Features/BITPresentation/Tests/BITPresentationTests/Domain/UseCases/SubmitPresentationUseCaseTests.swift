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
    let redirect = PresentationResponse(redirectUri: URL(string: "https://verifier.ch"))
    repositorySpy.submitAuthorizationResponseToEncryptionReturnValue = redirect

    try await useCase.execute(context: context).collectAndAssertEquals([.success(redirect)])
    XCTAssertEqual(repositorySpy.submitAuthorizationResponseToEncryptionReceivedArguments?.url, context.requestObject.responseUri)
    XCTAssertEqual(repositorySpy.submitAuthorizationResponseToEncryptionReceivedArguments?.authorizationResponse, authorizationResponseMock)
    XCTAssertEqual(repositorySpy.submitAuthorizationResponseToEncryptionReceivedArguments?.encryption, encryptionMock)

    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectWithOriginReceivedArguments?.compatibleCredential, mockCompatibleCredential)
    XCTAssertEqual(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectWithOriginReceivedArguments?.requestObject, context.requestObject)
    XCTAssertEqual(authorizationResponseEncryptionGeneratorSpy.callAsFunctionForReceivedClientMetadata, context.requestObject.clientMetadata)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationAccepted)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCompatibleCredential.id)
    XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
  }

  func testSubmitPresentation_generatorThrowsInvalidPayload_ThrowsAuthorizationRequestError() async throws {
    prepareSuccess()
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectWithOriginThrowableError = RequestObjectError.invalidPayload()

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? SubmitPresentationUseCaseError, .invalidAuthorizationRequest)
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
    }
  }

  func testSubmitPresentation_NoSelectedCredential_ThrowsMissingSelectedCredential() async throws {
    prepareSuccess()
    context.selectedCredential = nil

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? SubmitPresentationUseCaseError, .missingSelectedCredential)
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
    }
  }

  func testSubmitPresentation_AuthorizationResponseBodyGeneratorThrows_ThrowsException() async throws {
    prepareSuccess()
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectWithOriginThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectWithOriginCalled)
    }
  }

  func testSubmitPresentation_activityServiceThrows_justRuns() async throws {
    prepareSuccess()
    activityServiceSpy.createCredentialIdThrowableError = TestingError.error

    try await useCase.execute(context: context).collectAndAssertEquals([.success(nil)])
  }

  func testSubmitPresentation_encryptionGeneratorThrows_ThrowsException() async throws {
    prepareSuccess()
    authorizationResponseEncryptionGeneratorSpy.callAsFunctionForThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testSubmitPresentation_RepositoryThrows_ThrowsException() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToEncryptionThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
      XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testSubmitPresentation_RepositoryThrowsTimeout_DoesNotCreateActivity() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToEncryptionThrowableError = NetworkError(status: .timeout)

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual((error as? NetworkError)?.status, .timeout)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testSubmitPresentation_RepositoryThrowsNoConnection_DoesNotCreateActivity() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToEncryptionThrowableError = NetworkError(status: .noConnection)

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual((error as? NetworkError)?.status, .noConnection)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testSubmitPresentation_RepositoryThrowsHttpNetworkError_CreatesActivity() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToEncryptionThrowableError = NetworkError(status: .badRequest)

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual((error as? NetworkError)?.status, .badRequest)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationAccepted)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCompatibleCredential.id)
    }
  }

  func testSubmitPresentation_RepositoryThrowsPresentationResponseValidationError_CreatesActivity() async throws {
    prepareSuccess()
    repositorySpy.submitAuthorizationResponseToEncryptionThrowableError = PresentationResponseValidationError.invalidRedirectUri

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: context).collect()) { error in
      XCTAssertEqual(error as? PresentationResponseValidationError, .invalidRedirectUri)
      XCTAssertTrue(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationAccepted)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCompatibleCredential.id)
    }
  }

  func testSubmitPresentation_Proximity_UsesProximityRepository() async throws {
    prepareSuccess(mockProximityRepository: true)

    let proximityContext = PresentationRequestContext(
      requestObjectJWS: contextProximity.requestObjectJWS,
      compatibleCredentials: contextProximity.compatibleCredentials,
      transport: .proximity)
    proximityContext.selectedCredential = context.selectedCredential

    try await useCase.execute(context: proximityContext).collectAndAssertEquals([.success(nil)])
    XCTAssertEqual(proximityRepository.submitAuthorizationResponseCallsCount, 1)
    XCTAssertFalse(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
    XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
    XCTAssertEqual(authorizationResponseEncryptionGeneratorSpy.callAsFunctionForCallsCount, 0)
  }

  func testSubmitPresentation_Proximity_RepositoryThrows_ThrowsException() async throws {
    prepareSuccess()

    proximityRepository.submitAuthorizationResponseReturnValue = .fail(TestingError.error)

    let proximityContext = PresentationRequestContext(
      requestObjectJWS: contextProximity.requestObjectJWS,
      compatibleCredentials: contextProximity.compatibleCredentials,
      transport: .proximity)
    proximityContext.selectedCredential = context.selectedCredential

    await XCTAssertThrowsErrorAsync(try await useCase.execute(context: proximityContext).collect()) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(proximityRepository.submitAuthorizationResponseCallsCount, 1)
      XCTAssertFalse(repositorySpy.submitAuthorizationResponseToEncryptionCalled)
      XCTAssertEqual(rotateNextPresentableBundleItemUseCaseProtocolSpy.callAsFunctionCallsCount, 1)
    }
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  private let authorizationResponseMock = AuthorizationResponse(vpToken: ["id": ["token"]])
  private let encryptionMock = AuthorizationResponseEncryption(jwk: .Mock.validSample, algorithm: .A256GCM)
  private let contextProximity = PresentationRequestContext.Mock.vcSdJwtSampleProximity

  private var mockCompatibleCredential: CompatibleCredential!
  private var useCase: SubmitPresentationUseCase!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var authorizationResponseBodyGeneratorSpy: AuthorizationResponseBodyGeneratorProtocolSpy!
  private var authorizationResponseEncryptionGeneratorSpy: AuthorizationResponseEncryptionGeneratorProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
  private var proximityRepository: ProximityPresentationRepositoryProtocolSpy!
  private var rotateNextPresentableBundleItemUseCaseProtocolSpy: RotateNextPresentableBundleItemUseCaseProtocolSpy!

  private func setupMocks() {
    repositorySpy = PresentationRequestRepositoryProtocolSpy()
    authorizationResponseBodyGeneratorSpy = AuthorizationResponseBodyGeneratorProtocolSpy()
    authorizationResponseEncryptionGeneratorSpy = AuthorizationResponseEncryptionGeneratorProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    proximityRepository = ProximityPresentationRepositoryProtocolSpy()
    rotateNextPresentableBundleItemUseCaseProtocolSpy = RotateNextPresentableBundleItemUseCaseProtocolSpy()

    Container.shared.presentationRequestRepository.register { @MainActor in self.repositorySpy }
    Container.shared.authorizationResponseBodyGenerator.register { @MainActor in self.authorizationResponseBodyGeneratorSpy }
    Container.shared.authorizationResponseEncryptionGenerator.register { @MainActor in self.authorizationResponseEncryptionGeneratorSpy }
    Container.shared.activityService.register { @MainActor in self.activityServiceSpy }
    Container.shared.proximityPresentationRepository.register { @MainActor in self.proximityRepository }
    Container.shared.rotateNextPresentableBundleItemUseCase.register { @MainActor in self.rotateNextPresentableBundleItemUseCaseProtocolSpy }

    mockCompatibleCredential = .Mock.BIT
  }

  private func prepareSuccess(mockProximityRepository: Bool = false) {
    context.selectedCredential = mockCompatibleCredential
    authorizationResponseBodyGeneratorSpy.callAsFunctionForRequestObjectWithOriginReturnValue = authorizationResponseMock
    if mockProximityRepository {
      proximityRepository.submitAuthorizationResponseReturnValue = .just(.success)
    }
    authorizationResponseEncryptionGeneratorSpy.callAsFunctionForReturnValue = encryptionMock
  }
}
