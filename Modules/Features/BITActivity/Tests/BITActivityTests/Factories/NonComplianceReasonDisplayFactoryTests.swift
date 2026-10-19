import Factory
import FactoryTesting
import Testing
@testable import BITActivity
@testable import BITEntities

// MARK: - NonComplianceReasonDisplayFactoryTests

@MainActor
@Suite(.container)
struct NonComplianceReasonDisplayFactoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.configureInMemoryDataStore()
    factory = NonComplianceReasonDisplayFactory()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success_returnsDisplay() throws {
    let entity = try NonComplianceReasonDisplayEntity.Mock.create(locale: localeMock, reason: reasonMock)

    let display = factory(entity)

    #expect(display.locale == localeMock)
    #expect(display.reason == reasonMock)
  }

  // MARK: Private

  private let localeMock = "locale"
  private let reasonMock = "reason"

  private let factory: NonComplianceReasonDisplayFactory
}
