// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITEIDRequest

class DocumentSelectionViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = DocumentSelectionViewModel(router: router, cameraPermission: .authorized)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testOpenScannerWithCameraPermission() {
    viewModel = DocumentSelectionViewModel(router: router, cameraPermission: .authorized)
    viewModel.didSelect(.identityCard)

    XCTAssertTrue(router.scanDocumentCalled)
    XCTAssertEqual(router.context.identityType, .identityCard)
  }

  @MainActor
  func testOpenScannerWithoutCameraPermission() {
    viewModel = DocumentSelectionViewModel(router: router, cameraPermission: .notDetermined)

    for identityType in IdentityType.allCases {
      viewModel.didSelect(identityType)
      XCTAssertTrue(router.cameraPermissionCalled)
      XCTAssertEqual(router.context.identityType, identityType)
    }
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: DocumentSelectionViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
