import AVFoundation
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
@MainActor
class DocumentSelectionViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    context = EIDRequestContext()
    Container.shared.eidRequestContext.register { self.context }
    viewModel = DocumentSelectionViewModel()
  }

  @MainActor
  func testOpenScanner() {
    viewModel.didSelect(.identityCard)

    XCTAssertEqual(viewModel.destination, .scanDocumentInformation)
    XCTAssertEqual(context.identityType, .identityCard)
  }

  // MARK: Private

  private var viewModel: DocumentSelectionViewModel!
  private var context: EIDRequestContext!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
