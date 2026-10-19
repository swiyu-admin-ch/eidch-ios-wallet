import AVFoundation
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
@MainActor
class DocumentSelectionViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    let context = EIDRequestContext()
    self.context = context
    Container.shared.eidRequestContext.register { @MainActor in context }
    viewModel = DocumentSelectionViewModel()
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testOpenScanner() {
    viewModel.didSelect(.identityCard)

    XCTAssertEqual(viewModel.destination, .scanDocumentInformation(isBackEnabled: true))
    XCTAssertEqual(context.identityType, .identityCard)
  }

  // MARK: Private

  private var viewModel: DocumentSelectionViewModel!
  private var context: EIDRequestContext!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
