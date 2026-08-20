// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import BITSwiyuSharedKMP
import Factory
import XCTest
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - ProximityPresentationRepositoryTests

@MainActor
final class ProximityPresentationRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    controller = ProximityPresentationControllerProtocolSpy()
    Container.shared.proximityPresentationController.register { @MainActor in self.controller }
    repository = ProximityPresentationRepository()
  }

  // MARK: Engagement - Start

  func testStartEngagement_whenReadyForEngagement_emitsQrCode() async throws {
    let qrCodeData = "qr-code"
    controller.stateValuesReturnValue = .just(
      .ReadyForEngagement(qrCodeData: qrCodeData),
      .RequestingDocuments(raw: ""))

    let events = try await repository.startEngagement().collect()

    XCTAssertTrue(controller.startEngagementCalled)

    let first = try XCTUnwrap(events.first)
    guard case .qrCode(let qrCodeData) = first else {
      return XCTFail("Expected .qrCode update")
    }
    XCTAssertEqual(qrCodeData, qrCodeData)
  }

  func testStartEngagement_whenRequestingDocuments_emitsRequestAndFinishes() async throws {
    let rawRequest = "request-raw"
    controller.stateValuesReturnValue = .just(
      ProximityState.RequestingDocuments(raw: rawRequest))

    let events = try await repository.startEngagement().collect()

    XCTAssertTrue(controller.startEngagementCalled)

    let first = try XCTUnwrap(events.first)
    guard case .request(let rawRequest) = first else {
      return XCTFail("Expected .request update")
    }
    XCTAssertEqual(rawRequest.0, rawRequest.0)
    XCTAssertEqual(rawRequest.1, rawRequest.1)
  }

  func testStartEngagement_whenError_throwsFailedError() async {
    controller.stateValuesReturnValue = .just(ProximityState.Error(error: ProximityErrorUnknown(message: "engagement-error")))

    await XCTAssertThrowsErrorAsync(try await repository.startEngagement().collect()) { error in
      guard case ProximitySubmissionError.failed(let underlyingErrorMessage) = error else {
        return XCTFail("Expected ProximitySubmissionError.failed, got \(error)")
      }
      XCTAssertEqual(underlyingErrorMessage, "engagement-error")
    }
  }

  func testStartEngagement_whenDisconnected_throwsDisconnectedError() async {
    controller.stateValuesReturnValue = .just(ProximityState.Disconnected())

    await XCTAssertThrowsErrorAsync(try await repository.startEngagement().collect()) { error in
      XCTAssertEqual(error as? ProximitySubmissionError, .disconnected)
    }
  }

  func testStartEngagement_whenStreamTerminatesUnexpectedly_throwsUnexpectedTermination() async {
    controller.stateValuesReturnValue = .just()

    await XCTAssertThrowsErrorAsync(try await repository.startEngagement().collect()) { error in
      XCTAssertEqual(error as? ProximitySubmissionError, .unexpectedTermination)
    }
  }

  func testStartEngagement_whenControllerThrowsError_propagatesError() async {
    controller.stateValuesReturnValue = .fail(TestingError.error)

    await XCTAssertThrowsErrorAsync(try await repository.startEngagement().collect()) { error in
      guard case TestingError.error = error else {
        return XCTFail("Not the expected error")
      }
    }
  }

  func testStartEngagementReverse_callsControllerStartEngagementReverse() async throws {
    controller.stateValuesReturnValue = .just(
      .RequestingDocuments(raw: ""))

    _ = try await repository.startEngagementReverse(qrCode: "reader-engagement").collect()

    XCTAssertTrue(controller.startEngagementReverseReaderEngagementCalled)
    XCTAssertEqual(controller.startEngagementReverseReaderEngagementReceivedReaderEngagement, "reader-engagement")
  }

  func testSubmit_whenSubmittingDocuments_emitsProgress() async throws {
    let progress = 0.42
    controller.stateValuesReturnValue = .just(
      ProximityState.SubmittingDocuments(progress: KotlinDouble(value: progress)),
      ProximityState.PresentationCompleted())

    try await repository.submit(authorizationResponse: authorizationResponse)
      .collectAndAssertEquals([.progress(progress), .success])

    XCTAssertTrue(controller.submitDocumentDataCalled)
    XCTAssertNotNil(controller.submitDocumentDataReceivedData)
  }

  func testSubmit_whenPresentationCompleted_emitsSuccessAndFinishes() async throws {
    controller.stateValuesReturnValue = .just(
      ProximityState.PresentationCompleted())

    try await repository.submit(authorizationResponse: authorizationResponse)
      .collectAndAssertEquals([.success])

    XCTAssertTrue(controller.submitDocumentDataCalled)
  }

  func testSubmit_whenError_throwsFailedError() async {
    controller.stateValuesReturnValue = .just(.Error(error: ProximityErrorUnknown(message: "submit-error")))

    await XCTAssertThrowsErrorAsync(try await repository.submit(authorizationResponse: authorizationResponse).collect()) { error in
      guard case ProximitySubmissionError.failed(let underlyingErrorMessage) = error else {
        return XCTFail("Expected ProximitySubmissionError.failed, got \(error)")
      }
      XCTAssertEqual(underlyingErrorMessage, "submit-error")
    }
  }

  func testSubmit_whenDisconnected_throwsDisconnectedError() async {
    controller.stateValuesReturnValue = .just(.Disconnected())

    await XCTAssertThrowsErrorAsync(try await repository.submit(authorizationResponse: authorizationResponse).collect()) { error in
      XCTAssertEqual(error as? ProximitySubmissionError, .disconnected)
    }
  }

  func testSubmit_whenStreamTerminatesUnexpectedly_throwsUnexpectedTermination() async {
    controller.stateValuesReturnValue = .just()

    await XCTAssertThrowsErrorAsync(try await repository.submit(authorizationResponse: authorizationResponse).collect()) { error in
      XCTAssertEqual(error as? ProximitySubmissionError, .unexpectedTermination)
    }
  }

  func testSubmit_submitsData() async throws {
    controller.stateValuesReturnValue = .just(.PresentationCompleted())
    let data = try JSONSerialization.data(withJSONObject: authorizationResponse.asDictionary())

    try await repository.submit(authorizationResponse: authorizationResponse).collect()

    XCTAssertTrue(controller.submitDocumentDataCalled)
    XCTAssertNotNil(controller.submitDocumentDataReceivedData?.toData() == data)
  }

  func testSubmit_whenControllerThrowsError_propagatesError() async throws {
    controller.stateValuesReturnValue = .fail(TestingError.error)

    await XCTAssertThrowsErrorAsync(try await repository.submit(authorizationResponse: authorizationResponse).collect()) { error in
      guard case TestingError.error = error else {
        return XCTFail("Not the expected error")
      }
    }
  }

  func testDecline_callsControllerDecline() {
    repository.decline()

    XCTAssertTrue(controller.declineCalled)
  }

  // MARK: Private

  private var repository: ProximityPresentationRepository!
  private var controller: ProximityPresentationControllerProtocolSpy!
  private var authorizationResponse = AuthorizationResponse(vpToken: ["key": ["value"]])
}
