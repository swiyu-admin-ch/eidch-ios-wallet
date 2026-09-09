// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITNetworking
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - DeclinePresentationUseCaseTests

@MainActor
final class DeclinePresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    presentationRequestServiceSpy = PresentationRequestServiceProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    proximityRepository = ProximityPresentationRepositoryProtocolSpy()
    Container.shared.presentationRequestService.register { @MainActor in self.presentationRequestServiceSpy }
    Container.shared.activityService.register { @MainActor in self.activityServiceSpy }
    Container.shared.proximityPresentationRepository.register { @MainActor in self.proximityRepository }
    useCase = DeclinePresentationUseCase()
  }

  func testExecute_passesArguments() async throws {
    let redirect = PresentationResponse(redirectUri: URL(string: "https://verifier.ch"))
    presentationRequestServiceSpy.declineUrlStateWithReturnValue = redirect

    let response = try await useCase(context: contextMock)

    XCTAssertEqual(response, redirect)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlStateWithCallsCount, 1)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlStateWithReceivedArguments?.url, contextMock.requestObject.responseUri)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlStateWithReceivedArguments?.error, .accessDenied)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlStateWithReceivedArguments?.state, "1234")

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  func testExecute_serviceThrows_throwsError() async throws {
    presentationRequestServiceSpy.declineUrlStateWithThrowableError = TestingError.error

    do {
      _ = try await useCase(context: contextMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testExecute_serviceThrowsNoConnection_DoesNotCreateActivity() async throws {
    presentationRequestServiceSpy.declineUrlStateWithThrowableError = NetworkError(status: .noConnection)

    do {
      _ = try await useCase(context: contextMock)
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .noConnection)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testExecute_serviceThrowsHttpNetworkError_CreatesActivity() async throws {
    presentationRequestServiceSpy.declineUrlStateWithThrowableError = NetworkError(status: .badRequest)

    do {
      _ = try await useCase(context: contextMock)
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .badRequest)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
    }
  }

  func testExecute_serviceThrowsPresentationResponseValidationError_CreatesActivity() async throws {
    presentationRequestServiceSpy.declineUrlStateWithThrowableError = PresentationResponseValidationError.invalidRedirectUri

    await XCTAssertThrowsErrorAsync(try await useCase(context: contextMock)) { error in
      XCTAssertEqual(error as? PresentationResponseValidationError, .invalidRedirectUri)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
      XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
    }
  }

  func testExecute_Proximity_UsesRepositoryOnly() async throws {
    let proximityContext = PresentationRequestContext(
      requestObjectJWS: contextMock.requestObjectJWS,
      compatibleCredentials: contextMock.compatibleCredentials,
      transport: .proximity)
    proximityContext.selectedCredential = contextMock.selectedCredential

    let response = try await useCase(context: proximityContext)

    XCTAssertNil(response)
    XCTAssertTrue(proximityRepository.declineCalled)
    XCTAssertFalse(presentationRequestServiceSpy.declineUrlStateWithCalled)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  // MARK: Private

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtSample

  private var presentationRequestServiceSpy: PresentationRequestServiceProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
  private var proximityRepository: ProximityPresentationRepositoryProtocolSpy!

  private var useCase: DeclinePresentationUseCase!
}
