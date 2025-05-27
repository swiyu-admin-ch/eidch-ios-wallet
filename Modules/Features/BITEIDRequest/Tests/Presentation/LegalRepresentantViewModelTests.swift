// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest

@MainActor
class LegalRepresentantViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    legalRepresentantRepository = LegalRepresentantRepositoryProcotolSpy()

    Container.shared.legalRepresentantRepository.register { self.legalRepresentantRepository }
    viewModel = LegalRepresentantViewModel(router: router)
  }

  func testYesAction() {
    viewModel.yesAction()

    XCTAssertEqual(legalRepresentantRepository.setReceivedValue, true)
    XCTAssertTrue(router.checkCardIntroductionCalled)
  }

  func testNoAction() {
    viewModel.noAction()

    XCTAssertEqual(legalRepresentantRepository.setReceivedValue, false)
    XCTAssertTrue(router.checkCardIntroductionCalled)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: LegalRepresentantViewModel!
  private var legalRepresentantRepository: LegalRepresentantRepositoryProcotolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
