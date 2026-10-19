// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITL10n
@testable import BITNonCompliance
@testable import BITTestingCore

@MainActor
final class NonComplianceDescriptionViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    registerMocks()
    viewModel = NonComplianceDescriptionViewModel(initialValue: valueMock)
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testInit_validValue_valueSetAndIsValid() {
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

  private let valueMock = "value"

  private var nonComplianceFormValidatorSpy: NonComplianceFormValidatorProtocolSpy!
  private var viewModel: NonComplianceDescriptionViewModel!

  private func registerMocks() {
    let nonComplianceFormValidatorSpy = NonComplianceFormValidatorProtocolSpy()
    self.nonComplianceFormValidatorSpy = nonComplianceFormValidatorSpy
    nonComplianceFormValidatorSpy.validateForReturnValue = .valid
    Container.shared.nonComplianceFormValidator.register { @MainActor in nonComplianceFormValidatorSpy }
  }
}
