import Factory
import XCTest
@testable import BITAppAuth

final class NoDevicePinCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    hasDevicePinUseCase = HasDevicePinUseCaseProtocolSpy()

    Container.shared.hasDevicePinUseCase.register { @MainActor in self.hasDevicePinUseCase }

    router = NoDevicePinCodeRouterMock()
    viewModel = NoDevicePinCodeViewModel(router: router)
  }

  @MainActor
  func testOpenSettings() {
    viewModel.openSettings()
    XCTAssertTrue(router.didCallExternalSettings)
  }

  // MARK: Private

  // swiftlint:disable all
  private var router: NoDevicePinCodeRouterMock!
  private var viewModel: NoDevicePinCodeViewModel!
  private var hasDevicePinUseCase: HasDevicePinUseCaseProtocolSpy!
  // swiftlint:enable all
}
