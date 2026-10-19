import Factory
import XCTest
@testable import BITAppAuth

final class NoDevicePinCodeViewModelTests: XCTestCase {

  override func setUp() {
    super.setUp()
    let hasDevicePinUseCase = HasDevicePinUseCaseProtocolSpy()
    Container.shared.hasDevicePinUseCase.register { @MainActor in hasDevicePinUseCase }
  }

  @MainActor
  func testOpenSettings() {
    let router = NoDevicePinCodeRouterMock()
    let viewModel = NoDevicePinCodeViewModel(router: router)

    viewModel.openSettings()
    XCTAssertTrue(router.didCallExternalSettings)
  }
}
