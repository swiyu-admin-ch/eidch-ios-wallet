// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

@MainActor
final class DeclinePresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    presentationRequestServiceSpy = PresentationRequestServiceProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()
    Container.shared.presentationRequestService.register { self.presentationRequestServiceSpy }
    Container.shared.activityService.register { self.activityServiceSpy }
    useCase = DeclinePresentationUseCase()
  }

  func testExecute_passesArguments() async throws {
    try await useCase.execute(context: contextMock)

    XCTAssertEqual(presentationRequestServiceSpy.declineForWithCallsCount, 1)
    XCTAssertEqual(presentationRequestServiceSpy.declineForWithReceivedArguments?.requestObject, contextMock.requestObject)
    XCTAssertEqual(presentationRequestServiceSpy.declineForWithReceivedArguments?.error, .clientRejected)

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationDeclined)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, contextMock.selectedCredential?.id)
  }

  func testExecute_serviceThrows_throwsError() async throws {
    presentationRequestServiceSpy.declineForWithThrowableError = TestingError.error

    do {
      try await useCase.execute(context: contextMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

  private var presentationRequestServiceSpy: PresentationRequestServiceProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!

  private var useCase: DeclinePresentationUseCase!
}
