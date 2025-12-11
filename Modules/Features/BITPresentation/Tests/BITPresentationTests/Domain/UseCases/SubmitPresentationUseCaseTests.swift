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

    XCTAssertEqual(repositorySpy.submitFromPresentationRequestBodyReceivedArguments?.url, context.requestObject.responseUri)
    XCTAssertEqual(repositorySpy.submitFromPresentationRequestBodyReceivedArguments?.presentationRequestBody, mockPresentationRequestBody)

    XCTAssertEqual(presentationRequestBodyGeneratorSpy.generateForRequestObjectInputDescriptorReceivedArguments?.compatibleCredential, mockCompatibleCredential)
    XCTAssertEqual(presentationRequestBodyGeneratorSpy.generateForRequestObjectInputDescriptorReceivedArguments?.requestObject, context.requestObject)
    XCTAssertEqual(presentationRequestBodyGeneratorSpy.generateForRequestObjectInputDescriptorReceivedArguments?.inputDescriptor, mockInputDescriptor)

    XCTAssertEqual(activityServiceSpy.createCredentialIdCallsCount, 1)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.activity.type, .presentationAccepted)
    XCTAssertEqual(activityServiceSpy.createCredentialIdReceivedArguments?.credentialId, mockCompatibleCredential.id)
  }

  func testSubmitPresentation_NoInputDescriptors_ThrowsException() async throws {
    do {
      try await useCase.execute(context: .Mock.vcSdJwtSampleWithoutInputDescriptors)
      XCTFail("Should have thrown an exception")
    } catch BITPresentation.SubmitPresentationError.inputDescriptorsNotFound {
      XCTAssertFalse(repositorySpy.submitFromPresentationRequestBodyCalled)
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
      XCTAssertFalse(repositorySpy.submitFromPresentationRequestBodyCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_PresentationRequestBodyGeneratorThrows_ThrowsException() async throws {
    presentationRequestBodyGeneratorSpy.generateForRequestObjectInputDescriptorThrowableError = TestingError.error

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(presentationRequestBodyGeneratorSpy.generateForRequestObjectInputDescriptorCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_activityServiceThrows_justRuns() async throws {
    activityServiceSpy.createCredentialIdThrowableError = TestingError.error

    try await useCase.execute(context: context)
  }

  func testSubmitPresentation_RepositoryThrows_ThrowsException() async throws {
    repositorySpy.submitFromPresentationRequestBodyThrowableError = TestingError.error

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(repositorySpy.submitFromPresentationRequestBodyCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  private var mockPresentationRequestBody = PresentationRequestBody(vpToken: "vpToken", presentationSubmission: PresentationRequestBody.PresentationSubmission(id: "id", definitionId: "definitionId", descriptorMap: []))

  private var mockCompatibleCredential: CompatibleCredential!
  private var mockInputDescriptor: InputDescriptor!
  private var useCase: SubmitPresentationUseCase!
  private var repositorySpy: PresentationRequestRepositoryProtocolSpy!
  private var presentationRequestBodyGeneratorSpy: PresentationRequestBodyGeneratorProtocolSpy!
  private var activityServiceSpy: ActivityServiceProtocolSpy!

  private func setupMocks() {
    repositorySpy = PresentationRequestRepositoryProtocolSpy()
    presentationRequestBodyGeneratorSpy = PresentationRequestBodyGeneratorProtocolSpy()
    activityServiceSpy = ActivityServiceProtocolSpy()

    Container.shared.presentationRequestRepository.register { self.repositorySpy }
    Container.shared.presentationRequestBodyGenerator.register { self.presentationRequestBodyGeneratorSpy }
    Container.shared.activityService.register { self.activityServiceSpy }

    mockCompatibleCredential = .Mock.BIT
    mockInputDescriptor = context.requestObject.presentationDefinition.inputDescriptors.first!
  }

  private func success() {
    context.selectedCredential = mockCompatibleCredential
    presentationRequestBodyGeneratorSpy.generateForRequestObjectInputDescriptorReturnValue = mockPresentationRequestBody
  }

}
