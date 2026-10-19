import Factory
import Foundation
import Spyable
import XCTest
@testable import BITOnboarding

@MainActor
final class PinCodeInformationViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    router = MockOnboardingInternalRoutes()
    viewModel = PinCodeInformationViewModel(router: router)
  }

  func testInit() {
    XCTAssertFalse(viewModel.primaryText.isEmpty)
    XCTAssertFalse(viewModel.secondaryText.isEmpty)
    XCTAssertFalse(viewModel.buttonLabelText.isEmpty)
    XCTAssertNotNil(viewModel.image)
    XCTAssertNotNil(viewModel.backgroundImage)
  }

  func testNextOnboardingStep() {
    viewModel.nextOnboardingStep()
    XCTAssertTrue(router.pinCodeCalled)
  }

  func testPinCodeDelegate() {
    let initialPrimaryText = viewModel.primaryText
    let initialSecondaryText = viewModel.secondaryText
    let initialButtonLabelText = viewModel.buttonLabelText
    viewModel.didTryTooManyAttempts()
    XCTAssertNotEqual(initialSecondaryText, viewModel.secondaryText)
    XCTAssertEqual(initialPrimaryText, viewModel.primaryText)
    XCTAssertEqual(initialButtonLabelText, viewModel.buttonLabelText)
  }

  func testOnAppear() {
    let initialPrimaryText = viewModel.primaryText
    let initialSecondaryText = viewModel.secondaryText
    let initialButtonLabelText = viewModel.buttonLabelText
    viewModel.onAppear()
    XCTAssertEqual(initialSecondaryText, viewModel.secondaryText)
    XCTAssertEqual(initialPrimaryText, viewModel.primaryText)
    XCTAssertEqual(initialButtonLabelText, viewModel.buttonLabelText)

    simulateBackAction()
    XCTAssertNotEqual(initialSecondaryText, viewModel.secondaryText)
    XCTAssertEqual(initialPrimaryText, viewModel.primaryText)
    XCTAssertEqual(initialButtonLabelText, viewModel.buttonLabelText)

    viewModel.onAppear()
    XCTAssertEqual(initialSecondaryText, viewModel.secondaryText)
    XCTAssertEqual(initialPrimaryText, viewModel.primaryText)
    XCTAssertEqual(initialButtonLabelText, viewModel.buttonLabelText)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: PinCodeInformationViewModel!
  private var router: MockOnboardingInternalRoutes!

  // swiftlint:enable all

  private func simulateBackAction() {
    viewModel.didTryTooManyAttempts()
    viewModel.onAppear()
  }

}
