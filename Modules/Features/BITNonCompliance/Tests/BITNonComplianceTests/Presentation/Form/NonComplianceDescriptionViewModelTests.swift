// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITL10n
@testable import BITNonCompliance
@testable import BITTestingCore

@MainActor
final class NonComplianceDescriptionViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    viewModel = NonComplianceDescriptionViewModel(initialValue: valueMock)
  }

  func testInit_validValue_valueSetAndIsValid() {
    viewModel = NonComplianceDescriptionViewModel(initialValue: valueMock)

    XCTAssertEqual(viewModel.value, valueMock)
    XCTAssertEqual(viewModel.validation, .valid)
  }

  func testInit_malformedValue_valueSetAndIsMalformed() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed

    viewModel = NonComplianceDescriptionViewModel(initialValue: valueMock)

    XCTAssertEqual(viewModel.value, valueMock)
    XCTAssertEqual(viewModel.validation, .malformed)
  }

  func testSetValue_valid_valueSetAndIsValid() {
    viewModel.value = valueMock

    XCTAssertEqual(viewModel.value, valueMock)
    XCTAssertEqual(viewModel.validation, .valid)
  }

  func testSetValue_valid_argumentsPassed() {
    XCTAssertEqual(nonComplianceFormValidatorSpy.validateForCallsCount, 1)

    viewModel.value = valueMock

    XCTAssertEqual(nonComplianceFormValidatorSpy.validateForCallsCount, 2)
    XCTAssertEqual(nonComplianceFormValidatorSpy.validateForReceivedArguments?.field, .description)
    XCTAssertEqual(nonComplianceFormValidatorSpy.validateForReceivedArguments?.value, valueMock)
  }

  func testValidate_malformed_valueSetAndIsMalformed() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed

    viewModel.value = valueMock

    XCTAssertEqual(viewModel.value, valueMock)
    XCTAssertEqual(viewModel.validation, .malformed)
  }

  // MARK: Private

  private var viewModel: NonComplianceDescriptionViewModel!
  private let valueMock = "value"

  private var nonComplianceFormValidatorSpy: NonComplianceFormValidatorProtocolSpy!

  private func registerMocks() {
    nonComplianceFormValidatorSpy = NonComplianceFormValidatorProtocolSpy()

    Container.shared.nonComplianceFormValidator.register { self.nonComplianceFormValidatorSpy }
  }

  private func createSuccessState() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .valid
  }
}
