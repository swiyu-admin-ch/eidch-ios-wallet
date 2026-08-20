// swiftlint: disable implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITActivity
@testable import BITEntities

final class NonComplianceReasonDisplayFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.configureInMemoryDataStore()
    factory = NonComplianceReasonDisplayFactory()
  }

  func testCallAsFunction_success_returnsDisplay() throws {
    let entity = try NonComplianceReasonDisplayEntity.Mock.create(locale: localeMock, value: valueMock)

    let display = factory(entity)

    XCTAssertEqual(display.locale, localeMock)
    XCTAssertEqual(display.value, valueMock)
  }

  // MARK: Private

  private let localeMock = "locale"
  private let valueMock = "value"

  private var factory: NonComplianceReasonDisplayFactory!
}
