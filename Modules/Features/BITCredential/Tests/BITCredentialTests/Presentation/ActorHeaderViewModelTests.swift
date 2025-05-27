import SwiftUI
import XCTest
@testable import BITCredential

final class ActorHeaderViewModelTests: XCTestCase {

  @MainActor
  func testInitNameAndTrustStatus() {
    let viewModel = ActorHeaderViewModel(name: "Alice", trustStatus: .verified)

    XCTAssertEqual(viewModel.name, "Alice")
    XCTAssertEqual(viewModel.trustStatus, .verified)
    XCTAssertNil(viewModel.image)
  }

  @MainActor
  func testInitWithImage() {
    let testImage = Image(systemName: "person")
    let viewModel = ActorHeaderViewModel(name: "Bob", trustStatus: .verified, image: testImage)

    XCTAssertEqual(viewModel.name, "Bob")
    XCTAssertEqual(viewModel.trustStatus, .verified)
    XCTAssertNotNil(viewModel.image)
  }

  @MainActor
  func testInitWithImageData() {
    // swiftlint:disable all
    let data = UIImage(systemName: "person")!.pngData()!
    // swiftlint:enable all
    let viewModel = ActorHeaderViewModel(name: "Carol", trustStatus: .verified, imageData: data)

    XCTAssertNotNil(viewModel.image)
  }
}
