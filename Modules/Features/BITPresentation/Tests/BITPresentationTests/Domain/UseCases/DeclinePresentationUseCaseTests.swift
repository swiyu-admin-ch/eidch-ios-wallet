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
    presentationRequestServiceSpy.declineUrlWithReturnValue = redirect

    let response = try await useCase(context: contextMock)

    XCTAssertEqual(response, redirect)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithCallsCount, 1)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.url, contextMock.requestObject.responseUri)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.error, .accessDenied)

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  func testExecuteWithUrl_success() async throws {
    let response = try await useCase(url: XCTUnwrap(contextMock.responseUri))

    XCTAssertNil(response)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithCallsCount, 1)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.url, contextMock.requestObject.responseUri)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.error, .accessDenied)
  }

  func testExecute_serviceThrows_throwsError() async throws {
    presentationRequestServiceSpy.declineUrlWithThrowableError = TestingError.error

    do {
      _ = try await useCase(context: contextMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testExecute_serviceThrowsNoConnection_DoesNotCreateActivity() async throws {
    presentationRequestServiceSpy.declineUrlWithThrowableError = NetworkError(status: .noConnection)

    do {
      _ = try await useCase(context: contextMock)
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .noConnection)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testExecute_serviceThrowsHttpNetworkError_CreatesActivity() async throws {
    presentationRequestServiceSpy.declineUrlWithThrowableError = NetworkError(status: .badRequest)

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
    presentationRequestServiceSpy.declineUrlWithThrowableError = PresentationResponseValidationError.invalidRedirectUri

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
    XCTAssertFalse(presentationRequestServiceSpy.declineUrlWithCalled)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  func testExecuteWithUrl_serviceThrows_throwsError() async throws {
    presentationRequestServiceSpy.declineUrlWithThrowableError = TestingError.error

    do {
      _ = try await useCase(url: XCTUnwrap(contextMock.responseUri))
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtSample

  private var presentationRequestServiceSpy: PresentationRequestServiceProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
  private var proximityRepository: ProximityPresentationRepositoryProtocolSpy!

  private var useCase: DeclinePresentationUseCase!
}
