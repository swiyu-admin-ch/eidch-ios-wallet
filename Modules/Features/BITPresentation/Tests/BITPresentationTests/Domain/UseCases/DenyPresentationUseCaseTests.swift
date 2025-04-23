import Factory
import XCTest
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

final class DenyPresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = PresentationRepositoryProtocolSpy()

    Container.shared.presentationRepository.register {
      self.repository
    }

    useCase = DenyPresentationUseCase()
  }

  func test_denyPresentationSuccess() async throws {
    // swiftlint: disable all
    let inputDescriptor = context.requestObject.presentationDefinition.inputDescriptors.first!
    // swiftlint: enable all

    context.selectedCredentials = [inputDescriptor.id: CompatibleCredential.Mock.BIT]
    try await useCase.execute(requestObject: context.requestObject, error: mockErrorType)

    XCTAssertTrue(repository.submitPresentationFromPresentationErrorRequestBodyCalled)
    XCTAssertEqual(repository.submitPresentationFromPresentationErrorRequestBodyCallsCount, 1)
    XCTAssertEqual(repository.submitPresentationFromPresentationErrorRequestBodyReceivedArguments?.presentationErrorRequestBody.error, mockErrorType)
    validateRequestBody()
  }

  func test_denyPresentationFailure() async throws {
    repository.submitPresentationFromPresentationErrorRequestBodyThrowableError = TestingError.error

    do {
      try await useCase.execute(requestObject: context.requestObject, error: mockErrorType)
    } catch TestingError.error {
      XCTAssertTrue(repository.submitPresentationFromPresentationErrorRequestBodyCalled)
      XCTAssertEqual(repository.submitPresentationFromPresentationErrorRequestBodyCallsCount, 1)
      XCTAssertEqual(repository.submitPresentationFromPresentationErrorRequestBodyReceivedArguments?.presentationErrorRequestBody.error, mockErrorType)
      validateRequestBody()
    } catch {
      XCTFail("Not the expected error")
    }
  }

  // MARK: Private

  // swiftlint:disable all
  private var useCase: DenyPresentationUseCase!
  private var context = PresentationRequestContext.Mock.vcSdJwtSample
  private var repository: PresentationRepositoryProtocolSpy!
  private var mockErrorType = PresentationErrorRequestBody.ErrorType.clientRejected

  // swiftlint:enable all

  private func validateRequestBody() {
    XCTAssertEqual(repository.submitPresentationFromPresentationErrorRequestBodyReceivedArguments?.presentationErrorRequestBody.error, .clientRejected)
    XCTAssertNil(repository.submitPresentationFromPresentationErrorRequestBodyReceivedArguments?.presentationErrorRequestBody.errorDescription)
  }

}
