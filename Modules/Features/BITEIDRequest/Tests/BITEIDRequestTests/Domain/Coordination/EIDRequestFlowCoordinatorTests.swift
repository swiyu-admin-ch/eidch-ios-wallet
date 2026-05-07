// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
final class EIDRequestFlowCoordinatorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    avBeam = AVBeamProtocolSpy()
    context = EIDRequestContext()

    Container.shared.avBeam.register { @MainActor in self.avBeam }
    Container.shared.eidRequestContext.register { @MainActor in self.context }

    sut = EIDRequestFlowCoordinator()
  }

  override func tearDown() {
    Container.shared.reset()
    super.tearDown()
  }

  // MARK: - Close Tests

  func testClose_ShouldStopAllAVBeamOperations() {
    sut.cleanup()

    XCTAssertTrue(avBeam.stopCaptureFaceCalled)
    XCTAssertTrue(avBeam.stopRecordDocumentCalled)
    XCTAssertTrue(avBeam.stopScanDocumentCalled)
    XCTAssertTrue(avBeam.stopCameraCalled)
  }

  func testClose_ShouldShutdownAVBeam() {
    sut.cleanup()

    XCTAssertTrue(avBeam.shutdownCalled)
    XCTAssertEqual(avBeam.shutdownCallsCount, 1)
  }

  func testClose_ShouldResetContext() {
    context.hasLegalRepresentant = true
    context.identityType = .identityCard
    context.caseId = "test-case-id"
    context.autoVerificationResponse = AutoVerificationResponse.Mock.nfcSample

    sut.cleanup()

    XCTAssertFalse(context.hasLegalRepresentant)
    XCTAssertNil(context.identityType)
    XCTAssertNil(context.caseId)
    XCTAssertNil(context.autoVerificationResponse)
  }

  // MARK: - Multiple Close Calls Tests

  func testMultipleCloseCalls_shouldCallAsManyTimesTheMethods() {
    sut.cleanup()
    sut.cleanup()
    sut.cleanup()

    XCTAssertEqual(avBeam.shutdownCallsCount, 3)
    XCTAssertEqual(avBeam.stopCaptureFaceCallsCount, 3)
  }

  // MARK: - Edge Cases Tests

  func testClose_WithCameraError_ShouldStillCompleteClose() {
    avBeam.stopCameraThrowableError = NSError(domain: "Test", code: -1)

    sut.cleanup()

    XCTAssertTrue(avBeam.stopCameraCalled)
    XCTAssertTrue(avBeam.shutdownCalled)
  }

  // MARK: Private

  private var sut: EIDRequestFlowCoordinator!
  private var avBeam: AVBeamProtocolSpy!
  private var context: EIDRequestContext!
}
