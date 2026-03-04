import Factory
import XCTest
@testable import BITEIDRequest

final class EnableEIDRequestAfterOnboardingUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    repository = EIDRequestAfterOnboardingEnabledRepositoryProcotolSpy()

    Container.shared.eIDRequestAfterOnboardingEnabledRepository.register { self.repository }

    useCase = EnableEIDRequestAfterOnboardingUseCase()
  }

  func testHappyPath() {
    useCase.execute(true)
    XCTAssertEqual(repository.setReceivedEnabled, true)
  }

  // MARK: Private

  // swiftlint:disable all
  private var repository: EIDRequestAfterOnboardingEnabledRepositoryProcotolSpy!
  private var useCase: EnableEIDRequestAfterOnboardingUseCase!
  // swiftlint:enable all

}
