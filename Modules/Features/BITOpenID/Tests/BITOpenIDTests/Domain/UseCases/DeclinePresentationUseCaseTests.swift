// swiftlint: disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

final class DeclinePresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    serviceSpy = PresentationRequestServiceProtocolSpy()
    Container.shared.presentationRequestService.register { self.serviceSpy }
    useCase = DeclinePresentationUseCase()
  }

  func testExecute_passesArguments() async throws {
    try await useCase.execute(requestObject: requestObjectMock)

    XCTAssertEqual(serviceSpy.declineForWithCallsCount, 1)
    XCTAssertEqual(serviceSpy.declineForWithReceivedArguments?.requestObject, requestObjectMock)
    XCTAssertEqual(serviceSpy.declineForWithReceivedArguments?.error, .clientRejected)
  }

  func testExecute_serviceThrows_throwsError() async throws {
    serviceSpy.declineForWithThrowableError = TestingError.error

    do {
      try await useCase.execute(requestObject: requestObjectMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private var requestObjectMock = RequestObject.Mock.VcSdJwt.sample

  private var serviceSpy: PresentationRequestServiceProtocolSpy!

  private var useCase: DeclinePresentationUseCase!
}
