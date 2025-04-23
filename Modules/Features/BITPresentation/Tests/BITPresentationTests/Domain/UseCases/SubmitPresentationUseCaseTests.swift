import BITNetworking
import Factory
import Moya
import XCTest
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

final class SubmitPresentationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setupMocks()
    success()

    useCase = SubmitPresentationUseCase()
  }

  func testSubmitPresentation_Success_JustRuns() async throws {
    try await useCase.execute(context: context)

    XCTAssertEqual(spyRepository.submitPresentationFromPresentationRequestBodyReceivedArguments?.url.absoluteString, context.requestObject.responseUri)
    XCTAssertEqual(spyRepository.submitPresentationFromPresentationRequestBodyReceivedArguments?.presentationRequestBody, mockPresentationRequestBody)

    XCTAssertEqual(spyPresentationRequestBodyGenerator.generateForRequestObjectInputDescriptorReceivedArguments?.compatibleCredential, mockCompatibleCredential)
    XCTAssertEqual(spyPresentationRequestBodyGenerator.generateForRequestObjectInputDescriptorReceivedArguments?.requestObject, context.requestObject)
    XCTAssertEqual(spyPresentationRequestBodyGenerator.generateForRequestObjectInputDescriptorReceivedArguments?.inputDescriptor, mockInputDescriptor)
  }

  func testSubmitPresentation_NoInputDescriptors_ThrowsException() async throws {
    do {
      try await useCase.execute(context: .Mock.vcSdJwtSampleWithoutInputDescriptors)
      XCTFail("Should have thrown an exception")
    } catch SubmitPresentationError.inputDescriptorsNotFound {
      XCTAssertFalse(spyRepository.submitPresentationFromPresentationRequestBodyCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_NoSelectedCredential_ThrowsException() async throws {
    context.selectedCredentials = [:]

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch SubmitPresentationError.inputDescriptorsNotFound {
      XCTAssertFalse(spyRepository.submitPresentationFromPresentationRequestBodyCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_PresentationRequestBodyGeneratorThrows_ThrowsException() async throws {
    spyPresentationRequestBodyGenerator.generateForRequestObjectInputDescriptorThrowableError = TestingError.error

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(spyPresentationRequestBodyGenerator.generateForRequestObjectInputDescriptorCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testSubmitPresentation_RepositoryThrows_ThrowsException() async throws {
    spyRepository.submitPresentationFromPresentationRequestBodyThrowableError = TestingError.error

    do {
      try await useCase.execute(context: context)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(spyRepository.submitPresentationFromPresentationRequestBodyCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  private var mockPresentationRequestBody = PresentationRequestBody(vpToken: "vpToken", presentationSubmission: PresentationRequestBody.PresentationSubmission(id: "id", definitionId: "definitionId", descriptorMap: []))

  // swiftlint:disable all
  private var mockCompatibleCredential: CompatibleCredential!
  private var mockInputDescriptor: InputDescriptor!
  private var useCase: SubmitPresentationUseCase!
  private var spyRepository: PresentationRepositoryProtocolSpy!
  private var spyPresentationRequestBodyGenerator: PresentationRequestBodyGeneratorProtocolSpy!

  // swiftlint:enable all

  private func setupMocks() {
    spyRepository = PresentationRepositoryProtocolSpy()
    spyPresentationRequestBodyGenerator = PresentationRequestBodyGeneratorProtocolSpy()

    Container.shared.presentationRepository.register { self.spyRepository }
    Container.shared.presentationRequestBodyGenerator.register { self.spyPresentationRequestBodyGenerator }

    mockCompatibleCredential = .Mock.BIT
    // swiftlint: disable all
    mockInputDescriptor = context.requestObject.presentationDefinition.inputDescriptors.first!
    // swiftlint: enable all
  }

  private func success() {
    context.selectedCredentials[mockInputDescriptor.id] = mockCompatibleCredential
    spyPresentationRequestBodyGenerator.generateForRequestObjectInputDescriptorReturnValue = mockPresentationRequestBody
  }

}
