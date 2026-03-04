import Factory
import XCTest
@testable import BITEIDRequest

final class IsEIDRequestAfterOnboardingEnabledUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    repository = EIDRequestAfterOnboardingEnabledRepositoryProcotolSpy()

    Container.shared.eIDRequestAfterOnboardingEnabledRepository.register { self.repository }

    useCase = IsEIDRequestAfterOnboardingEnabledUseCase()
  }

  func testHappyPath() {
    repository.getReturnValue = true

    let result = useCase.execute()

    XCTAssertTrue(result)
  }

  // MARK: Private

  // swiftlint:disable all
  private var repository: EIDRequestAfterOnboardingEnabledRepositoryProcotolSpy!
  private var useCase: IsEIDRequestAfterOnboardingEnabledUseCase!
  // swiftlint:enable all

}
