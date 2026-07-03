// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
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
    try await useCase(context: contextMock)

    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithCallsCount, 1)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.url, contextMock.requestObject.responseUri)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.error, .accessDenied)

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  func testExecuteWithUrl_success() async throws {
    try await useCase(url: XCTUnwrap(contextMock.responseUri))

    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithCallsCount, 1)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.url, contextMock.requestObject.responseUri)
    XCTAssertEqual(presentationRequestServiceSpy.declineUrlWithReceivedArguments?.error, .accessDenied)
  }

  func testExecute_serviceThrows_throwsError() async throws {
    presentationRequestServiceSpy.declineUrlWithThrowableError = TestingError.error

    do {
      try await useCase(context: contextMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 0)
    }
  }

  func testExecute_Proximity_UsesRepositoryOnly() async throws {
    let proximityContext = PresentationRequestContext(
      requestObjectJWS: contextMock.requestObjectJWS,
      compatibleCredentials: contextMock.compatibleCredentials,
      transport: .proximity)
    proximityContext.selectedCredential = contextMock.selectedCredential

    try await useCase(context: proximityContext)

    XCTAssertTrue(proximityRepository.declineCalled)
    XCTAssertFalse(presentationRequestServiceSpy.declineUrlWithCalled)
    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  func testExecuteWithUrl_serviceThrows_throwsError() async throws {
    presentationRequestServiceSpy.declineUrlWithThrowableError = TestingError.error

    do {
      try await useCase(url: XCTUnwrap(contextMock.responseUri))
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

  private var presentationRequestServiceSpy: PresentationRequestServiceProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!
  private var proximityRepository: ProximityPresentationRepositoryProtocolSpy!

  private var useCase: DeclinePresentationUseCase!
}
